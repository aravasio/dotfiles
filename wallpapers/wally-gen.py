#!/usr/bin/env python3
import math, os, random, shutil, subprocess, sys, tempfile, pathlib
from PIL import Image, ImageDraw, ImageFilter, ImageChops, ImageEnhance

OUT = os.path.expanduser('~/dotfiles/wallpapers/Pictures/wallpapers')
os.makedirs(OUT, exist_ok=True)

BG = (25, 25, 25)
FG = (196, 196, 181)
BRIGHT = (246, 246, 238)
ROSE = (243, 0, 95)
GREEN = (151, 224, 35)
ORANGE = (250, 132, 25)
YELLOW = (223, 213, 97)
PURPLE = (156, 100, 254)
CYAN = (87, 209, 234)

FW, FH = 3840, 2160

STOPS = [
    (0.00, BG),
    (0.16, ROSE),
    (0.38, PURPLE),
    (0.60, CYAN),
    (0.76, GREEN),
    (0.90, YELLOW),
    (1.00, BRIGHT),
]


def ramp(v):
    if v <= 0.0:
        return BG
    if v >= 1.0:
        return BRIGHT
    for i in range(len(STOPS) - 1):
        p0, c0 = STOPS[i]
        p1, c1 = STOPS[i + 1]
        if v <= p1:
            t = (v - p0) / (p1 - p0)
            return tuple(int(c0[k] + (c1[k] - c0[k]) * t) for k in range(3))
    return BRIGHT


def vgrad(top, bot, w, h):
    data = bytearray()
    for y in range(h):
        t = y / (h - 1)
        c = (int(top[0] + (bot[0] - top[0]) * t),
             int(top[1] + (bot[1] - top[1]) * t),
             int(top[2] + (bot[2] - top[2]) * t))
        data += bytes(c) * w
    return Image.frombytes('RGB', (w, h), bytes(data))


def vignette(img, strong=0.5):
    w, h = img.size
    img = img.convert('RGB')
    px = img.load()
    data = bytearray()
    for y in range(h):
        ny = (y / h - 0.5) * 2
        for x in range(w):
            nx = (x / w - 0.5) * 2
            d = math.sqrt(nx * nx + ny * ny)
            f = 1.0 - strong * max(0.0, d - 0.35)
            if f < 0.1:
                f = 0.1
            p = px[x, y]
            data += bytes((min(255, int(p[0] * f)), min(255, int(p[1] * f)), min(255, int(p[2] * f))))
    return Image.frombytes('RGB', (w, h), bytes(data))


def bloom(img, radii=(2, 5, 10), wfrac=0.5):
    out = img.copy()
    for r in radii:
        bl = img.filter(ImageFilter.GaussianBlur(r))
        glow = ImageChops.add(img, bl)
        out = Image.blend(out, glow, wfrac)
    return out


def up(img, w=FW, h=FH):
    return img.resize((w, h), Image.LANCZOS).filter(ImageFilter.UnsharpMask(radius=1.8, percent=110, threshold=2))


def save(img, name):
    path = os.path.join(OUT, name)
    img.save(path, 'PNG')
    print('saved', name)


def draw_stars(d, w, h, n):
    cols = (BRIGHT, FG, CYAN, YELLOW)
    for _ in range(n):
        x = random.uniform(0, w)
        y = random.uniform(0, h)
        r = random.choice((1, 1, 1, 2))
        a = random.randint(60, 200)
        d.ellipse((x - r, y - r, x + r, y + r), fill=random.choice(cols) + (a,))


