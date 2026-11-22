# Driver VGA 640×480 sur FPGA Basys 3 (VHDL)

> *VGA 640×480 @ 60 Hz controller written in VHDL on a Digilent Basys 3 (Artix-7) board, built with Vivado: colour stripes, then a 32×16 sprite stored in a ROM, then a 240×160 colour image read from an FPGA Block RAM; both images are moved with the switches.*

## Le projet

Travaux pratiques de **Systèmes sur Puce et Systèmes Embarqués** (Master 2 Capteurs, Électronique et Objets Connectés, Université de Montpellier). L'objectif : faire afficher une image sur un écran VGA directement depuis le FPGA, sans processeur, en générant soi‑même les signaux de synchronisation.

- **Carte** : Digilent Basys 3 (Artix‑7 `xc7a35tcpg236-1`), sortie VGA 12 bits (4 bits par couleur)
- **Outils** : VHDL, Xilinx Vivado 2025.2 (synthèse, simulation, programmation)

## Ce qu'on a fait

### TP1 — Bandes de couleur

On génère les signaux `hsync` et `vsync` du VGA 640×480 à 60 Hz à partir de l'horloge 100 MHz de la carte (divisée par 4 pour obtenir 25 MHz, l'horloge pixel). Deux compteurs (`hc` pour la colonne, `vc` pour la ligne) repèrent le pixel courant, et un bloc de couleur affiche des bandes rouge/vert de 16 lignes dans la zone visible.

```mermaid
flowchart LR
    clk["mclk 100 MHz"] --> div["div_clk"]
    div -- "clk25" --> vga["VGA640x480"]
    vga -- "hsync, vsync" --> ecran(("écran VGA"))
    vga -- "hc, vc, vidon" --> col["VGA_STRIPES"]
    col -- "red, green, blue (4 bits)" --> ecran
```

### TP2 — Sprite stocké dans une PROM

On remplace le bloc de bandes par un petit dessin de **32×16 pixels** (un cadre avec mes initiales « TJ ») stocké dans une mémoire PROM écrite en VHDL. Le bloc `VGA_PROM` calcule, pour chaque pixel de l'écran, s'il tombe dans le sprite, puis lit le bon bit dans la PROM. Les **8 interrupteurs** de la carte déplacent le sprite : `SW0–SW3` pour la position horizontale (pas de 40 pixels) et `SW4–SW7` pour la verticale (pas de 30 lignes).

```mermaid
flowchart LR
    clk["mclk 100 MHz"] --> div["div_clk"]
    div -- "clk25" --> vga["VGA640x480"]
    vga -- "hsync, vsync" --> ecran(("écran VGA"))
    vga -- "hc, vc, vidon" --> sp["VGA_PROM"]
    sw["sw[7:0]"] --> sp
    sp -- "adresse (4 bits)" --> rom["PROM 16×32"]
    rom -- "ligne du sprite (32 bits)" --> sp
    sp -- "red, green, blue" --> ecran
```

Le contenu de la PROM (chaque `#` est un pixel blanc) :

```
################################
#..............................#
#.############.......#########.#
#.############.......#########.#
#......##................##....#
#......##................##....#
#......##................##....#
#......##................##....#
#......##................##....#
#......##................##....#
#......##........##......##....#
#......##........##......##....#
#......##.........########.....#
#......##..........######......#
#..............................#
################################
```

### TP3 — Image couleur stockée en Block ROM

Dans le TP2, le dessin était écrit à la main dans le VHDL, un bit par pixel. Pour une vraie image en couleur, ce n'est plus possible : on la stocke dans une **mémoire interne du FPGA** (Block RAM utilisée en ROM), générée par l'IP Xilinx *Block Memory Generator* et remplie par un fichier `.coe`. L'image fait **240 × 160 pixels**, soit 38 400 octets, chaque octet codant un pixel au format `RRRGGGBB` (256 couleurs). Les 8 interrupteurs déplacent toujours l'image.

```mermaid
flowchart LR
    clk["mclk 100 MHz"] --> div["div_clk"]
    div -- "clk25" --> vga["VGA640x480"]
    vga -- "hsync, vsync" --> ecran(("écran VGA"))
    vga -- "hc, vc, vidon" --> sp["VGA_PROM_2"]
    sw["sw[7:0]"] --> sp
    sp -- "rom_addr16 (16 bits)" --> rom["sprite_rom<br/>Block ROM 38 400 × 8 bits"]
    div -- "clk25" --> rom
    rom -- "M (8 bits RRRGGGBB)" --> sp
    sp -- "red, green, blue (4 bits)" --> ecran
```

