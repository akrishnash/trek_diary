# Trek Diary

A beautifully designed offline-first trekking journal built with Flutter. Inspired by the TIDE design language — full-bleed dark photography, ultra-thin Poppins typography, and frosted glass surfaces. Log treks, record daily stops with elevation and mood data, write diary entries with photos, and visualise your route — all stored locally on device.

---

## Features

### Authentication
- **Google Sign-In** — OAuth via Firebase, account picker on first tap
- **Phone + OTP** — Enter your number, receive a 6-digit code, verify
- **Email Sign-In** — Name + email → set a 4-digit PIN
- **Continue as Guest** — Session-only access, no account needed (X button on landing, not persisted)
- **Profile Setup** — After any sign-in, prompted for name, age, and experience level

### Trek Management
- **Create treks** — Name, region, difficulty, description, number of days
- **Edit treks** — Update all details including cover photo URL
- **Cover photo** — Set a custom image URL per trek; falls back to a region-matched Unsplash photo
- **Trek cards** — Pangea-style cards with gradient overlays, difficulty badges, and stop counts
- **Trek detail** — Day-by-day breakdown, stops timeline, stats

### Stops & Days
- **Add stops** — Name, coordinates, elevation, notes per stop
- **Stop detail** — TIDE editorial layout: giant elevation number on full-bleed photo, weather/mood chips
- **Trek path** — Visual zigzag route with cubic bezier connectors; nodes coloured by state (logged / current / locked)
- **Trek summary** — Aggregate stats: total days, stops, distance

### Diary
- **Rich text editor** — Format text with H1, H2, bold, italic, and bullet points via a sticky formatting toolbar
- **Trek photo background** — The diary screen uses the trek's cover photo as a full-bleed background
- **Photo picker** — Upload photos directly from your device gallery; displayed as a 2-column grid
- **Markdown syntax** — Formatting stored as markdown (`**bold**`, `_italic_`, `# Heading`)
- **Auto-save indicator** — Green "Save" pill when unsaved, greyed "Saved" when synced

### Profile
- **View & edit profile** — Full name, username, age, bio, email, phone, location
- **Experience level** — Beginner / Intermediate / Expert chip selector
- **Persisted locally** — All fields saved to SharedPreferences
- **Avatar** — Initials-based circular avatar with green gradient

### Settings
- **Data stats** — Trek and stop counts
- **Clear all data** — Confirmation dialog before wiping
- **Sign out** — Clears auth state and returns to landing screen

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart 3.x) |
| State Management | Riverpod 2.x (`StateNotifierProvider`, `Provider`) |
| Navigation | GoRouter 13.x with auth redirect guards |
| Local Storage | SharedPreferences |
| Auth | Firebase Auth, Google Sign-In, Phone OTP |
| Images | cached\_network\_image, image\_picker |
| Fonts | Google Fonts — Poppins, Source Code Pro |

---

## Project Structure

```
lib/
├── app.dart                          # MaterialApp.router root + theme
├── main.dart                         # Entry point; Firebase + SharedPreferences init
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Full dark-theme colour palette
│   │   ├── app_text_styles.dart      # TIDE-inspired Poppins type scale
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
│   │   └── diary_entry.dart          # DiaryEntry + DiaryImage (url + localPath + caption)
│   ├── providers/
│   │   └── auth_provider.dart        # AuthState, AuthNotifier, authFormProvider, sessionGuestProvider
│   └── repositories/
│       └── trek_repository.dart      # TrekRepository (CRUD) + TrekListNotifier + derived providers
│
├── features/
│   ├── auth/screens/
│   │   ├── auth_landing_screen.dart  # Google, Phone, Email, Guest options
│   │   ├── auth_email_screen.dart
│   │   ├── auth_pin_screen.dart
│   │   ├── auth_phone_screen.dart
│   │   ├── auth_otp_screen.dart      # 6-cell OTP + numpad + resend countdown
│   │   └── auth_profile_screen.dart  # Name, age, experience level
│   ├── home/
│   │   ├── screens/home_screen.dart  # SliverAppBar with parallax, ConsumerWidget sub-widgets
│   │   └── widgets/trek_card.dart    # Pangea-style card (photo hero + dark info panel)
│   ├── create_trek/screens/
│   ├── edit_trek/screens/            # Edit name, region, difficulty, cover image URL
│   ├── trek_detail/screens/          # Expandable day cards with diary + stop buttons
│   ├── add_stop/screens/
│   ├── stop_detail/screens/
│   ├── diary/screens/
│   │   └── diary_entry_screen.dart   # Rich text editor with formatting toolbar + image_picker
│   ├── trek_path/screens/            # Zigzag path painter
│   ├── summary/screens/
│   ├── profile/screens/
│   │   └── profile_screen.dart       # Editable profile with photo background
│   └── settings/screens/
│
└── shared/widgets/
    ├── glass.dart                    # GlassBackButton, GlassButton, GlassTabBar, PillButton
    ├── primary_button.dart           # PrimaryButton (accent / danger / disabled)
    ├── stat_card.dart                # Horizontal stat row with dividers
    ├── chip_picker.dart              # Wrapping chip row for single-select options
    ├── diff_badge.dart               # Colour-coded difficulty pill
    ├── photo_hero_header.dart
    ├── photo_grid.dart
    └── stop_timeline.dart
```

---

## Setup

### Prerequisites

- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`
- Android Studio or Xcode (for device builds)
- A Firebase project with Authentication enabled

### 1. Clone the repo

```bash
git clone https://github.com/akrishnash/trek_diary.git
cd trek_diary
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase setup

This app uses Firebase Authentication for Google Sign-In and Phone OTP.