def aurora_still():
    img = vgrad(BG, (11, 11, 15), FW, FH).convert('RGBA')
    gheight = int(FH * 0.10)
    gimg = vgrad((14, 14, 19), BG, FW, gheight).convert('RGBA')
    img.alpha_composite(gimg, (0, FH - gheight))

    specs = [
        (CYAN, 0.30, 0.10, 9.0, 0.0, 0.24, 150),
        (GREEN, 0.44, 0.12, 6.5, 2.1, 0.30, 140),
        (PURPLE, 0.40, 0.09, 11.0, 4.0, 0.20, 120),
        (ROSE, 0.54, 0.07, 7.3, 1.2, 0.16, 110),
        (YELLOW, 0.20, 0.05, 5.0, 3.0, 0.06, 60),
    ]
    for color, base, amp, freq, phase, thick, alpha in specs:
        layer = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
        d = ImageDraw.Draw(layer)
        top = []
        bot = []
        for x in range(0, FW + 8, 8):
            s = base + amp * math.sin(x / 1000.0 * freq + phase) + amp * 0.5 * math.sin(x / 340.0 * freq * 1.7 + phase * 2.3)
            top.append((x, s * FH))
            bot.append((x, (s + thick) * FH))
        d.polygon(top + list(reversed(bot)), fill=color + (alpha,))
        for x, y in top:
            d.ellipse((x - 14, y - 14, x + 14, y + 14), fill=color + (40,))
        layer = layer.filter(ImageFilter.GaussianBlur(int(FH * 0.012)))
        img.alpha_composite(layer)

        edge = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
        de = ImageDraw.Draw(edge)
        de.line(top, fill=BRIGHT + (110,), width=3)
        edge = edge.filter(ImageFilter.GaussianBlur(3))
        img.alpha_composite(edge)

    stars = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    draw_stars(ImageDraw.Draw(stars), FW, FH, 120)
    stars = stars.filter(ImageFilter.GaussianBlur(1))
    img.alpha_composite(stars)

    glowline = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    dg = ImageDraw.Draw(glowline)
    dg.rectangle((0, FH - gheight - 60, FW, FH - gheight), fill=CYAN + (30,))
    glowline = glowline.filter(ImageFilter.GaussianBlur(60))
    img.alpha_composite(glowline)
    return img.convert('RGB')


def plasma_still(t=2.7):
    SW, SH = 1440, 810
    data = bytearray()
    for y in range(SH):
        ny = y / SH
        for x in range(SW):
            nx = x / SW
            v = (math.sin(nx * 9.0 + t) + math.sin(ny * 7.0 - t * 0.7)
                 + math.sin((nx + ny) * 6.0 + t * 1.3)
                 + math.sin(math.hypot(nx - 0.5, ny - 0.5) * 15.0 - t * 2.0)
                 + math.sin(nx * 3.0 + ny * 5.0 + t * 0.9)) / 5.0
            vv = max(0.0, min(1.0, (v + 1.0) * 0.5))
            data += bytes(ramp(vv ** 1.3))
    img = Image.frombytes('RGB', (SW, SH), bytes(data)).convert('RGB')
    img = vignette(img, 0.42)
    return bloom(up(img))


def caustic_still():
    SW, SH = 1440, 810
    scales = (12.0, 22.0, 40.0, 75.0)
    weights = (1.0, 0.8, 0.55, 0.35)
    data = bytearray()
    for y in range(SH):
        ny = y / SH
        for x in range(SW):
            nx = x / SW
            s = 0.0
            for k, wk in zip(scales, weights):
                ax = (nx * 1.4 + 0.3) * k
                ay = (ny * 1.4 - 0.2) * k
                s += wk * abs(math.sin(ax) * math.cos(ay))
            v = s / sum(weights)
            vv = (v ** 1.12) * 1.08
            data += bytes(ramp(min(1.0, vv)))
    img = Image.frombytes('RGB', (SW, SH), bytes(data)).convert('RGB')
    img = img.filter(ImageFilter.GaussianBlur(1))
    img = vignette(img, 0.5)
    return bloom(up(img))


