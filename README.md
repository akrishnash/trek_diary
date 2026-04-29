# Trek Diary

A beautifully designed offline-first trekking journal app built with Flutter. Inspired by the TIDE design language — full-bleed dark photography, ultra-thin typography, and frosted glass surfaces.

---

## Features

### Authentication
- **Google Sign-In** — OAuth via Firebase, account picker on first tap
- **Phone + OTP** — Enter your number, receive a 6-digit code, verify
- **Email Sign-In** — Name + email → set a 4-digit PIN
- **Continue as Guest** — Session-only access, no account needed
- **Profile Setup** — After any sign-in, prompted for name, age, and experience level

### Trek Management
- **Create treks** — Name, region, difficulty, description, number of days
- **Edit treks** — Update all details including cover photo
- **Cover photo** — Set a custom image URL per trek; falls back to a region-matched Unsplash photo
- **Trek cards** — Pangea-style cards with gradient overlays, difficulty badges, and stop counts
- **Trek detail** — Day-by-day breakdown, stops timeline, stats

### Stops & Days
- **Add stops** — Name, coordinates, elevation, notes per stop
- **Stop detail** — Full stop info with photo header
- **Trek path** — Visual map of all stops in sequence
- **Trek summary** — Aggregate stats: total days, stops, distance

### Diary
- **Obsidian-style rich text editor** — Format text with H1, H2, bold, italic, and bullet points via a sticky formatting toolbar
- **Trek photo background** — The diary screen uses the trek's cover photo as a full-bleed background; falls back to the login mountain photo
- **Photo picker** — Upload photos directly from your device gallery; displayed as a 2-column grid
- **Markdown syntax** — Formatting is stored as markdown (`**bold**`, `_italic_`, `# Heading`)
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
| Serialization | freezed + json\_serializable |

---

## Project Structure

```
lib/
├── app.dart                          # Root app widget + theme
├── main.dart                         # Entry point, Firebase init
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Full design token palette
│   │   ├── app_text_styles.dart      # TIDE-inspired type scale
│   │   ├── app_constants.dart
│   │   └── app_durations.dart
│   ├── router/
│   │   └── app_router.dart           # GoRouter with auth guards
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── id_generator.dart
│
├── data/
│   ├── models/
│   │   ├── trek.dart
│   │   ├── day.dart
│   │   ├── stop.dart
│   │   └── diary_entry.dart          # DiaryEntry + DiaryImage (url + localPath)
│   ├── providers/
│   │   └── auth_provider.dart        # AuthState, AuthNotifier
│   └── repositories/
│       └── trek_repository.dart      # TrekNotifier, SharedPrefs persistence
│
├── features/
│   ├── auth/screens/
│   │   ├── auth_landing_screen.dart  # Google, Phone, Email, Guest
│   │   ├── auth_email_screen.dart
│   │   ├── auth_pin_screen.dart
│   │   ├── auth_phone_screen.dart
│   │   ├── auth_otp_screen.dart      # 6-cell OTP + numpad + resend countdown
│   │   └── auth_profile_screen.dart  # Name, age, experience level
│   ├── home/
│   │   ├── screens/home_screen.dart
│   │   └── widgets/trek_card.dart
│   ├── create_trek/screens/
│   ├── edit_trek/screens/
│   ├── trek_detail/screens/
│   ├── trek_path/screens/
│   ├── stop_detail/screens/
│   ├── add_stop/screens/
│   ├── summary/screens/
│   ├── diary/screens/
│   │   └── diary_entry_screen.dart   # Rich text editor with formatting toolbar
│   ├── profile/screens/
│   │   └── profile_screen.dart       # Editable profile with photo background
│   └── settings/screens/
│
└── shared/widgets/
    ├── glass.dart                    # GlassBackButton, frosted pill
    ├── primary_button.dart
    ├── stat_card.dart
    ├── diff_badge.dart
    ├── chip_picker.dart
    ├── photo_grid.dart
    ├── photo_hero_header.dart
    └── stop_timeline.dart
```

---

## Getting Started

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

---

## Auth Flow

```
Landing Screen
├── Continue with Google  →  Profile Setup  →  Home
├── Continue with Phone   →  OTP Screen  →  Profile Setup  →  Home
├── Continue with Email   →  PIN Screen  →  Home
└── Continue as Guest     →  Home (session only, no persistence)
```

The router automatically redirects:
- Unauthenticated users → `/auth`
- Authenticated users with incomplete profile → `/auth/profile`
- Authenticated + profile complete → `/`

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

Content is stored as plain markdown text. Photos are stored as local file paths.

---

## Design System

The app follows a TIDE-inspired dark design language:

| Token | Value | Usage |
|---|---|---|
| `sheet` | `#1A1F1C` | Main content sheet |
| `surface` | `#252B28` | Cards, inputs |
| `accent` | `#5B8A6E` | Sage green — CTAs, highlights |
| `border` | `#3A4240` | Field and card borders |
| `textPrimary` | `#FFFFFF` | Headings |
| `textSecondary` | `#8A9590` | Subtitles, hints |

Typography uses **Poppins** throughout (w200 display → w700 headings) and **Source Code Pro** in the diary editor.

---

## Data Persistence

All data is stored locally on device using `SharedPreferences`. No backend server is required for trek data. Firebase is used only for authentication.

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
| `td_treks` | string | JSON-encoded list of all treks |

---

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit your changes
4. Push and open a pull request

---

## License

MIT License — see [LICENSE](LICENSE) for details.
