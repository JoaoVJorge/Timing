"""Frame actual localized Flutter captures for the Google Play listing.

The app UI is never redrawn here. Re-capture it with
``tools/play_store_capture_main.dart`` before regenerating these assets.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
STORE = ROOT / "docs" / "play-store"
CAPTURES = STORE / "screenshots" / "captures"
OUT = STORE / "screenshots" / "final"
BACKGROUND = STORE / "marketing-background.png"
REGULAR = ROOT / "assets/fonts/Nunito/static/Nunito-Regular.ttf"
SEMIBOLD = ROOT / "assets/fonts/Nunito/static/Nunito-SemiBold.ttf"
BOLD = ROOT / "assets/fonts/Nunito/static/Nunito-ExtraBold.ttf"
ICON = ROOT / "assets/images/logo_launcher.png"

INK = (43, 52, 67)
MUTED = (88, 102, 117)
TEAL = (28, 172, 185)
WHITE = (255, 255, 255)

COPY = {
    "pt-BR": {
        "slides": [
            ("home", "Tudo em um só lugar", "Estudos, exercícios e leitura no seu ritmo", "01-tudo-em-um-so-lugar.png"),
            ("subjects", "Estude com clareza", "Matemática e Química com metas visíveis", "02-estude-com-clareza.png"),
            ("reading", "Sua leitura evolui", "Acompanhe páginas e tempo de leitura", "03-sua-leitura-evolui.png"),
            ("goals", "Metas para hoje", "Exercícios, leitura e estudos viram rotina", "04-metas-para-hoje.png"),
            ("timer", "Foco em cada minuto", "Um cronômetro simples para a próxima sessão", "05-foco-em-cada-minuto.png"),
            ("progress", "Veja o que você fez", "Tempo, sessões e progresso em um só lugar", "06-veja-seu-progresso.png"),
            ("achievements", "Cada conquista conta", "Reconheça sua constância todos os dias", "07-cada-conquista-conta.png"),
        ],
        "feature": "Seu tempo. Seu progresso.",
        "badges": "FOCO  •  ESTUDOS  •  METAS",
    },
    "en-US": {
        "slides": [
            ("home", "Everything in one place", "Study, exercise, and reading at your pace", "01-everything-in-one-place.png"),
            ("subjects", "Study with clarity", "Visible goals for Mathematics and Chemistry", "02-study-with-clarity.png"),
            ("reading", "Make reading progress", "Track pages and time spent reading", "03-make-reading-progress.png"),
            ("goals", "Goals for today", "Make exercise, reading, and study a routine", "04-goals-for-today.png"),
            ("timer", "Focus on every minute", "A simple timer for your next session", "05-focus-on-every-minute.png"),
            ("progress", "See how far you have come", "Time, sessions, and progress in one place", "06-see-your-progress.png"),
            ("achievements", "Every achievement counts", "Celebrate consistency every day", "07-every-achievement-counts.png"),
        ],
        "feature": "Your time. Your progress.",
        "badges": "FOCUS  •  STUDY  •  GOALS",
    },
}


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def fit_text(draw: ImageDraw.ImageDraw, value: str, path: Path, size: int, width: int) -> ImageFont.FreeTypeFont:
    while size > 22 and draw.textlength(value, font=font(path, size)) > width:
        size -= 2
    return font(path, size)


def centered(draw: ImageDraw.ImageDraw, bounds: tuple[int, int, int, int], value: str, face: ImageFont.FreeTypeFont, fill: tuple[int, int, int]) -> None:
    bbox = draw.textbbox((0, 0), value, font=face)
    x = bounds[0] + (bounds[2] - bounds[0] - (bbox[2] - bbox[0])) / 2
    y = bounds[1] + (bounds[3] - bounds[1] - (bbox[3] - bbox[1])) / 2 - bbox[1]
    draw.text((x, y), value, font=face, fill=fill)


def cover(path: Path, size: tuple[int, int]) -> Image.Image:
    source = Image.open(path).convert("RGB")
    scale = max(size[0] / source.width, size[1] / source.height)
    source = source.resize((round(source.width * scale), round(source.height * scale)), Image.Resampling.LANCZOS)
    x, y = (source.width - size[0]) // 2, (source.height - size[1]) // 2
    return source.crop((x, y, x + size[0], y + size[1]))


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def marketing_canvas(title: str, subtitle: str, index: int) -> Image.Image:
    canvas = cover(BACKGROUND, (1080, 1920))
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((56, 50, 232, 114), radius=32, fill=(226, 249, 246), outline=(173, 232, 225), width=2)
    draw.ellipse((76, 67, 105, 96), fill=TEAL)
    draw.ellipse((84, 75, 97, 88), fill=WHITE)
    draw.text((119, 67), "TIMING", font=font(BOLD, 27), fill=(20, 113, 105))
    draw.rounded_rectangle((888, 56, 1024, 108), radius=26, fill=WHITE, outline=(208, 223, 229), width=2)
    centered(draw, (888, 56, 1024, 108), f"{index}/7", font(SEMIBOLD, 22), MUTED)
    draw.text((56, 158), title, font=fit_text(draw, title, BOLD, 66, 968), fill=INK)
    draw.text((58, 261), subtitle, font=fit_text(draw, subtitle, REGULAR, 31, 964), fill=MUTED)
    return canvas


def add_actual_screen(canvas: Image.Image, source_path: Path) -> None:
    source = Image.open(source_path).convert("RGB")
    if source.size != (1179, 2556):
        raise ValueError(f"Unexpected capture size {source.size}: {source_path}")

    # Match the captured viewport ratio exactly: no stretched UI or invented
    # cards, graphs, controls, and navigation.
    screen_size = (652, round(652 * source.height / source.width))
    screen = source.resize(screen_size, Image.Resampling.LANCZOS)
    x, y = (1080 - screen.width) // 2, 454
    shadow = Image.new("RGBA", canvas.size)
    ImageDraw.Draw(shadow).rounded_rectangle((x - 28, y - 27, x + screen.width + 28, y + screen.height + 29), radius=68, fill=(71, 99, 118, 57))
    shadow = shadow.filter(ImageFilter.GaussianBlur(27))
    canvas.paste(shadow, (0, 0), shadow)
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((x - 25, y - 25, x + screen.width + 25, y + screen.height + 25), radius=63, fill=(232, 237, 242), outline=WHITE, width=5)
    canvas.paste(screen, (x, y), rounded_mask(screen_size, 43))


def feature_graphic(locale: str) -> Path:
    canvas = cover(BACKGROUND, (1024, 500))
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((58, 70, 69, 428), radius=6, fill=TEAL)
    draw.text((104, 87), "Timing", font=font(BOLD, 84), fill=INK)
    draw.text((108, 213), COPY[locale]["feature"], font=fit_text(draw, COPY[locale]["feature"], REGULAR, 35, 505), fill=MUTED)
    draw.rounded_rectangle((108, 320, 532, 382), radius=31, fill=(226, 249, 246), outline=(165, 229, 222), width=2)
    centered(draw, (108, 320, 532, 382), COPY[locale]["badges"], font(BOLD, 21), (23, 124, 115))
    icon = Image.open(ICON).convert("RGB").resize((330, 330), Image.Resampling.LANCZOS)
    canvas.paste(icon, (635, 84), rounded_mask(icon.size, 82))
    path = STORE / f"feature-graphic-{locale}-1024x500.png"
    canvas.save(path, optimize=True)
    return path


def main() -> None:
    generated: list[Path] = []
    for locale, copy in COPY.items():
        paths: list[Path] = []
        locale_dir = OUT / locale
        locale_dir.mkdir(parents=True, exist_ok=True)
        for index, (page, title, subtitle, filename) in enumerate(copy["slides"], 1):
            source = CAPTURES / locale / f"{locale}-{page}.png"
            if not source.exists():
                raise FileNotFoundError(f"Capture missing: {source}")
            canvas = marketing_canvas(title, subtitle, index)
            add_actual_screen(canvas, source)
            path = locale_dir / filename
            canvas.save(path, optimize=True)
            generated.append(path)
            paths.append(path)

        sheet = Image.new("RGB", (1080, 960), WHITE)
        for index, path in enumerate(paths):
            preview = Image.open(path).resize((270, 480), Image.Resampling.LANCZOS)
            sheet.paste(preview, ((index % 4) * 270, (index // 4) * 480))
        sheet_path = OUT / f"contact-sheet-{locale}.jpg"
        sheet.save(sheet_path, quality=90)
        generated.extend((sheet_path, feature_graphic(locale)))

    icon = Image.open(ICON).convert("RGB").resize((512, 512), Image.Resampling.LANCZOS)
    icon_path = STORE / "app-icon-512.png"
    icon.save(icon_path, optimize=True)
    generated.append(icon_path)
    print("\n".join(str(path.relative_to(ROOT)) for path in generated))


if __name__ == "__main__":
    main()