def mandel_still():
    cx, cy, r = -0.7269, 0.1889, 0.15
    maxit = 500
    SW, SH = 1440, 810
    data = bytearray()
    aw = r * 2.0
    ah = r * 2.0 * (SH / SW)
    for y in range(SH):
        yp = cy - (y / SH - 0.5) * ah
        for x in range(SW):
            xp = cx + (x / SW - 0.5) * aw
            zr, zi = 0.0, 0.0
            it = 0
            while it < maxit:
                zr2, zi2 = zr * zr, zi * zi
                if zr2 + zi2 > 4.0:
                    break
                zi = 2.0 * zr * zi + yp
                zr = zr2 - zi2 + xp
                it += 1
            if it == maxit:
                data += bytes(BG)
            else:
                zr2, zi2 = zr * zr, zi * zi
                mu = it + 1 - math.log2(max(1e-9, math.log2(math.sqrt(zr2 + zi2))))
                data += bytes(ramp(mu / maxit))
    img = Image.frombytes('RGB', (SW, SH), bytes(data)).convert('RGB')
    return bloom(up(img), radii=(1, 3, 6))


def julia_still():
    SW, SH = 1920, 1080
    cx, cy = -0.4, 0.6
    maxit = 80
    r = 1.7
    aw = r * 2.0
    ah = r * 2.0 * (SH / SW)
    mu_field = bytearray()
    for y in range(SH):
        yp = cy + (y / SH - 0.5) * ah
        for x in range(SW):
            xp = cx + (x / SW - 0.5) * aw
            zr, zi = xp, yp
            it = 0
            while it < maxit:
                zr2, zi2 = zr * zr, zi * zi
                if zr2 + zi2 > 4.0:
                    break
                zi = 2.0 * zr * zi - cy
                zr = zr2 - zi2 - cx
                it += 1
            if it == maxit:
                mu_field += bytes((255,))
            else:
                zr2, zi2 = zr * zr, zi * zi
                mu = it + 1 - math.log2(max(1e-9, math.log2(math.sqrt(zr2 + zi2))))
                mu_field += bytes((int(255 * (mu / maxit)),))
    field = Image.frombytes('L', (SW, SH), bytes(mu_field))
    field = field.filter(ImageFilter.GaussianBlur(1.2))
    fp = field.load()
    palette = (FG, CYAN, GREEN, ROSE, PURPLE, ORANGE, YELLOW, ROSE)
    out = bytearray()
    n = len(palette)
    for y in range(SH):
        for x in range(SW):
            v = fp[x, y]
            if v >= 254:
                out += bytes(BG)
            else:
                band = int((v * n) / 255.0) % n
                out += bytes(palette[band])
    img = Image.frombytes('RGB', (SW, SH), bytes(out)).convert('RGB')
    img = up(img)
    img = vignette(img, 0.35)
    return bloom(img, radii=(1, 3, 6), wfrac=0.4)


