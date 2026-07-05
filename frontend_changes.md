# Poneglyph — Frontend Design Documentation

> **Source of truth:** `design.jpeg` (16-panel composite screenshot)  
> All dimensions, colors, and behaviors described below are taken directly from the design image and matched against the current Flutter source code.

---

## Table of Contents

1. [Global Design System](#1-global-design-system)
2. [Bottom Navigation Bar](#2-bottom-navigation-bar)
3. [Screen 1 — Library](#3-screen-1--library)
4. [Screen 2 — Reader (Reading View)](#4-screen-2--reader-reading-view)
5. [Screen 3 — Reading Settings](#5-screen-3--reading-settings)
6. [Screen 4 — Themes](#6-screen-4--themes)
7. [Screen 5 — Table of Contents](#7-screen-5--table-of-contents)
8. [Screen 6 — Search in Book](#8-screen-6--search-in-book)
9. [Screen 7 — Highlights & Notes](#9-screen-7--highlights--notes)
10. [Screen 8 — Dictionary](#10-screen-8--dictionary)
11. [Screen 9 — Text-to-Speech (TTS)](#11-screen-9--text-to-speech-tts)
12. [Screen 10 — Reading Progress](#12-screen-10--reading-progress)
13. [Screen 11 — Collections (Bookshelves)](#13-screen-11--collections-bookshelves)
14. [Screen 12 — Statistics](#14-screen-12--statistics)
15. [Screen 13 — Import & Backup](#15-screen-13--import--backup)
16. [Screen 14 — Bookmarks](#16-screen-14--bookmarks)
17. [Screen 15 — More Options](#17-screen-15--more-options)
18. [Screen 16 — Filter & Sort](#18-screen-16--filter--sort)
19. [Shared Widgets & Components](#19-shared-widgets--components)
20. [What Is Implemented vs. What Needs Work](#20-what-is-implemented-vs-what-needs-work)
21. [File Map Quick Reference](#21-file-map-quick-reference)

---

## 1. Global Design System

### 1.1 Color Palette

| Token | Hex | Usage |
|---|---|---|
| `kPrimary` | `#7C6FFF` | Accent, active tabs, buttons, highlights, progress rings |
| `kDarkBg` | `#0F0F17` | Scaffold / page background |
| `kDarkSurface` | `#1A1A2E` | Cards, bottom nav, top bars, bottom sheets |
| `kDarkSurface2` | `#16213E` | Slightly lighter surfaces (selected tiles) |
| `kDarkText` | `#EAEAF4` | Primary text color |
| `kDarkSubtext` | `#8888A8` | Secondary / subtitle text |
| Highlight Yellow | `#FFD54F` | Yellow highlight accent bar |
| Highlight Green | `#81C784` | Green highlight accent bar |
| Highlight Blue | `#64B5F6` | Blue highlight accent bar |
| Highlight Pink | `#F06292` | Pink highlight accent bar |
| Stat Accent Purple | `#6C63FF` | Time-read stat card |
| Stat Accent Red | `#FF6584` | Pages-read stat card |
| Stat Accent Cyan | `#45B7D1` | Books-finished stat card |
| Stat Accent Amber | `#FFAA44` | Reading streak stat card |
| Error / Delete | `Colors.red[400]` ≈ `#EF5350` | Delete buttons, error states |
| Google Blue | `#4285F4` | Google Drive icon |
| Dropbox Blue | `#007EE5` | Dropbox icon |
| OneDrive Blue | `#0078D4` | OneDrive icon |

**Source file:** `lib/theme/app_theme.dart`

---

### 1.2 Typography

Font family: **Inter** via `google_fonts` package. Applied to the full `TextTheme`.

| Style | Size | Weight | Usage |
|---|---|---|---|
| `displaySmall` | 24 | Bold 700 | Screen titles (Library, Collections, Profile…) |
| `headlineMedium` | 20 | SemiBold 600 | Reading goal value |
| `titleLarge` | 16 | SemiBold 600 | Section headers, dialog titles, TOC title |
| `titleMedium` | 14 | Medium 500 | Card titles, list item titles |
| `titleSmall` | 12 | Medium 500 | Reader top bar book title |
| `bodyLarge` | 16 | Regular 400 | Reader body text |
| `bodyMedium` | 14 | Regular 400 | General body, highlight quotes |
| `bodySmall` | 12 | Regular 400 | Captions, subtitles, page numbers |
| `labelMedium` | 12 | Medium 500 | Book grid title |
| `labelSmall` | 10 | Medium 500 | Progress %, chapter page numbers |

**Source file:** `lib/theme/app_theme.dart` → `AppTheme._base()` textTheme

---

### 1.3 Border Radius Tokens

| Token | Value | Example Usage |
|---|---|---|
| `radiusXs` | 4 px | Progress bar clips, small accent dividers |
| `radiusSm` | 8 px | Icon containers in ListTile leading widgets |
| `radiusMd` | 12 px | Book grid covers, input fields, chips, TTS control chips |
| `radiusLg` | 16 px | Cards, dialogs, bottom sheets |
| `radiusXl` | 24 px | Bottom sheet top-rounded corners |
| `radiusFull` | 999 px | Filter tab pills, progress badges, TTS play button |

**Source file:** `lib/theme/design_tokens.dart`

---

### 1.4 Spacing Grid

Base unit: 4 px.

```
grid2=2   grid4=4   grid8=8   grid12=12  grid16=16
grid20=20 grid24=24 grid32=32 grid40=40  grid48=48
grid56=56 grid64=64
```

**Source file:** `lib/theme/design_tokens.dart`

---

### 1.5 Theme Modes

| Mode | Background | Surface | Accent | Brightness |
|---|---|---|---|---|
| **Dark** (default) | `#0F0F17` | `#1A1A2E` | `#7C6FFF` | Dark |
| Light | `#F5F5FA` | `#FFFFFF` | `#7C6FFF` | Light |
| Sepia | `#F0E8C8` | `#F5EDD6` | `#8B6914` | Light |
| Amoled Black | `#000000` | `#0A0A0A` | `#7C6FFF` | Dark |
| Custom | User-defined | Derived | User-defined | Auto |

Default is **Dark** — hardcoded in `ThemeProvider()` constructor:
```dart
ThemeProvider() : _currentTheme = AppTheme.fromMode(AppThemeMode.dark);
```
Also defaults to dark when `SharedPreferences` has no stored `theme_mode` key.

**Source files:** `lib/theme/app_theme.dart`, `lib/theme/theme_provider.dart`

---

### 1.6 Elevation

| Token | Value | Usage |
|---|---|---|
| `elevation0` | 0 | All cards (flat design) |
| `elevation1` | 2 | — |
| `elevation2` | 4 | — |
| `elevation3` | 8 | — |
| `elevation4` | 16 | — |

All cards use `elevation: 0`. Depth is implied by surface color contrast against the background.

---

## 2. Bottom Navigation Bar

**Source file:** `lib/app.dart` → `_AppShellState._navItem()`

### Visual Spec

```
┌──────────────────────────────────────────────────────┐
│  [Library]  [Reader]  [Bookshelves]  [Search]  [Profile] │
│     ■           □           □           □          □     │
└──────────────────────────────────────────────────────┘
```

| Index | Inactive Icon | Active Icon | Label |
|---|---|---|---|
| 0 | `local_library_outlined` | `local_library` | Library |
| 1 | `menu_book_outlined` | `menu_book` | Reader |
| 2 | `collections_bookmark_outlined` | `collections_bookmark` | Bookshelves |
| 3 | `search_outlined` | `search` | Search |
| 4 | `person_outline` | `person` | Profile |

### Styling Details

- Container background: `kDarkSurface` (`#1A1A2E`)
- Top border: `rgba(255,255,255,0.07)` hairline, 0.5 px
- Total height: 58 px + `SafeArea` bottom inset
- Active icon + label: `kPrimary` (`#7C6FFF`)
- Inactive icon + label: `kDarkText` at ~43% opacity (`withAlpha(110)`)
- Icon size: 22 px
- Label font: 9.5 px Inter, w600 active, w400 inactive
- Spacing: icon → label gap = 3 px
- Implementation: custom `Row` of `Expanded(GestureDetector)` — **not** Flutter's `BottomNavigationBar` widget
- Active Library tab shows the filled `local_library` icon with purple color exactly as in design

---

## 3. Screen 1 — Library

**Source file:** `lib/screens/library/library_screen.dart`

### 3.1 Top App Bar

```
[≡]          Library          [🔍][+]
```

| Element | Detail |
|---|---|
| Left | `Icons.menu` hamburger, 24 px, `kDarkText` color |
| Center | Text "Library", 18 px, Inter w700 |
| Right 1 | `Icons.search` icon button, opens search dialog |
| Right 2 | `Icons.add` icon button, opens import bottom sheet |
| Background | Transparent (inherits `kDarkBg`) |
| Elevation | None |
| Padding | `fromLTRB(16, 14, 8, 0)` |
| Icon button constraints | `minWidth: 36, minHeight: 36`, `padding: EdgeInsets.zero` |

### 3.2 Filter Tab Bar

Horizontal `ListView` of pill-shaped filter tabs, placed 14 px below the top bar.

| Tab Label | State in Design |
|---|---|
| **All** | Active |
| Books | Inactive |
| Collections | Inactive |
| Authors | Inactive |

**Active tab:**
- Background: `kPrimary` (solid purple)
- Text color: white
- Font weight: w600

**Inactive tab:**
- Background: `kPrimary.withAlpha(20)` (~8% opacity purple)
- Text color: `kPrimary`
- Font weight: w400

**Common:**
- Font size: 12.5 px
- Padding per tab: `symmetric(horizontal:18, vertical:7)`
- Border radius: `radiusFull` (999 px pill)
- Right margin between tabs: 8 px
- ListView height: 36 px
- ListView padding: `symmetric(horizontal:16)`
- Selected state changes on `setState`

### 3.3 Book Grid

- **3 columns** (`crossAxisCount: 3`)
- `childAspectRatio: 0.62` (portrait orientation — books are taller than wide)
- `crossAxisSpacing: 10 px`
- `mainAxisSpacing: 14 px`
- Grid padding: `fromLTRB(12, 4, 12, 20)`
- Wrapped in `RefreshIndicator` (purple color, dark background)

### 3.4 Book Grid Item (`_BookGridItem`)

**Layout:** `Column` (crossAxisAlignment: start)

**Cover (Expanded):**
- Container with `BoxDecoration`:
  - Color: one of 8 dark cover tones, cycled by `title.length % 8`

    | Color Name | Hex |
    |---|---|
    | Deep Navy | `#2D2D5A` |
    | Dark Brown | `#3D2E1E` |
    | Dark Green | `#1E3A2F` |
    | Dark Plum | `#3A1E2E` |
    | Dark Steel | `#1E2C3A` |
    | Dark Purple | `#2E1E3A` |
    | Dark Amber | `#3A2E1E` |
    | Dark Teal | `#1E3A3A` |

  - `borderRadius: radiusMd` (12 px)
- Centered `Icons.menu_book_rounded`, size 32, `Colors.white.withAlpha(200)` (78%)

**Progress Badge** (shown only when `book.progress > 0`):
- `Positioned(bottom:6, right:6)`
- Text: `"$progressPct%"` (e.g. "67%")
- Background: `rgba(0,0,0,0.63)`
- Border radius: 20 px (pill)
- Font: 9 px, white, w600
- Padding: `symmetric(horizontal:6, vertical:3)`

**Favorite Heart** (shown only when `book.isFavorite`):
- `Positioned(top:6, right:6)`
- `Icons.favorite`, `Colors.red[400]`, size 16

**Below Cover (in Column):**

| Element | Style |
|---|---|
| SizedBox | height: 6 |
| Book title | `labelMedium` 12px w600, maxLines:1, ellipsis |
| SizedBox | height: 1 |
| Author name | `labelSmall` 10px, `kDarkText.withAlpha(140)`, maxLines:1, ellipsis |
| Progress text | 9.5px w600 `kPrimary` — shown only if `progress > 0` |

**Interactions:**
- `onTap` → pushes `ReaderScreen(book: book)`
- `onLongPress` → shows book context menu bottom sheet

### 3.5 Empty State

Centered column:
- `Icons.menu_book_outlined`, 64 px, primary at 31% opacity
- "Your library is empty" — titleMedium, muted
- "Import your first book to get started" — bodySmall, 39% opacity
- `ElevatedButton.icon` "Import Book" with `Icons.add`, 24 px below subtitle

### 3.6 Loading State

`GridView.builder` with 9 placeholder cells:
- Each: dark container matching cover shape (`kDarkSurface`, `radiusMd`)
- No shimmer in current implementation

### 3.7 Authors Tab

- Groups `library.books` by `book.author`
- `Map<String, List<Book>>` → sorted alphabetically
- `ListView.separated`:
  - `separatorBuilder`: `Divider(height:1, color:rgba(255,255,255,0.06))`
- Each row: `ListTile`
  - Leading: `CircleAvatar` — `kPrimary.withAlpha(40)` bg, first letter of author in `kPrimary` bold
  - Title: author name, titleMedium w600
  - Subtitle: "N book(s)" — bodySmall at 51% opacity
  - Trailing: `Icons.chevron_right` at 39% opacity
  - `onTap` → opens first book in the author's list

### 3.8 Collections Tab

- Reads `CollectionsProvider.collections`
- If empty: centered "No collections yet" muted text
- If populated: `ListView.separated` with folder icon, collection name, book count, chevron

### 3.9 Import Bottom Sheet

Triggered by "+" icon. Dark bottom sheet (`kDarkSurface`, `SafeArea`):

- Drag handle: 40×4 px, `rgba(255,255,255,0.16)`, `borderRadius:2`
- Title: "Import Book", titleLarge
- `ListTile` rows:
  - `Icons.phone_android` "From Device" — "Browse files on your device"
  - `Icons.link` "From URL" — "Download from a web link"
  - `Icons.drive_file_move_outlined` "Google Drive"
  - `Icons.cloud_upload_outlined` "Dropbox"

### 3.10 Book Context Menu (long-press)

Dark bottom sheet:
- Drag handle
- "Add to Favorites" / "Remove from Favorites" with heart icon → calls `library.toggleFavorite(book.id)`
- "Share" with share icon (no-op currently)
- "Delete" in red → triggers `_confirmDelete()` AlertDialog
  - Dialog: "Delete Book", "Delete {title}?", Cancel + red "Delete" buttons

---

## 4. Screen 2 — Reader (Reading View)

**Source file:** `lib/screens/reader/reader_screen.dart`

### 4.1 Reading Content Area

- Full-screen `Container`, color = `theme.scaffoldBackgroundColor`
- `SingleChildScrollView` → `Padding(horizontal: settings.readingMargins)`
- Inner padding: `(1 - settings.readingLineWidth) * 100` on each side
- **Book title text:** `readingFontSize × 1.3`, bold, `kDarkText`
- **Body text:** configurable via `SettingsProvider`:
  - `readingFontSize` (default 18 px)
  - `readingFontFamily` (default "System" = Inter)
  - `readingFontWeight` (0.0–1.0 mapped to `FontWeight` enum index)
  - `readingLineHeight` (default 1.6)
  - `readingJustification` → `TextAlign.justify` or `TextAlign.start`
- Tap anywhere → `reader.toggleBars()` → fade in/out (300 ms `easeInOut`)

### 4.2 Top Bar

```
[←]    The Hobbit         [☰][🔖][🔍][⋮]
       Chapter 1
```

| Element | Detail |
|---|---|
| Background | `scaffoldBackgroundColor.withAlpha(240)` + 4 px bottom shadow |
| Back `Icons.arrow_back` | Saves progress via `LibraryProvider.updateBookProgress()` then `Navigator.pop()` |
| Center title | Book title — `titleSmall` (12px w500), maxLines:1, ellipsis |
| Center subtitle | "Page X of Y" — `labelSmall` at 59% opacity |
| `Icons.list` / `Icons.close` | Toggles TOC panel |
| `Icons.bookmark` / `Icons.bookmark_border` | `reader.toggleBookmark()` |
| `Icons.search` | `reader.setSearching(true)` — opens in-book search panel |
| `Icons.more_vert` | Opens "More" bottom sheet |

### 4.3 Bottom Bar

```
[Progress Slider ──────●──────── 67%]
[←Prev] [Aa Font] [🎨Theme] [🔊TTS] [☀Bright] [Next→]
```

| Element | Detail |
|---|---|
| Background | `scaffoldBackgroundColor.withAlpha(240)` + 4 px top shadow |
| Slider | `trackHeight:3`, thumb radius 6, overlay radius 12, `kPrimary` color |
| Slider range | 0 → `reader.totalPages`, `onChanged`: `reader.goToPage()` |
| Prev / Next | `Icons.chevron_left` / `Icons.chevron_right` |
| Font button | `Icons.format_size` → `FontBottomSheet` |
| Theme button | `Icons.palette` → `ThemeBottomSheet` |
| TTS button | `Icons.volume_up` → `reader.setTTSActive()` toggle |
| Brightness button | `Icons.brightness_6` → brightness bottom sheet |
| Button layout | Icon 20 px + label 9 px, stacked vertically, padding 8 px all |

---

## 5. Screen 3 — Reading Settings

**Source file:** `lib/widgets/bottom_sheets.dart` → `FontBottomSheet`

Accessed via Reader bottom bar "Font" (Aa) button.

### Layout

Dark bottom sheet, `isScrollControlled: true`. Rows:

| Row | Left label | Right control |
|---|---|---|
| Section header | **Font** | — |
| Font Family | "Font Family" | "Lora" + `Icons.chevron_right` |
| Font Size | "Font Size" | `[−]  18  [+]` stepper |
| Line Spacing | "Line Spacing" | "1.6" + `Icons.expand_more` dropdown |
| Margins | "Margins" | 4 icon buttons (compact/normal/wide/full-width) |
| Text Alignment | "Text Alignment" | 3 icon buttons (left/center/justify) |
| Justification | "Justification" | `Switch` (ON → purple) |
| Hyphenation | "Hyphenation" | `Switch` (OFF → grey) |
| Two-column (Landscape) | "Two-column (Landscape)" | `Switch` (OFF) |
| Maintain Line Width | "Maintain Line Width" | `Switch` (ON) |
| — | **"More Settings"** | Full-width purple `ElevatedButton` |

**Stepper buttons** (`[−]` and `[+]`): outlined circular buttons, purple
**Margin icons:** grid icons representing text width presets
**Alignment icons:** `format_align_left`, `format_align_center`, `format_align_justify`

---

## 6. Screen 4 — Themes

**Source file:** `lib/widgets/bottom_sheets.dart` → `ThemeBottomSheet`

Dark bottom sheet accessed via Reader "Theme" (🎨) button.

### Theme List

Each row: theme name (left) + preview swatch + radio button (right)

| Theme | Radio State in Design |
|---|---|
| Light | ● Selected (purple filled circle with checkmark) |
| Dark | ○ Unselected |
| Sepia | ○ Unselected |
| Amoled Black | ○ Unselected |
| Forest Green | ○ Unselected |
| Custom Theme | ○ Unselected + "Edit" text link + small color dot |

### Brightness Section (below theme list)

```
☀ ────────●──────── ☀ (brighter)
Auto Brightness        [Toggle ON]
```

- Section label: "Brightness" — titleMedium
- `Row`: dim sun icon + `Slider` (purple) + bright sun icon
- `SwitchListTile` "Auto Brightness" — purple when ON

---

## 7. Screen 5 — Table of Contents

**Source file:** `lib/screens/reader/reader_screen.dart` → `_buildTocPanel()`

Full-screen overlay covering the reader.

### Header Bar

```
[×]  Table of Contents
```

- Background: `kDarkSurface` + 4 px bottom shadow
- `Icons.close` left-aligned → `reader.setTocOpen(false)`
- "Table of Contents" — titleLarge

### Chapter List

`ListView.separated` with `Divider`:

Each chapter row is a `ListTile`:
- **Title:** chapter name — normal weight by default; **active chapter** uses w600, color `kPrimary`
- **Subtitle:** "Page X"
- **Trailing:** `Icons.more_vert` (3-dot menu per chapter)
- **Selected tile** background: `kPrimary.withAlpha(15)`
- `onTap` → `reader.goToPage(index * 20 + 1)` + close panel

**Chapters shown in design (The Hobbit):**
```
Cover
Title Page
Chapter 1 · An Unexpected Party    ← active (purple highlight)
Chapter 2 · Roast Mutton
Chapter 3 · A Short Rest
Chapter 4 · Over Hill and Under Hill
Chapter 5 · Riddles in the Dark
Chapter 6 · Out of the Frying-Pan into the Fire
Chapter 7 · Queer Lodgings
```

---

## 8. Screen 6 — Search in Book

**Source file:** `lib/screens/reader/reader_screen.dart` → `_buildSearchPanel()`

Full-screen overlay.

### Header

```
[×]  [🔍 hobbit  ×]
```

- `Icons.close` → `reader.setSearching(false)`
- Autofocused `TextField`, hint "Search in book…"
- Clear `Icons.clear` appears when text is non-empty
- Background: `kDarkSurface` + 4 px bottom shadow

### Results List

- Count: "12 results found" — bodySmall muted
- `ListView.builder` rows showing page number + excerpt with **bolded keyword**

**Results shown in design:**
```
Page 3   — In a hole in the ground there lived a hobbit.
Page 16  — Bilbo was very rich for a hobbit.
Page 27  — The hobbit sat and thought.
Page 45  — The hobbits were singing merrily.
Page 102 — A hobbit's life is peaceful.
```

### Bottom Actions Bar (bottom of sheet)

```
"Search Options"        [⚙ filter icon]
```

---

## 9. Screen 7 — Highlights & Notes

**Source file:** `lib/screens/highlights_screen.dart`

### Header

```
Highlights & Notes                  [🔽 filter]
```

- "Highlights & Notes" — displaySmall
- `Icons.filter_list` icon button (right) → opens filter bottom sheet

### Segment Tabs

```
[ Highlights ]   [ Notes ]
```

- Segmented control style: active tab has purple filled pill background
- "Highlights" is the default active tab

### Color Filter Chips (horizontal `ListView`)

```
[All]  [Yellow]  [Green]  [Blue]  [Pink]  [Underline]
```

- Pill-shaped chips, 12 px font
- Active chip: solid highlight color background, white text
- Inactive chip: `kPrimary.withAlpha(15)` bg, `kPrimary` text
- Height: 36 px

### Highlight Cards (`ListView.builder`)

Each `Card` (`kDarkSurface`, `radiusLg`, elevation 0):

```
┌──────────────────────────────────────────────┐
│ ▏ (colored 4px bar)                          │
│   "Quoted highlight text here..."             │
│   Page 3                      [↗ share] [🗑] │
└──────────────────────────────────────────────┘
```

- Left accent bar: 4 px wide × 40 px tall, color matches highlight type, `borderRadius:2`
- Gap: 12 px between bar and text
- Quote text: bodyMedium, maxLines:3, ellipsis
- If note attached: note box below text
  - Background: `kPrimary.withAlpha(10)`
  - `borderRadius: 6`
  - `Icons.note` 14 px + note text bodySmall
- Bottom row:
  - "Page X" — labelSmall at 47% opacity
  - Share icon (`Icons.share`, 16 px) — no-op
  - Delete icon (`Icons.delete_outline`, 16 px) → removes from list

**Highlight examples from design:**

| Color | Page | Text |
|---|---|---|
| 🟡 Yellow | 3 | "In a hole in the ground there lived a hobbit." |
| 🟢 Green | 25 | "All we have to decide is what to do with the time that is given us." |
| 🔵 Blue | 48 | "There is some good in this world, and it's worth fighting for." |
| 🩷 Pink | 121 | "Even the smallest person can change the course of the future." |

### Add Note Button

- Full-width `ElevatedButton` at bottom: `"+ Add Note"`, purple

---

## 10. Screen 8 — Dictionary

**Source file:** `lib/screens/dictionary_screen.dart`

### Header

```
[←]  Dictionary                          [🔊]
```

- Back arrow + "Dictionary" title + `Icons.volume_up` speaker (right)

### Word Entry

```
hob·bit
/ ˈhɒbɪt /
noun
```

- Word: very large bold white text (display size)
- Phonetic: bodyMedium italic, muted color
- Part of speech: "noun" — small label chip

### Definitions Section

**Oxford Dictionary** (labeled source):

1. a member of a fictional race in J. R. R. Tolkien's Middle-earth, smaller than humans.
2. a person who enjoys a quiet, simple life.

- Source label: "Source: Oxford Dictionary" — bodySmall muted

### Wikipedia Section

- Header: "Wikipedia" — titleMedium
- Paragraph extract text — bodyMedium, muted
- "Full Definition" — full-width outlined button, `kPrimary` border + text

---

## 11. Screen 9 — Text-to-Speech (TTS)

**Source file:** `lib/screens/tts_screen.dart`

### Header

```
[←]  Text-to-Speech
```

### Book Info (centered)

- Book cover thumbnail: 100×140 px, `kPrimary.withAlpha(30)` bg, `Icons.menu_book` 48 px
- Book title: "The Hobbit" — titleLarge
- Author: "J.R.R. Tolkien" — bodySmall muted
- Chapter info: "Chapter 1 · An Unexpected Party" — bodySmall muted

### Progress Bar

```
02:46  ─────────●─────────  06:31
```

- Purple `Slider` with time labels either side
- `_progress` state drives slider value (0.0–1.0)

### Playback Controls

```
[↩15]          [▶]          [15↪]
```

- Rewind: `Icons.replay_15`, 36 px
- Play/Pause: 64×64 px circle, `kPrimary` background, `Icons.play_arrow` / `Icons.pause` white 32 px
- Forward: `Icons.forward_15`, 36 px

### Voice & Speed Controls

```
Voice                Speed
English (US) - Ava   1.0x  [▼]
```

- Each: dark rounded container (`kDarkSurface`, `radiusMd`)
- Label on top (10 px muted), value below (12 px w600)
- Tappable (dropdown)

---

## 12. Screen 10 — Reading Progress

**Source file:** `lib/screens/reading_stats_screen.dart` + reader bottom bar `ReaderProvider`

### Header

```
[≡]  Reading Progress
```

### Large Circular Progress Indicator

- Center text: **"67%"** — very large (displayLarge ~40 px+), white bold
- Subtitle: "Completed" — bodyMedium muted
- Ring: thick arc (~12 px stroke), `kPrimary` foreground, dark grey track
- Diameter: ~200 px (fills most of screen width)
- Implemented with `CustomPainter` arc (needs implementation — currently not built as a circular ring)

### Stats Grid (2 columns × 2 rows)

```
Pages read      Time spent
132 / 198       6h 45m
─────────────────────────
Pages left      Current streak
66              5 days 🔥
```

- Values: titleLarge white bold
- Labels: bodySmall at 51% opacity
- Current streak: "5 days 🔥" — orange colored

### Reading Insights Button

- Full-width outlined button: `"📊 Reading Insights"` with bar-chart icon
- `kPrimary` border + text, transparent background

---

## 13. Screen 11 — Collections (Bookshelves)

**Source file:** `lib/screens/collections_screen.dart`

### Header

```
Collections                           [+]
```

- "Collections" — displaySmall
- `Icons.add` icon button → `_showCreateDialog()`

### Collection List (`ReorderableListView.builder`)

Each item: dark `Card` with `margin: bottom:12`

```
[📁 icon]  Favorites          [✎][🗑][⠿]
           12 books
```

| Icon | Collection Name | Count |
|---|---|---|
| ❤️ `Icons.favorite` | Favorites | 12 books |
| 📖 `Icons.menu_book` | Currently Reading | 5 books |
| 📋 `Icons.playlist_add` | To Read | 18 books |
| 🔬 `Icons.science` | Science | 8 books |
| ⭐ `Icons.star` | Motivation | 6 books |

**Leading icon container:**
- Size: 44×44 px (from `padding:8` around icon)
- Background: `kPrimary.withAlpha(20)`
- Border radius: `radiusSm` (8 px)
- Icon color: `kPrimary`

**Trailing:**
- `Icons.edit_outlined` 18 px → rename dialog
- `Icons.delete_outline` 18 px, `Colors.red[400]` → `DeleteDialog`
- `Icons.drag_handle` for reorder

**Bottom:**
- `"+ New Collection"` — purple text button, centered below list

### Empty State

- `Icons.folder_open` 56 px, muted
- "No collections yet"
- "Create your first collection to organize books"
- `ElevatedButton.icon` "Create Collection" with `Icons.add`

---

## 14. Screen 12 — Statistics

**Source file:** `lib/screens/reading_stats_screen.dart`

### Header

```
[←]  Statistics                   This Week ▾
```

- "This Week" dropdown (right-aligned) — filters chart data period

### Stat Cards (2×2 grid)

| Position | Icon | Accent Color | Value | Label |
|---|---|---|---|---|
| Top-left | `timer_outlined` | `#6C63FF` purple | 4h 32m | Time Read |
| Top-right | `auto_stories` | `#FF6584` pink | 120 | Pages Read |
| Bottom-left | `timer_outlined` | `#6C63FF` purple | 1h 12m | Daily Average |
| Bottom-right | `flag_outlined` | `#45B7D1` cyan | 2 | Books Finished |

Each card (`kDarkSurface`, `radiusLg`, elevation 0):
- Icon in small container: 8 px padding, `color.withAlpha(20)` bg, `radiusSm`
- Value: 24 px bold, accent color
- Label: bodySmall at 59% opacity

### Streak Row

```
Streak
5 days 🔥
```

- Full-width card, label + value side by side or stacked

### Weekly Bar Chart

Inside a `Card` with `Padding(all:24)`, height 180 px:

- 7 bars, one per day (Mon–Sun)
- Bar color: `kPrimary` at variable opacity (brighter = more reading)
- Bar width: 28 px
- Bar border radius: 6 px
- Value label above bar (e.g. "3", "2") — labelSmall purple
- Day label below bar — labelSmall at 47% opacity
- Bars sorted Mon → Sun

---

## 15. Screen 13 — Import & Backup

**Source file:** `lib/screens/import_screen.dart` + `lib/screens/profile_screen.dart` (Cloud Sync sheet)

### Header

```
[←]  Import & Backup
```

### Import Books Section

Title: "Import Books" — titleMedium

`ListView` of import source rows (each a `ListTile`):

| Icon | Color | Title | Subtitle |
|---|---|---|---|
| `phone_android` | `#6C63FF` | From Device | Browse files on your device |
| `link` | `#45B7D1` | From URL | Download from a web link |
| `folder_zip_outlined` | `#FFAA44` | From ZIP | Import compressed archives |
| `folder_open` | `#81C784` | From Folder | Import an entire folder |
| `drive_file_move_outlined` | `#4285F4` | Google Drive | Sync from your Drive |
| `cloud_upload_outlined` | `#007EE5` | Dropbox | Import from Dropbox |
| `add` / `more_horiz` | purple | More Sources | — |

Each leading icon:
- Container 44×44 px, `color.withAlpha(20)` bg, `radiusSm`
- Icon color = accent color, 22 px

### Backup & Sync Section

Title: "Backup & Sync" — titleMedium

| Icon | Service | Subtitle | Toggle |
|---|---|---|---|
| Google Drive logo | Google Drive | Last sync: Today, 9:41 AM | ✅ Green ON |
| Dropbox logo | Dropbox | Last sync: Yesterday | ✅ Green ON |
| `cloud` | Auto Backup | Wi-Fi only | ✅ Green ON |

Toggle switches: **green** when ON (note: differs from `kPrimary` purple used elsewhere — the design specifically shows green for these sync toggles)

### Sync Now Button

- Full-width `ElevatedButton` "Sync Now", `kPrimary` purple, at very bottom
- Padding: standard 16 px vertical

---

## 16. Screen 14 — Bookmarks

**Source file:** `lib/providers/reader_provider.dart` (state), no dedicated screen yet

### Header

```
[←]  Bookmarks                    Newest ▾
```

- "Newest" sort dropdown right-aligned

### Bookmark List

`ListView.builder`, each item:

```
Page 3
In a hole in the ground there lived a hobbit.

Page 67
...that means comfort.

Page 121
All that is gold does not glitter.

Page 165
The road goes ever on and on.
```

- Page number: labelSmall muted, smaller font
- Excerpt text: bodyMedium white, 2–3 lines, not truncated in design
- Thin `Divider` between items

### Add Bookmark Button

- Full-width `ElevatedButton` "**+ Add Bookmark**", `kPrimary` purple, pinned at bottom

---

## 17. Screen 15 — More Options

**Source file:** `lib/screens/reader/reader_screen.dart` → `_showMoreMenu()`

Dark bottom sheet triggered by reader top bar `Icons.more_vert`.

### Option Rows

| Icon | Label | Right Control |
|---|---|---|
| `phone_android` | Screen On While Reading | Toggle **ON** (purple) |
| `nights_stay` | Night Mode by Time · 10:00 PM – 6:00 AM | Toggle **ON** (purple) |
| `lock` | Lock Library | Toggle **OFF** (grey) |
| `upload_file` | Import/Export Annotations | `Icons.chevron_right` |
| `menu_book` | Reading Mode | "Scroll" + dropdown |
| `translate` | Language | "English >" |
| `accessibility` | Accessibility | `Icons.chevron_right` |
| `settings` | Advanced Settings | `Icons.chevron_right` |

**Styling:**
- Each icon in a small `radiusSm` container, `kPrimary.withAlpha(15)` bg
- Toggle: purple when ON, grey when OFF
- Time range subtitle shown below "Night Mode by Time"

---

## 18. Screen 16 — Filter & Sort

**Source file:** Not yet a dedicated screen — partial in `lib/screens/search_screen.dart`

### Header

```
[←]  Filter & Sort
```

### Sort By Section

Title: "Sort By" — titleMedium

Radio button list (single-select):

| Option | State |
|---|---|
| **Title** | ● Selected (purple filled) |
| Author | ○ |
| Recently Read | ○ |
| Date Added | ○ |

### Filter Section

Title: "Filter" — titleMedium

Checkbox list (multi-select):

| Option | State |
|---|---|
| ☑ **Books** | Checked (purple) |
| ☐ Documents | Unchecked |

### Tags Section

Title: "Tags" — titleMedium

- "All Tags" — tappable row + `Icons.chevron_right`

### Apply Button

- Full-width `ElevatedButton` "**Apply**", `kPrimary` purple, pinned at bottom
- Border radius: `radiusMd`

---

## 19. Shared Widgets & Components

### 19.1 Card Widget

Applied everywhere via `ThemeData.cardTheme`:
- `elevation: 0` (completely flat)
- `color: kDarkSurface` (`#1A1A2E`)
- `borderRadius: radiusLg` (16 px)
- `margin: EdgeInsets.zero`

**Source:** `lib/widgets/cards.dart`, `lib/theme/app_theme.dart`

---

### 19.2 Bottom Sheets

All bottom sheets share:

- `backgroundColor: kDarkSurface`
- `borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl))` (24 px top corners)
- Drag handle: 40×4 px rectangle, `rgba(255,255,255,0.16)`, `borderRadius: 2`, centered, margin vertical 12

**`FontBottomSheet`** — font family, font size stepper, line height, margins, text alignment, 4 toggle switches, "More Settings" button  
**`ThemeBottomSheet`** — theme radio list + brightness slider + auto-brightness switch  
**Import bottom sheet** — inline in `library_screen.dart`  
**Book context menu** — inline in `library_screen.dart`  
**Brightness/Keep-on sheet** — inline in `reader_screen.dart`

**Source:** `lib/widgets/bottom_sheets.dart`

---

### 19.3 Dialogs

`AlertDialog` theme:
- `backgroundColor: kDarkSurface`
- `borderRadius: radiusLg`

**`DeleteDialog`** (`lib/widgets/dialogs.dart`):
- Title + item name + confirmation message
- Actions: "Cancel" (TextButton) + "Delete" (red TextButton)

---

### 19.4 Splash Screen

**Source:** `lib/screens/splash_screen.dart`

- Full-screen `kDarkBg` background
- Centered app logo + "Poneglyph" name in large Inter bold
- Shown for 2 seconds on cold start

---

### 19.5 Onboarding Screen

**Source:** `lib/screens/onboarding/onboarding_screen.dart`

- Multi-page walkthrough (shown only once)
- Persisted via `SettingsProvider.onboardingComplete`
- Full-screen, `fullscreenDialog: true` modal route

---

### 19.6 Input Fields

`InputDecorationTheme`:
- `filled: true`, `fillColor: kDarkSurface`
- Border: none when unfocused, `kPrimary` 2 px border when focused
- `borderRadius: radiusMd` (12 px)
- `contentPadding: all(16)`
- Hint text at 39% opacity

---

### 19.7 Elevated Buttons

`ElevatedButtonThemeData`:
- Background: `kPrimary`
- Text: white
- Elevation: 0
- Padding: `symmetric(horizontal:24, vertical:16)`
- Border radius: `radiusMd` (12 px)

---

### 19.8 Toggle Switches

`SwitchThemeData`:
- Active thumb: `kPrimary`
- Active track: `kPrimary.withAlpha(60)`
- Inactive thumb: `kDarkText.withAlpha(100)`
- Inactive track: `kDarkText.withAlpha(25)`

*Exception:* Backup & Sync toggles in Import & Backup screen use **green** (design-specific override).

---

## 20. What Is Implemented vs. What Needs Work

### ✅ Fully Implemented

| Feature | Source File |
|---|---|
| Dark theme default + 5 theme modes | `app_theme.dart`, `theme_provider.dart` |
| Custom bottom nav bar (5 tabs) | `app.dart` |
| Library 3-column book grid | `library_screen.dart` |
| Filter tabs (All / Books / Collections / Authors) | `library_screen.dart` |
| Progress % badge on book covers | `library_screen.dart` → `_BookGridItem` |
| Dark cover color palette (8 tones) | `library_screen.dart` → `_coverColor()` |
| Favorite heart badge on covers | `library_screen.dart` |
| Import bottom sheet | `library_screen.dart` |
| Long-press book context menu | `library_screen.dart` |
| Authors grouped list view | `library_screen.dart` |
| Reader full-screen with tap-to-hide bars | `reader_screen.dart` |
| Reader top bar (back/TOC/bookmark/search/more) | `reader_screen.dart` |
| Reader bottom bar (slider + 6 buttons) | `reader_screen.dart` |
| Table of Contents panel (full-screen overlay) | `reader_screen.dart` |
| In-book Search panel (full-screen overlay) | `reader_screen.dart` |
| Font Settings bottom sheet | `bottom_sheets.dart` |
| Theme picker bottom sheet | `bottom_sheets.dart` |
| Brightness / Keep-on / Auto-night sheet | `reader_screen.dart` |
| Text-to-Speech screen (UI only) | `tts_screen.dart` |
| Collections / Bookshelves screen | `collections_screen.dart` |
| Statistics screen (stat cards + weekly chart) | `reading_stats_screen.dart` |
| Highlights screen (color filter + card list) | `highlights_screen.dart` |
| Import sources list | `import_screen.dart` |
| Global search screen | `search_screen.dart` |
| Profile screen (avatar + goal + menu) | `profile_screen.dart` |
| Dictionary screen | `dictionary_screen.dart` |
| Delete dialog | `dialogs.dart` |
| Splash screen | `splash_screen.dart` |
| Onboarding screen | `onboarding_screen.dart` |

---

### ⚠️ Partially Implemented (needs polish to fully match design)

| Feature | Current State | Gap |
|---|---|---|
| Book cover images | Solid-color placeholder | Design shows real covers (The Hobbit, 1984, Atomic Habits, etc.) — needs EPUB/PDF metadata or network images |
| Reading Progress circular ring | No circular ring — shows flat stats | Needs `CustomPainter` arc ring showing "67% Completed" |
| More Options sheet | Basic reading mode dropdown | Night Mode by Time, Lock Library, Annotations toggles not wired |
| Bookmarks screen | State exists in `ReaderProvider` | No dedicated full-screen bookmarks list UI |
| Filter & Sort screen | No dedicated screen | Only partial sort in library provider |
| Statistics "This Week" dropdown | Static label | Not functional — no period filter |
| Highlights Notes tab | Only Highlights tab built | Notes tab needs separate list UI |
| Collections pre-seeded names | Dynamic creation works | Default collections (Favorites, Currently Reading, etc.) not auto-created |
| Import & Backup screen | Split between ImportScreen + ProfileScreen cloud sheet | Needs unified "Import & Backup" screen matching design |
| Sync toggles (green) | Uses purple `kPrimary` toggle | Design shows green toggles specifically for sync |

---

### ❌ Not Yet Implemented (design shows it, code does not have it)

| Feature | Description |
|---|---|
| Real EPUB/PDF rendering | Current reader is lorem ipsum text only; needs `epub_view` or similar package |
| Text selection + context menu | Long-press text → popup with Highlight / Dictionary / Copy / Note |
| Search result keyword bolding | Matched word shown in bold within excerpt |
| Chapter subtitle in TOC | "An Unexpected Party" shown under "Chapter 1" as subtitle |
| Landscape two-column layout | Toggle exists in Reading Settings but layout not built |
| TTS engine audio playback | UI-only; `flutter_tts` not integrated |
| Actual backup/sync APIs | Google Drive / Dropbox OAuth flow not wired |
| Reading streak persistence | Resets on app restart; needs `SharedPreferences` persistence |
| Bookmarks screen | Full list of bookmarks with sort (Newest ▾) and "Add Bookmark" button |
| Filter & Sort screen | Full dedicated screen with Sort By radio + Filter checkboxes + Tags + Apply |
| Night Mode by Time | Auto dark mode scheduling not implemented |
| Accessibility settings screen | Navigates nowhere currently |
| Advanced Settings screen | Navigates nowhere currently |
| Language picker | Static "English" label |
| Import/Export Annotations | No file I/O for highlights |
| App lock / biometric | `SettingsProvider` stores the flag but no lock screen implemented |

---

## 21. File Map Quick Reference

```
lib/
├── app.dart                              ← AppShell + custom bottom nav bar
├── main.dart                             ← Entry, SystemUI overlay style
│
├── theme/
│   ├── app_theme.dart                    ← Color tokens, 5 ThemeData factories
│   ├── theme_provider.dart               ← Theme state manager (default: dark)
│   └── design_tokens.dart                ← Radius, spacing, elevation constants
│
├── screens/
│   ├── library/
│   │   └── library_screen.dart           ← 3-col grid, filter tabs, imports
│   ├── reader/
│   │   └── reader_screen.dart            ← Reader, top/bottom bars, TOC, search
│   ├── collections_screen.dart           ← Bookshelves / Collections
│   ├── search_screen.dart                ← Global search
│   ├── profile_screen.dart               ← Profile, reading goal, menu
│   ├── highlights_screen.dart            ← Highlights & Notes
│   ├── reading_stats_screen.dart         ← Statistics, bar chart
│   ├── import_screen.dart                ← Import source list
│   ├── tts_screen.dart                   ← Text-to-Speech player UI
│   ├── dictionary_screen.dart            ← Dictionary lookup
│   ├── splash_screen.dart                ← 2-second splash
│   └── onboarding/
│       └── onboarding_screen.dart        ← First-run walkthrough
│
├── widgets/
│   ├── bottom_sheets.dart                ← FontBottomSheet, ThemeBottomSheet
│   ├── cards.dart                        ← BookCard, ProgressCard
│   ├── dialogs.dart                      ← DeleteDialog
│   └── sheets/
│       └── book_context_menu.dart        ← Long-press book menu
│
├── providers/
│   ├── library_provider.dart             ← Book list, progress, favorites
│   ├── reader_provider.dart              ← Page nav, bookmarks, TTS state
│   ├── collections_provider.dart         ← Collection CRUD + reorder
│   ├── search_provider.dart              ← Query + results
│   ├── reading_stats_provider.dart       ← Time/pages/streak tracking
│   └── settings_provider.dart            ← All persistent user settings
│
├── models/
│   ├── book.dart                         ← Book, BookFormat, BookSource enums
│   ├── collection.dart                   ← Collection model
│   ├── highlight.dart                    ← Highlight, HighlightColor
│   └── reading_session.dart              ← Session duration/pages for stats
│
├── repositories/
│   ├── book_repository.dart              ← Abstract persistence interface
│   └── in_memory_repository.dart         ← In-memory backend (dev/demo)
│
└── utils/
    ├── helpers.dart                      ← Duration format, etc.
    └── constants.dart                    ← AppConstants (name, version)
```

---

*Last updated: 2026-07-05 · Derived from `design.jpeg` and full codebase audit*