**Create a Firebase project:**
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a project → enable **Google** and **Phone** sign-in under Authentication → Sign-in method

**Register your Android app:**
```bash
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android
```

This generates `lib/firebase_options.dart` and downloads `android/app/google-services.json`.

**Add SHA-1 fingerprint (required for Google Sign-In on Android):**
```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android
```
Copy the SHA-1 value → Firebase Console → Project Settings → Your Android app → Add fingerprint → re-download `google-services.json`.

**Configure OAuth consent screen:**
1. Go to [console.cloud.google.com](https://console.cloud.google.com) → APIs & Services → OAuth consent screen
2. Set up as External, fill in app name and email → Save

### 4. Run

```bash
flutter run
```

> **Note:** `main.dart` contains `await prefs.remove('td_logged_in')` to clear a previously stuck guest-auth state. Remove this line once you have confirmed the auth screens are working correctly in your environment.

---

## Routes

| Path | Screen | Auth required |
|---|---|---|
| `/auth` | AuthLandingScreen | No |
| `/auth/email` | AuthEmailScreen | No |
| `/auth/pin` | AuthPinScreen | No |
| `/auth/phone` | AuthPhoneScreen | No |
| `/auth/otp` | AuthOtpScreen | No |
| `/auth/profile` | AuthProfileScreen | No (post-sign-in setup) |
| `/` | HomeScreen | Yes |
| `/create` | CreateTrekScreen | Yes |
| `/trek/:id` | TrekDetailScreen | Yes |
| `/trek/:id/edit` | EditTrekScreen | Yes |
| `/trek/:id/add-stop/:dayNum` | AddStopScreen | Yes |
| `/trek/:id/stop/:dayNum/:stopId` | StopDetailScreen | Yes |
| `/trek/:id/diary/:dayNum` | DiaryEntryScreen | Yes |
| `/trek/:id/path` | TrekPathScreen | Yes |
| `/trek/:id/summary` | SummaryScreen | Yes |
| `/profile` | ProfileScreen | Yes |
| `/settings` | SettingsScreen | Yes |

GoRouter redirect logic (in `app_router.dart`, listens to `authProvider` + `sessionGuestProvider`):
- Unauthenticated → `/auth`
- Authenticated but profile incomplete → `/auth/profile`
- Authenticated + profile complete + at auth route → `/`

---

## Auth Flow

```
Landing Screen
├── Continue with Google  →  Profile Setup  →  Home
├── Continue with Phone   →  OTP Screen  →  Profile Setup  →  Home
├── Continue with Email   →  PIN Screen  →  Home
└── Continue as Guest     →  Home (session only, not persisted to disk)
```

The X button on the landing screen sets `sessionGuestProvider` (RAM only) — it does **not** write to SharedPreferences, so the sign-in screen reappears on next app launch.

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
  photos: List<String>
}
```

### DiaryEntry / DiaryImage
```dart
DiaryEntry { text: String, images: List<DiaryImage> }
DiaryImage { url: String, localPath: String, caption: String }
// localPath: device gallery path (image_picker); url: network URL fallback
// hasContent = url.isNotEmpty || localPath.isNotEmpty
// displayPath = localPath.isNotEmpty ? localPath : url
```

All models implement `fromJson` / `toJson` and `copyWith`. Persistence is manual — no code generation is used.

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
| `authFormProvider` | `StateProvider<({String name, String email, String phone, String signInMethod})?>` | Passes data between auth screens |
| `sessionGuestProvider` | `StateProvider<bool>` | Session-only guest bypass (not written to disk) |

`HomeScreen` is split into separate `ConsumerWidget` sub-widgets to minimise rebuild scope.

---

## Diary Editor

The diary uses a markdown-based rich text editor:

| Toolbar Button | Effect |
|---|---|
| `H1` | Inserts `# ` prefix on current line |
| `H2` | Inserts `## ` prefix on current line |
| **B** | Wraps selected text with `**bold**` |
| *I* | Wraps selected text with `_italic_` |
| `•` | Inserts `• ` bullet prefix on current line |
| 📷 | Opens device gallery to pick a photo |

Content stored as plain markdown text. Photos stored as local file paths via `image_picker`.

---

## Design System

The app uses a TIDE iOS-inspired dark design system. All values live in `app_colors.dart` and `app_text_styles.dart`.

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

## Data Persistence

All trek data is stored locally using `SharedPreferences`. Firebase is used only for authentication.

| Key | Type | Contents |
|---|---|---|
| `td_logged_in` | bool | Auth state |
| `td_name` | string | User name |
| `td_email` | string | User email |
| `td_phone` | string | User phone |
| `td_age` | int | User age |
| `td_bio` | string | Profile bio |
| `td_location` | string | Home location |
| `td_experience` | string | Trekking experience level |
| `td_profile_complete` | bool | Profile setup completed |
| `td_pin` | string | 4-digit app PIN |
| `trekdiary_treks` | string | JSON-encoded list of all treks |

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
- `context.pushReplacement()` — replace current screen (used after form submit)
- `context.go()` — top-level tab switches only
- Never use `Navigator.push` / `Navigator.pop` — all navigation goes through GoRouter

**Cover photos**
`Trek.coverImageUrl` takes precedence over the deterministic `getTrekPhotoUrl(trek)` hash-based fallback. Any publicly accessible direct image URL works.

**Diary images**
`DiaryImage` has both `localPath` (device gallery, from `image_picker`) and `url` (network URL). `displayPath` returns `localPath` if non-empty, otherwise `url`. Display with `Image.file(File(image.localPath))` for local paths and `CachedNetworkImage` for URLs.

---

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit your changes
4. Push and open a pull request

---

## License

MIT License — see [LICENSE](LICENSE) for details.