def rain_still():
    img = vgrad(BG, (12, 12, 15), FW, FH).convert('RGBA')

    hint = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    dh = ImageDraw.Draw(hint)
    for x in range(0, FW, 10):
        s = 0.14 + 0.03 * math.sin(x / 700.0 * 2.0) + 0.02 * math.sin(x / 180.0 * 3.0)
        dh.line((x, s * FH, x, (s + 0.09) * FH), fill=PURPLE + (26,), width=12)
    hint = hint.filter(ImageFilter.GaussianBlur(30))
    img.alpha_composite(hint)

    puddle = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    dp = ImageDraw.Draw(puddle)
    dp.ellipse((-int(FW * 0.2), FH - int(FH * 0.28), int(FW * 1.2), FH + int(FH * 0.35)), fill=CYAN + (60,))
    dp.ellipse((-int(FW * 0.1), FH - int(FH * 0.36), int(FW * 1.1), FH + int(FH * 0.25)), fill=PURPLE + (40,))
    puddle = puddle.filter(ImageFilter.GaussianBlur(50))
    img.alpha_composite(puddle)

    d = ImageDraw.Draw(img)
    cols = (CYAN, GREEN, PURPLE, ROSE)
    for layer_i, (count, far_dark) in enumerate(((240, 40), (200, 80), (160, 140))):
        zfac = (layer_i + 1) / 3.0
        for i in range(count):
            z = random.random() ** 1.7
            x = random.uniform(0, FW)
            y = FH + 60 - z * (FH + 120)
            length = 6 + z * 100 * (0.5 + zfac * 0.6)
            slant = 10 + z * (26 + zfac * 30)
            color = cols[i % 4] + (int(far_dark + 150 * z / zfac),)
            width = 1 if z < 0.4 else (2 if z < 0.7 else 3)
            d.line((x, y, x - slant, y - length), fill=color, width=width)
            if z > 0.42 and random.random() < 0.06:
                bx, by = x - slant, y
                splash_glow = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
                dg = ImageDraw.Draw(splash_glow)
                splash = random.choice((CYAN, ROSE, GREEN, BRIGHT))
                rr = random.uniform(5, 14)
                dg.ellipse((bx - rr, by - rr * 0.5, bx + rr, by + rr * 0.5), fill=splash + (90,))
                splash_glow = splash_glow.filter(ImageFilter.GaussianBlur(6))
                img.alpha_composite(splash_glow)
                d2 = ImageDraw.Draw(img)
                for _ in range(6):
                    ang = random.uniform(0, math.tau)
                    rl = random.uniform(3, 16)
                    ex = bx + math.cos(ang) * rl
                    ey = by + math.sin(ang) * rl * 0.35
                    d2.line((bx, by, ex, ey), fill=splash + (int(150 * z),), width=2)
                d2.ellipse((bx - 6, by - 4, bx + 6, by + 4), fill=BRIGHT + (170,))

    refl = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    dr = ImageDraw.Draw(refl)
    for i in range(150):
        x = random.uniform(0, FW)
        ry = FH - random.uniform(0.03, 0.2) * FH
        col_i = i % 4
        dr.line((x, ry, x, ry + random.uniform(20, 80)), fill=cols[col_i] + (30,), width=2)
    refl = refl.filter(ImageFilter.GaussianBlur(8))
    img.alpha_composite(refl)

    haze = img.filter(ImageFilter.GaussianBlur(1.4))
    img = ImageChops.add(haze, img)
    return img.convert('RGB')


def starfall_still():
    img = vgrad(BG, (13, 13, 17), FW, FH).convert('RGBA')
    cx, cy = FW / 2, FH / 2

    core = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    dc = ImageDraw.Draw(core)
    dc.ellipse((cx - 380, cy - 380, cx + 380, cy + 380), fill=ROSE + (90,))
    dc.ellipse((cx - 180, cy - 180, cx + 180, cy + 180), fill=PURPLE + (100,))
    dc.ellipse((cx - 70, cy - 70, cx + 70, cy + 70), fill=BRIGHT + (140,))
    core = core.filter(ImageFilter.GaussianBlur(50))
    img.alpha_composite(core)
    core2 = core.filter(ImageFilter.GaussianBlur(120))
    img.alpha_composite(ImageEnhance.Brightness(core2).enhance(2))

    flare = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    df = ImageDraw.Draw(flare)
    df.line((cx - 600, cy, cx + 600, cy), fill=CYAN + (60,), width=3)
    df.line((cx, cy - 400, cx, cy + 400), fill=YELLOW + (50,), width=3)
    flare = flare.filter(ImageFilter.GaussianBlur(30))
    img.alpha_composite(flare)

    d = ImageDraw.Draw(img)
    arm_cols = (CYAN, GREEN, PURPLE, ROSE)
    for arm in range(4):
        base_ang = arm * math.pi / 2 + 0.55
        anchor = arm_cols[arm]
        for _ in range(400):
            tdist = random.expovariate(0.55)
            rdist = 8 + tdist * 1500
            ang = base_ang + rdist * 0.0032
            x = cx + math.cos(ang) * rdist + random.uniform(-30, 30)
            y = cy + math.sin(ang) * rdist + random.uniform(-22, 22)
            if not (0 <= x <= FW and 0 <= y <= FH):
                continue
            near = 1.0 - min(1.0, rdist / 1500.0)
            size = 1 + int(7 * near) + random.randint(0, 1)
            lum = random.randint(110, 255)
            if random.random() < 0.5:
                col = anchor + (lum,)
            elif random.random() < 0.7:
                col = BRIGHT + (lum,)
            else:
                col = YELLOW + (lum,)
            d.ellipse((x - size, y - size, x + size, y + size), fill=col)

    dust = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    dd = ImageDraw.Draw(dust)
    for _ in range(700):
        x = random.uniform(0, FW)
        y = random.uniform(0, FH)
        dd.ellipse((x - 1, y - 1, x + 1, y + 1), fill=BRIGHT + (random.randint(18, 80),))
    img.alpha_composite(dust)
    img = img.filter(ImageFilter.GaussianBlur(0.8))
    return img.convert('RGB')