Le module `VGA_PROM_2`, écrit pour ce TP, fait trois choses :

- **Il calcule l'adresse du pixel** : l'image est rangée ligne après ligne, donc `adresse = ypix × 240 + xpix`. La multiplication par 240 se fait sans multiplieur, avec quatre décalages et quatre additions (`240 = 128 + 64 + 32 + 16`). Hors de l'image, l'adresse est forcée à 0 pour ne jamais sortir de la ROM.
- **Il compense la latence de la mémoire** : la Block ROM est synchrone et ne rend la donnée qu'un cycle d'horloge après avoir reçu l'adresse, quand le balayage a déjà avancé d'un pixel. Le module présente donc l'adresse du pixel **suivant**. Sans cette correction, toute l'image serait décalée d'un pixel vers la droite.
- **Il convertit la couleur** : chaque composante est étendue à 4 bits pour la sortie VGA de la Basys 3 en recopiant ses bits de poids fort (`111` → `1111`, `000` → `0000`), pour que le blanc reste blanc et le noir reste noir.

Un point de l'énoncé était contradictoire : le texte parle de données sur 12 bits, mais la figure de l'IP et les fichiers `.coe` fournis sont en 8 bits. J'ai suivi les fichiers réels (8 bits) et documenté l'écart. Les pas de déplacement (25 pixels en colonne, 20 lignes en ligne) sont choisis pour que l'image reste toujours entière à l'écran.

### Le VGA 640×480 en chiffres

| Paramètre | Valeur |
|---|---|
| Horloge pixel | 25 MHz (100 MHz ÷ 4) |
| Pixels par ligne | 800 (96 synchro + 48 back porch + 640 visibles + 16 front porch) |
| Lignes par image | 521 (2 synchro + 29 back porch + 480 visibles + 10 front porch) |
| Durée d'une ligne / d'une image | 32 µs / 16,67 ms, soit 59,98 Hz |

## Résultats

### Sur la carte

La carte Basys 3 est reliée à l'écran par un câble VGA.

<p align="center">
  <img src="images/01_carte_basys3_vga.jpg" alt="Carte Basys 3 reliée à l'écran par le câble VGA" width="320">
</p>

**TP1** — les bandes rouge/vert s'affichent sur l'écran (les franges fines sont un effet de moiré de la photo). Sur la seconde photo, on voit le poste complet : l'écran, la simulation dans Vivado et la carte.

<p align="center">
  <img src="images/02_tp1_bandes_rouge_vert.jpg" alt="Bandes rouge et vert affichées sur l'écran VGA" width="340">
  <img src="images/03_tp1_poste_simulation_et_carte.jpg" alt="Poste de travail : écran VGA, chronogrammes Vivado et carte Basys 3" width="460">
</p>

**TP2** — le sprite « TJ » s'affiche en haut à gauche de l'écran quand tous les interrupteurs sont à 0, et le code de la PROM est celui ouvert dans Vivado sur la seconde photo.

<p align="center">
  <img src="images/04_tp2_sprite_TJ_ecran.jpg" alt="Sprite TJ affiché en haut à gauche de l'écran" width="340">
  <img src="images/05_tp2_PROM_dans_Vivado.jpg" alt="Fichier PROM.vhd ouvert dans Vivado" width="460">
</p>

<p align="center">
  <img src="images/06_tp2_poste_de_travail.jpg" alt="Poste de travail du TP2" width="640">
</p>

### Vidéo : déplacement du sprite avec les interrupteurs

On déplace le sprite sur l'écran en actionnant les interrupteurs de la carte.

[![Aperçu de la vidéo](video/tp2_deplacement_sprite_apercu.gif)](video/tp2_deplacement_sprite.mp4)

*Cliquer sur l'aperçu pour ouvrir la vidéo complète (32 s, [`tp2_deplacement_sprite.mp4`](video/tp2_deplacement_sprite.mp4)).*

**TP3** — l'image couleur 240 × 160, lue dans la Block ROM, s'affiche nette sur fond noir. Sur la seconde photo, on voit l'écran VGA, Vivado (Hardware Manager, carte programmée, fichier `VGA_PROM_2.vhd` ouvert) et la carte Basys 3 au premier plan.

