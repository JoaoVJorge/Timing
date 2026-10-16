# Google Play artwork

The localized store artwork uses real Flutter screens captured on a medium-size phone simulator with deterministic, privacy-safe demo data. It intentionally uses generic Mathematics, Chemistry, exercise, reading, and study examples instead of a real account. The pale marketing background and phone frame are added around the capture; the app UI is not reconstructed.

## Capture and generate

Run the capture-only entrypoint on a disposable simulator for each locale:

```sh
flutter run -d <simulator-id> -t tools/play_store_capture_main.dart --dart-define=STORE_LOCALE=pt-BR
flutter run -d <simulator-id> -t tools/play_store_capture_main.dart --dart-define=STORE_LOCALE=en-US
```

The console prints `STORE_CAPTURE_SAVED` with each absolute PNG path. Copy the PNGs into `screenshots/captures/pt-BR/` and `screenshots/captures/en-US/` respectively. Copy each locale before rebuilding for the other locale, since a simulator reinstall can replace its app container. The capture entrypoint uses local guest data and does not modify the production launch flow.

Run the asset generator with a Python environment that includes Pillow:

```sh
python3 tools/create_play_store_assets.py
```

Outputs:

- `screenshots/final/pt-BR/`: seven Portuguese screenshots at 1080 × 1920.
- `screenshots/final/en-US/`: seven English screenshots at 1080 × 1920.
- `screenshots/final/contact-sheet-*.jpg`: compact visual review sheets.
- `feature-graphic-*-1024x500.png`: localized feature graphics.
- `app-icon-512.png`: store icon export.

`marketing-background.png` is the shared, predominantly white background used by every localized asset. The phone viewport preserves the captured 1179 × 2556 aspect ratio (about 9:19.5) without stretching or redrawing the interface. Keep the two language sets structurally identical so screenshots can be updated and reviewed together. The calendar capture is retained as a source but is not part of the final seven-image set.