def render_anim(base, w, h, nframes, fps, draw_fn, out_webm):
    tmpdir = pathlib.Path(tempfile.mkdtemp(prefix='wally-anim-'))
    enc_res = subprocess.run(['ffmpeg', '-encoders'], capture_output=True, text=True).stdout
    encoder = 'libvpx-vp9' if 'libvpx-vp9' in enc_res else 'libx264'
    for i in range(nframes):
        t = i / fps
        frame = draw_fn(t, w, h)
        frame.save(tmpdir / f'f{i:04d}.png')
        if i % 40 == 0:
            print(f'{base}: frame {i}/{nframes}')
    cmd = ['ffmpeg', '-y', '-framerate', str(fps), '-i', str(tmpdir / 'f%04d.png'),
           '-c:v', encoder, '-b:v', '8M' if encoder == 'libvpx-vp9' else '12M',
           '-pix_fmt', 'yuv420p', os.path.join(OUT, out_webm)]
    subprocess.run(cmd, check=True, capture_output=True)
    shutil.rmtree(tmpdir)
    print('saved', out_webm)


def framer_aurora(t, w, h):
    img = vgrad(BG, (11, 11, 15), w, h).convert('RGBA')
    specs = [
        (CYAN, 0.30 + 0.03 * math.sin(t * 0.8), 0.10, 9.0, 0.0 + t * 0.6, 0.24, 130),
        (GREEN, 0.44 + 0.03 * math.sin(t * 0.9 + 1.7), 0.12, 6.5, 2.1 + t * 0.5, 0.30, 120),
        (PURPLE, 0.40 + 0.02 * math.sin(t * 1.1 + 4.0), 0.09, 11.0, 4.0 + t * 0.7, 0.20, 100),
        (ROSE, 0.54 + 0.02 * math.sin(t * 0.7 + 2.8), 0.07, 7.3, 1.2 + t * 0.4, 0.16, 90),
        (YELLOW, 0.22 + 0.02 * math.sin(t * 1.3 + 5.2), 0.05, 5.0, 3.0 + t * 0.8, 0.06, 50),
    ]
    for color, base, amp, freq, phase, thick, alpha in specs:
        layer = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        d = ImageDraw.Draw(layer)
        top = []
        bot = []
        for x in range(0, w + 6, 6):
            s = base + amp * math.sin(x / 520.0 * freq + phase) + amp * 0.5 * math.sin(x / 180.0 * freq * 1.7 + phase * 2.3)
            top.append((x, s * h))
            bot.append((x, (s + thick) * h))
        d.polygon(top + list(reversed(bot)), fill=color + (alpha,))
        for x, y in top:
            d.ellipse((x - 8, y - 8, x + 8, y + 8), fill=color + (30,))
        layer = layer.filter(ImageFilter.GaussianBlur(int(h * 0.014)))
        img.alpha_composite(layer)
        edge = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        de = ImageDraw.Draw(edge)
        de.line(top, fill=BRIGHT + (80,), width=2)
        edge = edge.filter(ImageFilter.GaussianBlur(2))
        img.alpha_composite(edge)

    stars = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    ds = ImageDraw.Draw(stars)
    random.seed(7)
    for _ in range(100):
        x = random.uniform(0, w)
        y = random.uniform(0, h * 0.8)
        tw = 0.6 + 0.4 * math.sin(t * 2.0 + x * 0.5)
        a = int(40 + 160 * tw)
        ds.ellipse((x - 1, y - 1, x + 1, y + 1), fill=BRIGHT + (a,))
    img.alpha_composite(stars)
    return img.convert('RGB')


