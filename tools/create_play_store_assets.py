from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
RAW_PT = ROOT / "docs" / "play-store" / "screenshots" / "raw"
RAW_EN = ROOT / "docs" / "play-store" / "screenshots" / "raw-en"
OUT_ROOT = ROOT / "docs" / "play-store" / "screenshots" / "final"

FONT_REGULAR = ROOT / "assets" / "fonts" / "Nunito" / "static" / "Nunito-Regular.ttf"
FONT_BOLD = ROOT / "assets" / "fonts" / "Nunito" / "static" / "Nunito-ExtraBold.ttf"
ICON = ROOT / "assets" / "images" / "logo_launcher.png"


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    width, height = size
    image = Image.new("RGB", size)
    pixels = image.load()
    for y in range(height):
        t = y / max(height - 1, 1)
        color = tuple(round(a + (b - a) * t) for a, b in zip(top, bottom))
        for x in range(width):
            pixels[x, y] = color
    return image


def fit_screenshot(path: Path, width: int, height: int, top_crop: int = 70) -> Image.Image:
    image = Image.open(path).convert("RGB")
    image = image.crop((4, top_crop, image.width - 4, image.height - 4))
    scale = width / image.width
    resized = image.resize((width, round(image.height * scale)), Image.Resampling.LANCZOS)
    if resized.height < height:
        padded = Image.new("RGB", (width, height), resized.getpixel((0, 0)))
        padded.paste(resized, (0, 0))
        return padded
    return resized.crop((0, 0, width, height))


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    return mask


def create_store_shot(
    raw_dir: Path,
    out_dir: Path,
    source: str,
    output: str,
    title: str,
    subtitle: str,
    dark_frame: bool = False,
) -> None:
    canvas = gradient((1080, 1920), (24, 55, 91), (14, 29, 52))
    draw = ImageDraw.Draw(canvas)

    draw.ellipse((720, -120, 1190, 350), outline=(27, 210, 197), width=3)
    draw.ellipse((770, -70, 1140, 300), outline=(54, 120, 180), width=2)
    draw.rounded_rectangle((56, 52, 220, 116), radius=32, fill=(35, 78, 116))
    draw.text((88, 67), "TIMING", font=font(FONT_BOLD, 28), fill=(111, 238, 227))

    title_size = 62
    title_font = font(FONT_BOLD, title_size)
    while draw.textbbox((0, 0), title, font=title_font)[2] > 968:
        title_size -= 2
        title_font = font(FONT_BOLD, title_size)
    draw.text((56, 145), title, font=title_font, fill="white")
    draw.text((58, 225), subtitle, font=font(FONT_REGULAR, 34), fill=(211, 225, 239))

    frame_box = (70, 320, 1010, 1870)
    frame_color = (11, 21, 38) if dark_frame else (244, 247, 250)
    draw.rounded_rectangle(frame_box, radius=70, fill=frame_color, outline=(91, 183, 244), width=4)

    shot = fit_screenshot(raw_dir / source, 880, 1490)
    mask = rounded_mask(shot.size, 45)
    canvas.paste(shot, (100, 350), mask)

    out_dir.mkdir(parents=True, exist_ok=True)
    canvas.save(out_dir / output, format="PNG", optimize=True)


def create_english_feature_graphic() -> None:
    canvas = gradient((1024, 500), (27, 54, 84), (16, 34, 60))
    draw = ImageDraw.Draw(canvas)
    draw.ellipse((585, 18, 1045, 478), outline=(28, 82, 105), width=2)
    draw.ellipse((610, 48, 1015, 453), outline=(31, 68, 101), width=2)
    draw.rounded_rectangle((74, 108, 82, 313), radius=4, fill=(18, 213, 198))
    draw.text((110, 126), "Timing", font=font(FONT_BOLD, 88), fill="white")
    draw.text((114, 248), "Your time. Your progress.", font=font(FONT_REGULAR, 34), fill=(218, 229, 239))
    draw.rounded_rectangle((114, 350, 525, 404), radius=27, fill=(36, 77, 96))
    draw.text((141, 364), "FOCUS  •  ROUTINE  •  GOALS", font=font(FONT_BOLD, 20), fill=(108, 237, 226))

    icon = Image.open(ICON).convert("RGB").resize((352, 352), Image.Resampling.LANCZOS)
    canvas.paste(icon, (640, 74), rounded_mask(icon.size, 82))
    canvas.save(ROOT / "docs" / "play-store" / "feature-graphic-en-US-1024x500.png", format="PNG", optimize=True)


def main() -> None:
    pt_specs = [
        ("timer.png", "01-foco-sem-distracoes.png", "Foco sem distrações", "Cronômetro, pausas e notas no mesmo fluxo", True),
        ("daily-goals.png", "02-metas-que-viram-rotina.png", "Metas que viram rotina", "Planeje o dia com objetivos simples", False),
        ("create-group-step.png", "03-progresso-em-grupo.png", "Progresso em grupo", "Crie desafios e evolua com amigos", False),
        ("progress.png", "04-veja-sua-evolucao.png", "Veja sua evolução", "Acompanhe foco, sessões e conquistas", False),
        ("schedule.png", "05-planeje-sua-agenda.png", "Planeje sua agenda", "Organize compromissos e sua rotina semanal", False),
    ]
    en_specs = [
        ("timer.png", "01-distraction-free-focus.png", "Distraction-free focus", "Timer, breaks, and notes in one seamless flow", True),
        ("daily-goals.png", "02-goals-that-build-routines.png", "Goals that build routines", "Plan your day with clear, achievable goals", False),
        ("create-group-step.png", "03-progress-together.png", "Progress together", "Create challenges and grow with friends", False),
        ("progress.png", "04-see-your-progress.png", "See your progress", "Track focus, sessions, and achievements", False),
        ("schedule.png", "05-plan-your-schedule.png", "Plan your schedule", "Organize appointments and your weekly routine", False),
    ]
    for source, output, title, subtitle, dark_frame in pt_specs:
        create_store_shot(RAW_PT, OUT_ROOT / "pt-BR", source, output, title, subtitle, dark_frame)
    for source, output, title, subtitle, dark_frame in en_specs:
        create_store_shot(RAW_EN, OUT_ROOT / "en-US", source, output, title, subtitle, dark_frame)

    app_icon = Image.open(ICON).convert("RGB").resize((512, 512), Image.Resampling.LANCZOS)
    app_icon.save(ROOT / "docs" / "play-store" / "app-icon-512.png", format="PNG", optimize=True)
    create_english_feature_graphic()


if __name__ == "__main__":
    main()
