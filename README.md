# Trek Diary

An offline-first trekking journal built with Flutter. Log treks, record daily stops with elevation and mood data, write diary entries with photos, and visualise your route — all stored locally on device with no backend required.

---

## Tech Stack

| Layer | Library | Version |
|---|---|---|
| UI framework | Flutter | SDK ≥ 3.3 |
| State management | flutter_riverpod | ^2.5.1 |
| Navigation | go_router | ^13.2.0 |
| Local persistence | shared_preferences | ^2.2.3 |
| Image loading | cached_network_image | ^3.3.1 |
| Fonts | google_fonts (Poppins) | ^6.2.1 |

All data is serialised to JSON and stored in SharedPreferences under the key `trekdiary_treks`. There is no remote database, authentication server, or API.

---

## Features

- **Auth flow** — landing screen → email + name → optional 4-digit PIN. Guest mode available. Auth state persisted via SharedPreferences. X button on landing is session-only (does not persist).
- **Home dashboard** — Pangea-style trek cards (photo hero + dark info panel), live stats row, active trek spotlight, empty state.
- **Create trek** — name, region, description, day count stepper, difficulty chip picker.
- **Edit trek** — update all fields including a custom cover photo URL (paste any direct image link).
- **Trek detail** — expandable day cards, stop list per day, glass chip actions (Edit / Path / Summary).
- **Add stop** — name, elevation (m), distance (km), weather chip, mood chip, notes.
- **Stop detail** — TIDE editorial layout: giant elevation number on full-bleed photo, quote-style notes, weather/mood chips.
- **Diary entry** — per-day journal text + unlimited image cards (URL + caption), persisted to the day model.
- **Trek path** — visual zigzag route with cubic bezier connectors; nodes coloured by state (logged / current / locked).
- **Summary** — aggregated stats (max elevation, elevation gain, total distance, stops), per-day breakdown, mark-complete action.
- **Settings** — data stats, clear all, sign out.

---

## Project Structure

```
lib/
├── app.dart                          # MaterialApp.router root
├── main.dart                         # Entry point; SharedPreferences init
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Full dark-theme colour palette
│   │   ├── app_text_styles.dart      # Poppins type scale (display → label)
│   │   ├── app_constants.dart        # Storage keys, option lists, photo URLs
│   │   └── app_durations.dart        # Animation duration constants
│   ├── router/
│   │   └── app_router.dart           # GoRouter config + auth redirect guard
│   ├── theme/
│   │   └── app_theme.dart            # ThemeData (dark); AppTheme.dark / .light
│   └── utils/
│       └── id_generator.dart
│
├── data/
│   ├── models/
│   │   ├── trek.dart                 # Trek — id, name, region, difficulty, coverImageUrl, days[]
│   │   ├── day.dart                  # TrekDay — dayNum, title, stops[], diary?
│   │   ├── stop.dart                 # TrekStop — elevation, distance, weather, mood, notes, photos[]
│   │   └── diary_entry.dart          # DiaryEntry — text, images[]; DiaryImage — url, caption
│   ├── providers/
│   │   └── auth_provider.dart        # AuthState, AuthNotifier, authFormProvider, sessionGuestProvider
│   └── repositories/
│       └── trek_repository.dart      # TrekRepository (CRUD) + TrekListNotifier + derived providers
│
├── features/
│   ├── auth/screens/                 # auth_landing, auth_email, auth_pin
│   ├── home/
│   │   ├── screens/home_screen.dart  # Split into 5 Consumer sub-widgets (minimal rebuild scope)
│   │   └── widgets/trek_card.dart    # Pangea-style card
│   ├── create_trek/screens/
│   ├── edit_trek/screens/            # Edit name, region, difficulty, cover image URL
│   ├── trek_detail/screens/          # Expandable day cards with diary + stop buttons
│   ├── add_stop/screens/
│   ├── stop_detail/screens/
│   ├── diary/screens/                # Per-day journal text + photo URL/caption entries
│   ├── trek_path/screens/            # Zigzag path painter
│   ├── summary/screens/
│   └── settings/screens/
│
└── shared/
    └── widgets/
        ├── glass.dart                # GlassCard, GlassButton, GlassBackButton, PillButton, GlassTabBar
        ├── primary_button.dart       # PrimaryButton (accent / danger / disabled)
        ├── stat_card.dart            # Horizontal stat row with dividers
        ├── chip_picker.dart          # Horizontal wrapping chip selector
        ├── diff_badge.dart           # Colour-coded difficulty pill
        ├── photo_hero_header.dart
        ├── photo_grid.dart
        └── stop_timeline.dart
```