def framer_starfall(t, w, h):
    img = vgrad((13, 13, 17), (8, 8, 12), w, h).convert('RGBA')
    cx, cy = w / 2 + math.sin(t) * 30, h / 2 + math.cos(t * 0.8) * 15

    core = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    dc = ImageDraw.Draw(core)
    rp = 160 + 20 * math.sin(t * 1.3)
    dc.ellipse((cx - rp, cy - rp, cx + rp, cy + rp), fill=ROSE + (80,))
    dc.ellipse((cx - 80, cy - 80, cx + 80, cy + 80), fill=PURPLE + (90,))
    dc.ellipse((cx - 35, cy - 35, cx + 35, cy + 35), fill=BRIGHT + (120,))
    core = core.filter(ImageFilter.GaussianBlur(30))
    img.alpha_composite(core)

    d = ImageDraw.Draw(img)
    arm_cols = (CYAN, GREEN, PURPLE, ROSE)
    base_rot = t * 0.55
    random.seed(11)
    stars_seed = [(random.uniform(0, w), random.uniform(0, h)) for _ in range(900)]
    for x0, y0 in stars_seed:
        dx = x0 - cx
        dy = y0 - cy
        r = math.hypot(dx, dy)
        ang = math.atan2(dy, dx) + base_rot * (1.0 / (1.0 + r / 800.0))
        x = cx + math.cos(ang) * r
        y = cy + math.sin(ang) * r
        if not (0 <= x <= w and 0 <= y <= h):
            continue
        if r > 40:
            arm = int((ang % (math.pi / 2)) * (4 / math.pi)) % 4
        else:
            arm = 0
        size = 1 + int(5 * (1 - min(1.0, r / 1500.0)))
        tw = 0.5 + 0.5 * math.sin(t * 2.5 + x * 0.004 + y * 0.003)
        lum = int(90 + 160 * tw)
        col = arm_cols[arm] + (lum,)
        d.ellipse((x - size, y - size, x + size, y + size), fill=col)

    dust = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    dd = ImageDraw.Draw(dust)
    random.seed(13)
    for _ in range(400):
        x = random.uniform(0, w)
        y = random.uniform(0, h)
        dd.ellipse((x - 1, y - 1, x + 1, y + 1), fill=BRIGHT + (random.randint(15, 60),))
    img.alpha_composite(dust)
    return img.convert('RGB')


def main():
    if len(sys.argv) > 1 and sys.argv[1] == 'anims':
        render_anim('aurora', 1920, 1080, 240, 24, framer_aurora, 'wally-01-aurora.webm')
        render_anim('starfall', 1920, 1080, 240, 24, framer_starfall, 'wally-02-starfall.webm')
        return
    random.seed(3)
    save(aurora_still(), 'wally-01-aurora.png')
    random.seed(3)
    save(starfall_still(), 'wally-02-starfall.png')
    random.seed(7)
    save(rain_still(), 'wally-03-rain.png')
    save(julia_still(), 'wally-04-juliatopo.png')
    save(plasma_still(), 'wally-05-plasma.png')
    save(caustic_still(), 'wally-06-caustic.png')
    save(mandel_still(), 'wally-07-mandelmelt.png')
    print('done stills')


if __name__ == '__main__':
    main()