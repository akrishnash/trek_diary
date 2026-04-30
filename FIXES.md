# Trek Diary — Senior Frontend Fixes

Applied during code review session. Nine issues fixed across four files.

---

## Bug Fixes

### 1. Trek detail screen ignored uploaded cover photo
**File:** `lib/features/trek_detail/screens/trek_detail_screen.dart`

The detail screen always showed a hash-derived nature photo, ignoring any cover image the user uploaded. The journal screen already handled this correctly.

```dart
// Before
imageUrl: getTrekPhotoUrl(trek),

// After
imageUrl: trek.coverImageUrl?.isNotEmpty == true
    ? trek.coverImageUrl!
    : getTrekPhotoUrl(trek),
```

---

### 2. Auth state cleared on every app launch
**File:** `lib/main.dart`

A temporary debug line (`prefs.remove('td_logged_in')`) was never removed. Every cold start logged the user out.

```dart
// Removed:
await prefs.remove('td_logged_in'); // TEMP: clear stuck guest auth
```

---

### 3. `activeTrekProvider` used try/catch instead of `.firstOrNull`
**File:** `lib/data/repositories/trek_repository.dart`

Violated the CLAUDE.md convention: "All `firstWhere` on lists must use `.where().firstOrNull`".

```dart
// Before
final activeTrekProvider = Provider<Trek?>((ref) {
  final list = ref.watch(trekListProvider);
  try {
    return list.firstWhere((t) => !t.completed);
  } catch (_) {
    return null;
  }
});

// After
final activeTrekProvider = Provider<Trek?>((ref) =>
    ref.watch(trekListProvider).where((t) => !t.completed).firstOrNull);
```

---

### 4. Markdown viewer stripped bold/italic instead of rendering it
**File:** `lib/features/journal/screens/trek_journal_screen.dart`

`_MarkdownView._strip()` removed `**bold**` and `_italic_` markers but rendered everything as plain unstyled text. Inline formatting was silently discarded.

Replaced `_strip()` + `Text()` with `_parseInline()` + `RichText(TextSpan(...))` so bold and italic are actually rendered.

```dart
// Before: strips markers, loses formatting
static String _strip(String s) => s
    .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'_(.+?)_'), (m) => m[1]!);

// After: parses markers into styled TextSpans
static List<TextSpan> _parseInline(String text, TextStyle base) {
  // bold → FontWeight.bold, italic → FontStyle.italic
}
```

---

## Performance Fixes

### 5. Trek detail screen rebuilt on any trek list change
**File:** `lib/features/trek_detail/screens/trek_detail_screen.dart`

`ref.watch(trekListProvider)` subscribed to the entire list. Any mutation to any trek (e.g. adding a stop to a different trek) triggered a full rebuild of the detail screen.

```dart
// Before
final treks = ref.watch(trekListProvider);
final trek  = treks.where((t) => t.id == widget.trekId).firstOrNull;

// After — rebuilds only when this specific trek changes
final trek = ref.watch(
  trekListProvider.select(
    (list) => list.where((t) => t.id == widget.trekId).firstOrNull,
  ),
);
```

---

### 6. `MediaQuery.of(context)` used instead of single-aspect subscriptions
**File:** `lib/features/trek_detail/screens/trek_detail_screen.dart`

`MediaQuery.of(context)` subscribes to the entire MediaQuery object and rebuilds on any change (keyboard, text scale, orientation, system insets). The more targeted APIs subscribe only to the value they need.

```dart
// Before
final size = MediaQuery.of(context).size;
final safe = MediaQuery.of(context).padding;

// After
final size = MediaQuery.sizeOf(context);
final safe = MediaQuery.paddingOf(context);
```

---

## UX / Layout Fixes

### 7. Four action chips in unconstrained Row caused overflow on small screens
**File:** `lib/features/trek_detail/screens/trek_detail_screen.dart`

"Journal", "Edit", "Path", "Summary" buttons in a `Row` with no overflow handling clipped on 360px-wide devices. Wrapped in a horizontally scrollable container bounded on the left by the back button.

```dart
Positioned(
  top: safe.top + 12,
  left: 62,   // reserves space for back button
  right: 16,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    reverse: true,  // keeps right-aligned; scrolls left on overflow
    child: Row(children: [ ... ]),
  ),
),
```

---

### 8. `GestureDetector` replaced with `InkWell` throughout `_DayCard`
**File:** `lib/features/trek_detail/screens/trek_detail_screen.dart`

`GestureDetector` gives no haptic/ripple feedback and no accessibility semantics. All interactive containers converted to `InkWell` (with `Material(color: transparent)` ancestor where needed for the ink layer).

Affected: main card tap, "Log a stop", "Add stop", diary button, stop rows, "Full Journal" link.

---

### 9. Monospace code font used for diary journal body text
**File:** `lib/features/journal/screens/trek_journal_screen.dart`

`GoogleFonts.sourceCodePro` is a monospace font designed for source code. Journal entries rendered as if they were terminal output.

```dart
// Before
static final _body = GoogleFonts.sourceCodePro(...);

// After
static final _body = GoogleFonts.lora(...);  // serif, readable for long-form prose
```

---

## Files Changed

| File | Changes |
|------|---------|
| `lib/main.dart` | Remove debug `prefs.remove` |
| `lib/data/repositories/trek_repository.dart` | Fix `activeTrekProvider` |
| `lib/features/trek_detail/screens/trek_detail_screen.dart` | Cover photo, select(), MediaQuery, chips overflow, InkWell |
| `lib/features/journal/screens/trek_journal_screen.dart` | Markdown inline rendering, Lora font |
