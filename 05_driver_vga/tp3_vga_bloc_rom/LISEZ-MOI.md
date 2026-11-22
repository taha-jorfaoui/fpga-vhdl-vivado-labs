# TP3 – Image couleur en Block ROM (Basys 3, Vivado)

Affiche une image **240 × 160** en couleur (fichier `COE240x160.coe` du cours) sur un écran VGA 640 × 480, depuis une **Block ROM** du FPGA (IP Xilinx *Block Memory Generator*). Les 8 interrupteurs déplacent l'image. Suite du TP2 : mêmes `div_clk` et `VGA640x480`.

La présentation du projet, les schémas et les photos sont dans le [README du driver VGA](../README.md#tp3--image-couleur-stockée-en-block-rom).

## Recréer le projet dans Vivado

1. Placer le fichier `COE240x160.coe` du cours dans `ip/` (il n'est pas publié ici, voir plus bas).
2. Vivado → **Tools > Run Tcl Script…** → choisir `create_project.tcl`.
3. Le projet est créé dans `vivado/` (ignoré par Git), sans copier les sources. Le script crée aussi l'IP `sprite_rom`.
4. **Run Simulation** (testbench `TOP_VGA_PROM_2_tb`, 35 ms déjà réglés), puis Synthèse → Implémentation → Bitstream → Programmer la carte.

## Contenu

| Fichier | Rôle |
|---|---|
| `sources/div_clk.vhd` | 100 MHz → 25 MHz (compteur 2 bits), repris du TP2 |
| `sources/VGA640x480.vhd` | Compteurs `hc`, `vc`, `hsync`, `vsync`, `vidon`, repris du TP2 |
| `sources/VGA_PROM_2.vhd` | **Nouveau.** Calcule `rom_addr16 = ypix × 240 + xpix`, lit l'octet `M` et produit `red`, `green`, `blue` |
| `sources/TOP_VGA_PROM_2.vhd` | **Nouveau.** Top-level : `U1 div_clk`, `U2 VGA640x480`, `U3 VGA_PROM_2`, `U4 sprite_rom` |
| `simulation/TOP_VGA_PROM_2_tb.vhd` | Test final : 1ʳᵉ image avec `sw = 00000000`, 2ᵉ image avec `sw = 00100011` |
| `simulation/div_clk_tb.vhd`, `VGA640x480_tb.vhd` | Tests des blocs repris |
| `constraints/Basys3_VGA_PROM_2.xdc` | Broches Basys 3 (reset sur le bouton central U18), horloge 25 MHz générée, CFGBVS |
| `create_project.tcl` | Crée le projet et l'IP `sprite_rom` |
| `verification/` | Modèle de ROM et script de contrôle pour GHDL, **hors projet Vivado** |

## Choix techniques

**IP `sprite_rom`** : Single Port ROM, largeur 8 bits, profondeur 38 400, *Always Enabled*, *Primitives Output Register* décoché, initialisée par le `.coe`.

> **Écart avec l'énoncé.** Le texte parle de « 12 bits », mais la figure de l'IP, les fichiers `.coe` fournis et la suite de l'énoncé sont en **8 bits** au format `RRRGGGBB`. Le projet suit donc les fichiers réels : rouge = `M(7:5)`, vert = `M(4:2)`, bleu = `M(1:0)`, chacun étendu à 4 bits en recopiant ses bits de poids fort (`111` → `1111`, `000` → `0000`).

**Adressage.** `rom_addr16 = ypix × 240 + xpix`, avec `ypix × 240 = ypix × (128 + 64 + 32 + 16)` : quatre décalages et quatre additions, sans multiplieur. Hors de l'image, l'adresse est forcée à 0 : elle ne sort jamais de la ROM.

**Latence de la Block ROM.** La BRAM est synchrone : la donnée de l'adresse présentée à un front de `clk25` n'arrive qu'après ce front, quand `hc` a déjà avancé d'un pixel. On adresse donc le pixel **suivant** (`xpix = hc − hbp − xoff`, au lieu de `… − 1`). Sans cette correction, l'image serait décalée d'un pixel (6 354 pixels faux en simulation).

**Position de l'image.** `sw(3:0)` : colonne, pas de 25 pixels (0 à 375) ; `sw(7:4)` : ligne, pas de 20 lignes (0 à 300). Ces pas sont un choix du projet : l'image reste toujours entière à l'écran (375 + 240 ≤ 640, 300 + 160 ≤ 480).

## Vérification en simulation (GHDL 4.1.0)

Le design complet a été simulé 35 ms (2 images) avec un modèle de la ROM (`verification/sprite_rom_model.vhd` : même interface, lecture synchrone à 1 cycle, contenu lu dans le `.coe`). `verification/check_image.py` compare **chaque pixel** de l'écran 640 × 480 à l'image attendue, calculée directement depuis le `.coe`.

| Image | Interrupteurs | Pixels de l'image faux | Pixels noirs faux | Hors zone visible non noirs |
|---|---|---|---|---|
| 1 | `00000000` (x = 0, y = 0) | 0 / 38 400 | 0 / 268 800 | 0 |
| 2 | `00100011` (x = 75, y = 40) | 0 / 38 400 | 0 / 268 800 | 0 |

Pour rejouer la vérification (depuis ce dossier, avec `COE240x160.coe` copié à côté) :

```
ghdl -a --std=93c --ieee=synopsys -fexplicit sources/div_clk.vhd sources/VGA640x480.vhd sources/VGA_PROM_2.vhd verification/sprite_rom_model.vhd sources/TOP_VGA_PROM_2.vhd simulation/TOP_VGA_PROM_2_tb.vhd
ghdl -e --std=93c --ieee=synopsys -fexplicit TOP_VGA_PROM_2_tb
ghdl -r --std=93c --ieee=synopsys -fexplicit TOP_VGA_PROM_2_tb --stop-time=35ms --vcd=top.vcd
python3 verification/check_image.py top.vcd COE240x160.coe
```

`-fexplicit` n'est utile que pour GHDL, pas pour Vivado.

## Sur la carte

L'image s'affiche en couleur sur un écran VGA relié à la Basys 3, sur fond noir, et change de position quand on actionne les interrupteurs (photos dans `../images/`, vidéo dans `../video/`).

Non mesuré : les rapports d'utilisation (LUT, BRAM) et de timing de Vivado, et la position exacte de l'image pour chaque combinaison d'interrupteurs. Un décalage d'un seul pixel ne se voit pas sur une photo : la correction de latence est établie par la simulation.

## Fichiers non publiés

`COE240x160.coe` (contenu de la ROM) et l'image d'origine viennent des ressources du cours HAE924E : ils ne sont pas dans le dépôt. Pour afficher une autre image, générer un `.coe` 8 bits à partir d'un BMP ou JPG, recréer l'IP avec la nouvelle profondeur, puis adapter `w`, `h` et la constante `240` du calcul d'adresse dans `VGA_PROM_2.vhd`. Au-delà de 65 536 pixels, il faut un bus d'adresse de 17 bits.