---

## Routes

| Path | Screen | Auth required |
|---|---|---|
| `/auth` | AuthLandingScreen | No |
| `/auth/email` | AuthEmailScreen | No |
| `/auth/pin` | AuthPinScreen | No |
| `/` | HomeScreen | Yes |
| `/create` | CreateTrekScreen | Yes |
| `/trek/:id` | TrekDetailScreen | Yes |
| `/trek/:id/edit` | EditTrekScreen | Yes |
| `/trek/:id/add-stop/:dayNum` | AddStopScreen | Yes |
| `/trek/:id/stop/:dayNum/:stopId` | StopDetailScreen | Yes |
| `/trek/:id/diary/:dayNum` | DiaryEntryScreen | Yes |
| `/trek/:id/path` | TrekPathScreen | Yes |
| `/trek/:id/summary` | SummaryScreen | Yes |
| `/settings` | SettingsScreen | Yes |

GoRouter redirects all unauthenticated requests to `/auth`, and redirects `/auth/*` to `/` when already logged in. The redirect logic lives in `app_router.dart` and listens to both `authProvider` and `sessionGuestProvider`.

---

## Data Models

### Trek
```dart
Trek {
  id, name, region, difficulty,
  totalDays,
  coverImageUrl?,      // user-set URL; overrides auto-assigned nature photo
  description, createdAt, completed,
  days: List<TrekDay>
}
```

### TrekDay
```dart
TrekDay {
  dayNum, title,
  stops: List<TrekStop>,
  diary: DiaryEntry?   // null = no entry written yet
}
```

### TrekStop
```dart
TrekStop {
  id, name,
  elevation (int, metres),
  distance (double, km),
  weather, mood, notes,
  photos: List<String> // reserved; not yet used in UI
}
```

### DiaryEntry / DiaryImage
```dart
DiaryEntry { text: String, images: List<DiaryImage> }
DiaryImage { url: String, caption: String }
```

All models implement `fromJson` / `toJson` and `copyWith`. Persistence is manual — no code generation is used despite `freezed` and `json_serializable` being in pubspec (they are unused; can be removed or adopted in future).

---

## State Management

Riverpod is used throughout. Key providers:

| Provider | Type | Purpose |
|---|---|---|
| `sharedPrefsProvider` | `Provider<SharedPreferences>` | Injected at root via `overrideWithValue` in `main.dart` |
| `trekListProvider` | `StateNotifierProvider<TrekListNotifier, List<Trek>>` | Single source of truth for all trek data |
| `trekCountProvider` | `Provider<int>` | Derived — only rebuilds on count change |
| `totalStopsProvider` | `Provider<int>` | Derived |
| `completedCountProvider` | `Provider<int>` | Derived |
| `activeTrekProvider` | `Provider<Trek?>` | First non-completed trek (home spotlight) |
| `authProvider` | `StateNotifierProvider<AuthNotifier, AuthState>` | Login state + SharedPreferences persistence |
| `authFormProvider` | `StateProvider<({String name, String email})?>` | Passes data from email screen → pin screen |
| `sessionGuestProvider` | `StateProvider<bool>` | Session-only guest bypass (not written to disk) |

`HomeScreen` is split into 5 separate `ConsumerWidget` sub-widgets so the hero photo and tab bar never rebuild when trek data changes.

---

## Design System

The app uses a TIDE iOS-inspired dark design system. All values are in `app_colors.dart` and `app_text_styles.dart`.

