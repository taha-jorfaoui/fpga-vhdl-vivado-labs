#!/usr/bin/env python3
"""Compare, pixel par pixel, l'image affichee en simulation (VCD GHDL) a l'image attendue
calculee directement depuis le .coe.   Usage : check_image.py top.vcd COE240x160.coe"""
import sys
vcd, coe = sys.argv[1], sys.argv[2]
W, H, HBP, VBP, XSTEP, YSTEP = 240, 160, 144, 31, 25, 20

# --- image attendue (RRRGGGBB -> 4 bits par composante, bits de poids fort recopies)
body = open(coe).read().split("memory_initialization_vector=")[1]
rom = [int(x, 16) for x in body.replace(";", "").replace("\n", "").split(",") if x.strip()]
assert len(rom) == W * H, len(rom)
def expand(b):
    r, g, bl = b >> 5, (b >> 2) & 7, b & 3
    return ((r << 1) | (r >> 2), (g << 1) | (g >> 2), (bl << 2) | bl)

# --- lecture du VCD
want = {('top_vga_prom_2_tb', 'red'): 'red', ('top_vga_prom_2_tb', 'green'): 'green',
        ('top_vga_prom_2_tb', 'blue'): 'blue', ('uut', 'hc_s'): 'hc', ('uut', 'vc_s'): 'vc'}
ids, scope, unit = {}, [], 1
f = open(vcd)
for l in f:
    if l.startswith('$scope'): scope.append(l.split()[2])
    elif l.startswith('$upscope'): scope.pop()
    elif l.startswith('$timescale'):
        t = l.split()[1:3] if len(l.split()) > 2 else None
    elif l.startswith('$var'):
        p = l.split(); k = (scope[-1], p[4].split('[')[0])
        if k in want and p[3] not in ids: ids[p[3]] = want[k]
    elif l.startswith('$enddefinitions'): break
FS_PER_MS = 10**12   # GHDL ecrit son VCD en femtosecondes
cur, t, changed = {}, 0, False
frames = {1: {}, 2: {}}
def rec():
    try:
        key = (int(cur['vc'], 2), int(cur['hc'], 2))
        rgb = tuple(int(cur[c], 2) for c in ('red', 'green', 'blue'))
    except (KeyError, ValueError):
        return
    frames[1 if t < 17 * FS_PER_MS else 2][key] = rgb
for l in f:
    l = l.strip()
    if not l: continue
    if l[0] == '#':
        if changed: rec()
        t = int(l[1:]); changed = False; continue
    if l[0] == 'b':
        v, i = l[1:].split()
        if i in ids:
            cur[ids[i]] = v
            if ids[i] == 'hc': changed = True
if changed: rec()

# --- comparaison
ok_all = True
for fr, sw in ((1, 0b00000000), (2, 0b00100011)):
    xo, yo = (sw & 15) * XSTEP, (sw >> 4) * YSTEP
    P = frames[fr]
    bad_img = bad_black = n_img = n_black = missing = 0
    for vc in range(VBP, VBP + 480):
        for hc in range(HBP, HBP + 640):
            r, c = vc - VBP - 1 - yo, hc - HBP - 1 - xo
            if (vc, hc) not in P: missing += 1; continue
            if 0 <= r < H and 0 <= c < W:
                n_img += 1; bad_img += P[(vc, hc)] != expand(rom[r * W + c])
            else:
                n_black += 1; bad_black += P[(vc, hc)] != (0, 0, 0)
    outside = [k for k, v in P.items() if not (VBP <= k[0] < VBP + 480 and HBP <= k[1] < HBP + 640) and v != (0, 0, 0)]
    ok = bad_img == 0 and bad_black == 0 and missing == 0 and not outside and n_img == W * H
    ok_all &= ok
    print(f"Image {fr} (sw={sw:08b}, decalage x={xo} y={yo}) : "
          f"{n_img} px image, {bad_img} faux | {n_black} px noirs, {bad_black} faux | "
          f"hors zone visible non noirs : {len(outside)} | pixels manquants : {missing}  ->  {'OK' if ok else 'ECHEC'}")
sys.exit(0 if ok_all else 1)