<p align="center">
  <img src="images/07_tp3_image_ferrari_ecran.jpg" alt="Image couleur 240×160 lue dans la Block ROM, affichée sur l'écran VGA" width="340">
  <img src="images/08_tp3_poste_vivado_et_carte.jpg" alt="Poste du TP3 : écran VGA avec l'image, Vivado et carte Basys 3" width="460">
</p>

### Vidéo : déplacement de l'image (TP3)

L'image change de position sur l'écran quand on actionne les interrupteurs.

[![Aperçu de la vidéo du TP3](video/tp3_deplacement_image_apercu.gif)](video/tp3_deplacement_image.mp4)

*Cliquer sur l'aperçu pour ouvrir la vidéo complète (11 s, [`tp3_deplacement_image.mp4`](video/tp3_deplacement_image.mp4)).*

### En simulation

Les chronogrammes ont été relevés sur la simulation et correspondent à ce qui est attendu :

| Mesure | Attendu | Relevé |
|---|---|---|
| Période de `clk25` | 40 ns | 40 ns |
| Période de `hsync` | 32 µs | 32,000 µs |
| `vsync` à 0 | 64 µs | 64,000 µs |
| Période d'image | 16,67 ms | 16,672 ms |
| Pixels visibles par image | 640 × 480 = 307 200 | 307 200 |
| Sprite (interrupteurs à 0) | 188 pixels allumés, colonnes 145 à 176, lignes 32 à 47 | identique à la PROM, pixel par pixel |

Pour le TP3, la simulation a été faite avec **GHDL** et un modèle de la Block ROM que j'ai écrit (même interface que l'IP, lecture à un cycle de latence, contenu lu dans le `.coe`). Un script Python compare **chaque pixel** de l'écran à l'image attendue, calculée directement depuis le `.coe` :

| Test (2 images de 640 × 480) | Image 1 : interrupteurs `00000000` | Image 2 : `00100011` (image décalée de 75 px et 40 lignes) |
|---|---|---|
| Pixels de l'image faux | 0 / 38 400 | 0 / 38 400 |
| Pixels du fond noir faux | 0 / 268 800 | 0 / 268 800 |
| Adresses hors de la ROM | 0 | 0 |

Le test détecte bien un décalage d'un seul pixel : sans la compensation de latence, il trouve 6 354 pixels faux sur la première image.

## Organisation du dossier

```
05_driver_vga/
├── README.md
├── images/                 photos du montage et des résultats
├── video/                  vidéos du TP2 et du TP3 (et leurs aperçus)
├── tp1_vga_stripes/        TP1 : sources, testbenches, contraintes .xdc, create_project.tcl
├── tp2_vga_prom/           TP2 : idem, avec PROM.vhd et VGA_PROM.vhd
└── tp3_vga_bloc_rom/       TP3 : sources/, simulation/, constraints/, verification/, create_project.tcl
```

Chaque dossier de TP contient tout ce qu'il faut pour recréer le projet : `create_project.tcl` crée le projet Vivado (`Tools → Run Tcl Script…`), avec comme top de synthèse `TOP_VGA_SPRITES` (TP1) ou `TOP_VGA_PROM` (TP2) et comme top de simulation le testbench `…_tb` correspondant (lancer la simulation sur 35 ms pour voir une image complète).

Pour le TP3, le script crée aussi l'IP `sprite_rom` ; il faut d'abord placer le fichier `.coe` du cours dans `tp3_vga_bloc_rom/ip/` (détails dans le [guide du TP3](tp3_vga_bloc_rom/LISEZ-MOI.md)).

Le reset est affecté à un bouton de la carte : `BTNR` (TP1) et le bouton central `BTNC` (TP2), voir les fichiers `.xdc`. Au TP3, il est aussi sur le bouton central.

## Crédits

Le fichier `VGA640x480.vhd` reprend le code de référence montré en cours (HAE924E, Université de Montpellier). Le reste (division d'horloge, couleurs, PROM, sprite, déplacement, testbenches) est le travail du TP. Au TP3, `VGA_PROM_2`, `TOP_VGA_PROM_2`, le modèle de ROM, le script de vérification et les testbenches sont mon travail ; l'image et son fichier `.coe` viennent des ressources du cours et ne sont pas publiés.

## Pistes

- Relever les rapports Vivado du TP3 (ressources LUT et BRAM, timing).
- Passer à 4 096 couleurs avec un `.coe` 12 bits et une ROM de 12 bits de large.
