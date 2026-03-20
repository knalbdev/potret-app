<div align="center">
  <img src="assets/images/logo.png" alt="Potret Logo" width="120"/>
  <p>A story-sharing app built with Flutter — Dicoding Flutter Intermediate Submission</p>
</div>

---

## Features

### Submission 1
- Authentication — register, login, logout with session persistence
- Story List — paginated infinite scroll with pull-to-refresh
- Story Detail — full photo, author, description
- Add Story — pick image from camera or gallery, write description
- Localization — English & Indonesian (persisted across sessions)
- Declarative Navigation — GoRouter (Navigation 2.0)

### Submission 2
- Maps — story detail shows location on Google Maps with address info
- Location Picker — pick location on map when adding a story (Paid only)
- Infinite Scroll Pagination — auto-load more stories on scroll
- Code Generation — all model classes use `json_serializable`
- Build Variant — Free and Paid flavor

---

## Build Variants

This app has two flavors:

| Flavor | Feature |
|--------|---------|
| **Free** | Cannot add location to story |
| **Paid** | Can pick location on map when adding a story |

### Run the app

```bash
# Free version
flutter run --flavor free -t lib/main_free.dart

# Paid version (includes location picker)
flutter run --flavor paid -t lib/main_paid.dart
```

### Build APK

```bash
# Free APK
flutter build apk --flavor free -t lib/main_free.dart

# Paid APK
flutter build apk --flavor paid -t lib/main_paid.dart
```

---

## Google Maps API Key Setup

This project uses Google Maps. The API key is stored in `android/local.properties` (excluded from version control for security).

Before running, make sure `android/local.properties` contains:

```
MAPS_API_KEY=your_google_maps_api_key_here
```

---

## Tech Stack

| Category | Library |
|----------|---------|
| State Management | Provider |
| Navigation | GoRouter (Navigator 2.0) |
| Network | http |
| Maps | google_maps_flutter |
| Geocoding | geocoding |
| Image Picker | image_picker |
| Storage | shared_preferences |
| Code Generation | json_serializable + build_runner |
| Fonts | Google Fonts (Poppins) |
| Localization | flutter_localizations + intl |

---

## Project Structure

```
lib/
├── data/
│   ├── api/          # API service
│   ├── model/        # Data models (@JsonSerializable)
│   └── preferences/  # Local storage
├── flavor/           # Build variant config
├── l10n/             # Localization (.arb files)
├── provider/         # State management
├── router/           # GoRouter configuration
├── screen/           # UI screens
│   ├── auth/
│   ├── map/
│   └── story/
└── utils/            # Helpers
```

---

## API

This app uses the [Dicoding Story API](https://story-api.dicoding.dev/v1/).

---

<div align="center">
  <p>Made with Flutter · Dicoding Indonesia</p>
</div>