### Colour Palette
```
heroDark    #0D1A0D   scaffold background, photo fallback
sheet       #1A1F1C   main content sheet (dark charcoal)
surface     #252B28   cards, inputs
surfaceDim  #1E2420   dimmer variant (disabled states)
border      #3A4240   field and card borders
borderLight #2E3530   dividers

accent      #5B8A6E   sage green — buttons, active states, logged nodes
accentLight #7EC8A0   lighter sage — progress bars, diary highlights

textPrimary   #FFFFFF
textSecondary #8A9590  subtitles, descriptions
textMuted     #6A7570  body small, labels
textHint      #5A6560  placeholders, eyebrow labels
```

### Typography — Poppins weight conventions
| Weight | Usage |
|---|---|
| w100 / w200 | Ultra-thin editorial numbers (day "01", elevation "3048 m") |
| w300 | Hero headings on dark photo backgrounds |
| w400 | Body text, input values |
| w500 / w600 | Secondary labels, chip text |
| w700 / w800 | Card titles, screen headings, button labels |

### Key Shared Widgets
| Widget | File | Notes |
|---|---|---|
| `GlassBackButton` | `glass.dart` | Frosted circular chevron for photo headers |
| `GlassButton` | `glass.dart` | Small frosted action chip (Edit, Path, Summary) |
| `GlassTabBar` | `glass.dart` | Dark pill tab bar (`#F0252B28`) |
| `PillButton` | `glass.dart` | White solid (primary) or dark glass (secondary) full-width pill |
| `PrimaryButton` | `primary_button.dart` | Accent / danger / disabled rounded button |
| `ChipPicker` | `chip_picker.dart` | Wrapping chip row for single-select options |
| `DiffBadge` | `diff_badge.dart` | Colour-coded difficulty label |
| `StatCard` | `stat_card.dart` | Horizontal stat row with dividers |

---

## Running Locally

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web, hot-reload enabled)
flutter run -d chrome --web-port 8080

# Run on connected Android / iOS device
flutter run

# Production web build
flutter build web
```

Requires Flutter SDK ≥ 3.3.0. On first launch, two sample treks ("Valley of Flowers" and "Hampta Pass") are pre-loaded automatically.

> **Temporary:** `main.dart` contains `await prefs.remove('td_logged_in')` to clear a previously stuck guest-auth state. Remove this line once you have confirmed the auth screens are working correctly in your environment.

---

## Agent / Contributor Notes

**Adding a new screen**
1. Create `lib/features/<name>/screens/<name>_screen.dart`
2. Add a `GoRoute` entry in `lib/core/router/app_router.dart`
3. Import the screen file at the top of `app_router.dart`

**Adding a new data field**
1. Update the model class (`copyWith`, `fromJson`, `toJson`)
2. Update any `_sampleTreks` entries in `trek_repository.dart` if needed
3. If it requires a new repository method, add it to `TrekRepository` and `TrekListNotifier`

**Theming rules**
- Never hardcode colour values in widget files — always use `AppColors.*`
- Never hardcode font sizes or weights inline — prefer `AppTextStyles.*` or `.copyWith()`

**Riverpod rules**
- Use `ref.watch` inside `build` methods only
- Use `ref.read` inside callbacks and event handlers
- Never call `setState` on data that is managed by a Riverpod provider

**Navigation rules**
- `context.push()` — drill-down (adds to stack, back button works)
- `context.pop()` — return to previous screen
- `context.pushReplacement()` — replace current screen (used after form submit so form is not in back stack)
- `context.go()` — top-level tab switches only
- Never use `Navigator.push` / `Navigator.pop` — all navigation goes through GoRouter

**Cover photos**
`Trek.coverImageUrl` takes precedence over the deterministic `getTrekPhotoUrl(trek)` hash-based fallback. Any publicly accessible direct image URL works.

**Diary images**
Stored as `DiaryImage(url, caption)` inside `DiaryEntry.images`. Loaded via `CachedNetworkImage` — must be publicly accessible direct image URLs (not page URLs).
