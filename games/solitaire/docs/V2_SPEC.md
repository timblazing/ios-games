# Solitaire v2 spec

Status: draft. v1 (1.0.0) installs and runs on the iPad mini 2 (iOS 10.3.3, TNS Sockport, AppSync Unified) via Legacy iOS Kit → Install IPA (ideviceinstaller).

Same target as v1: ARM64, iOS 10.0+, iPhoneOS 10.3 SDK, Theos, Objective-C, UIKit + SpriteKit, offline.

## Goals

1. Portrait support that follows device rotation.
2. Controls bar (timer, moves, buttons) moves to the bottom of the screen.
3. Undo, New game, and Settings become icon buttons.
4. One custom card design (52 faces + 1 back), with fallback to the built-in drawn cards.
5. A new home screen app icon.
6. An HTML playground for previewing card art and the app icon before building.

## 1. Portrait mode

The app is landscape-only in v1. `Info.plist` lists only the landscape orientations, and `GameViewController` returns `UIInterfaceOrientationMaskLandscape`.

Changes:

- Add `UIInterfaceOrientationPortrait` and `UIInterfaceOrientationPortraitUpsideDown` to `UISupportedInterfaceOrientations`, and return `UIInterfaceOrientationMaskAll` from `supportedInterfaceOrientations`. The app always follows the device; there is no orientation lock setting.
- Add a portrait launch image (`Launch-Portrait.png` 768×1024 and `@2x` 1536×2048) and a matching `UILaunchImages` entry. Without one, iOS 10 letterboxes or shows the landscape image during a portrait launch.
- Board layout is unchanged in both orientations: stock, waste, gap, and four foundations on the top row, seven tableau columns below. Only the controls bar moves (see §2). `GameScene` already derives card size from scene width:

  | Orientation | Scene width | Card size (pt) | Texture @2x (px) |
  |---|---|---|---|
  | Landscape | 1024 | 112 × 157 (capped) | 224 × 314 |
  | Portrait | 768 | ~94 × 131 | ~188 × 263 |

- Portrait has much more vertical room. Let tableau spacing use it, so long stacks compress less than they do in landscape.
- Rotating mid-drag or mid-selection must cancel the interaction cleanly. `didChangeSize:` already calls `cancelInteraction`, so verify this on the device.
- Rotation should not re-deal, lose state, or reset the timer.
- The texture cache is keyed by size, so rotating renders a second set of textures. Either clear the cache on size change, or raise `countLimit` so that 52 faces + back fit at both sizes (currently 110).

## 2. Controls bar at the bottom

v1 puts a 52pt black bar at the top: status (`0:28 • 0 moves`) on the left, buttons on the right.

- Move the bar to the bottom edge in both orientations. The board fills the area above it. The stock/foundation row stays at the top of the board.
- Keep it in UIKit (`GameControls`), not SpriteKit.
- Layout: status on the left, icon buttons on the right.
- The victory label must not overlap the bar.

## 3. Icon buttons

- Undo: curved back arrow. New game: circular arrow. Settings: gear.
- iOS 10 has no SF Symbols. Use either:
  - bundled template PNGs (`Resources/Icons/undo.png`, `@2x`) rendered with `UIImageRenderingModeAlwaysTemplate` so tint and disabled states still work, or
  - icons drawn in code with `UIBezierPath` (no assets, scales cleanly).
- Tap targets at least 44×44pt. Keep the existing disabled state, where Undo dims with no history.
- Set `accessibilityLabel` on each button ("Undo", "New game", "Settings").
- New game keeps its confirmation alert.

## 4. Custom card art

One design only. No card face or card back options in Settings.

### Asset layout

```
Resources/Cards/
  back.png
  AS.png 2S.png … 10S.png JS.png QS.png KS.png
  AH.png … KH.png
  AD.png … KD.png
  AC.png … KC.png
```

- Filenames are `<rank><suit>.png`. Ranks are `A 2 3 4 5 6 7 8 9 10 J Q K`, suits are `S H D C`, uppercase.
- **Fallback, per card:** if a face PNG is missing or fails to load, draw that card with the v1 renderer (rank text + suit emoji). If `back.png` is missing, draw the v1 default back (blue lattice pattern). So an empty `Resources/Cards/` gives exactly the v1 look, and a partial set works while you're still designing.
- Never crash on bad art. Log missing filenames once at launch.
- Faces and back get the same rounded clip, shadow, and 2pt inset as v1 backs in `CardNode`.

### Removals

- Remove the Card Back section and its footer text from Settings, and the `cardBack` user default.
- Remove `Resources/CardBacks/` (burgundy, default, graphite). Fold the default lattice into the drawn fallback, or ship it as the initial `back.png`.
- Settings keeps only Statistics.

### Format: PNG

| Format | Verdict |
|---|---|
| **PNG** | **Use this.** Lossless, crisp edges and text, native on iOS 10. |
| JPEG | Avoid. Compression artifacts show around corner indices and line art. |
| SVG | Not loadable at runtime on iOS 10 (no native SVG in UIKit). Fine as your source format: design in SVG/Figma and export PNGs. A build script could rasterize with `rsvg-convert`. |

Export size: **250 × 350 px** (5:7, the same aspect as the in-game card's 1.4 ratio). That covers the largest @2x render (~224 × 314) with a little headroom. Art must be exactly 5:7, because it's aspect-filled and other ratios get cropped.

### Performance

53 images is not a problem on the A7:

- Decoded RGBA at 250×350 ≈ 350 KB per card → ~18 MB for the full set. The iPad mini 2 has 1 GB RAM.
- Textures are rendered once per card and size, then cached. Drawing cost during play doesn't change from v1.
- The risk is a hitch the first time each card is flipped, because the PNG is decoded on demand. Fix: preload and render all textures on a background queue at launch. Upload to SpriteKit on the main thread.
- Keep PNGs reasonably small (run them through `pngcrush` or `oxipng`). Don't ship 4K art. It wastes decode time and memory for no visible gain.
- Optional later: pack into an `SKTextureAtlas` if profiling shows a need.

### Design guidance

- In the tableau only the **top ~24% of a card** shows for face-up cards, and less when a long stack compresses. The top-left rank + suit index must read clearly in that strip.
- The bottom-right index is upside down and only visible on the top card of a pile.
- Red/black must be distinguishable at a glance. Moves depend on alternating colors.
- The app clips rounded corners, so the PNG can be a plain rectangle, with or without transparency.

## 5. App icon

Replace the generated v1 icon with your own design.

### Source and sizes

- Design one master: `Resources/Icon/icon-1024.png`, 1024×1024, square, **no transparency** (fill the corners), sRGB. iOS applies the rounded mask itself, so don't pre-round the corners.
- The master is the source of truth. A script generates the bundle sizes, replacing the hand-generated icons from `scripts/generate-assets.py`:

  | File | Pixels | Used for |
  |---|---|---|
  | `Icon-76@2x.png` | 152 | **Home screen (iPad mini 2)** |
  | `Icon-40@2x.png` | 80 | Spotlight |
  | `Icon-29@2x.png` | 58 | Settings |
  | `Icon-83.5@2x.png` | 167 | iPad Pro home screen |
  | `Icon-76.png`, `Icon-40.png`, `Icon-29.png` | 76, 40, 29 | Non-Retina iPads |

- Add `scripts/make-icons.sh`, using macOS `sips -z <px> <px> icon-1024.png --out Resources/Icon-….png`. Run it before `make package`. If the master is missing, keep the existing icons.
- The `Info.plist` `CFBundleIcons~ipad` entries don't change, since filenames stay the same.
- Design for 152px. Fine detail disappears at that size, and Spotlight/Settings go down to 80px and 58px. Bold shapes, few colors.
- After installing, iOS may show the old icon from cache. Run `uicache` as mobile, or respring.

## 6. Design playground (HTML)

A static, zero-dependency page for previewing card art and the app icon on the Mac before building.

Location: `tools/design-playground/index.html` (single file, inline CSS/JS). Open with `open tools/design-playground/index.html`. No server or build step. Nothing is uploaded; images stay in the browser.

### Cards tab

- **Load art:** a folder picker (`<input type="file" webkitdirectory>`) or drag-and-drop for a folder containing the faces and `back.png`. Pointing it at `Resources/Cards/` should just work.
- **Validation panel:** lists missing or unexpected filenames against the 53 expected names, plus files that aren't 5:7 or are below 250×350.
- **Full deck grid:** all 52 faces + back, by suit.
- **Simulated board:** a black canvas sized to the iPad mini 2 in points (1024×768 landscape / 768×1024 portrait toggle), with the v2 bottom controls bar mockup (status + three icon placeholders). It uses the same layout math as `GameScene.m`: margin `max(14, w*0.025)`, card width `min(112, (w - 2*margin - 72) / 7)`, height = width × 1.4, tableau offsets 0.24h face-up / 0.105h face-down, 7pt corner radius, 2pt inset, drop shadow. It deals a random board using the loaded art. Add a comment pointing at `GameScene.m` so the two stay in sync.
- **Stress views:** one column with a 13-card face-up run, plus a compressed version, to check index legibility at worst-case overlap.
- **Zoom:** 1× (actual points) and 2× (device pixels), plus a "physical size" mode approximating the mini 2's 326 ppi on the Mac screen.
- **Fallback preview:** missing cards render the way the app's fallback would (rank text + suit emoji, lattice back), so a partial set previews accurately.

### App icon tab

- **Load:** a file picker or drop target for `icon-1024.png`.
- **Validation:** warns if the file isn't square, is smaller than 1024×1024, or has any transparent pixels.
- **Size strip:** the icon downscaled to 152, 80, and 58 px, each shown at 1× and at actual on-device size, to check legibility at small sizes.
- **Home screen mock:** an iOS 10-style iPad home screen (768×1024 points, portrait and landscape toggle) with the icon in the grid among placeholder icons. It uses the iOS 7–10 rounded-square mask (approximate with `border-radius: 22.37%` or a superellipse SVG clip) and the "Solitaire" label below in white with a text shadow. Switchable wallpaper: dark, light, and a custom image upload.
- **Side-by-side:** the current v1 icon (`Resources/Icon-76@2x.png`) next to the new one, for comparison.

## Other v2 cleanup (from v1 device testing)

- Settings sheet: "Current win streak" sits below the fold in landscape. Make sure the sheet scrolls or fits. This gets easier once the Card Back section is removed.
- Remove the non-interactive "Draw mode: Draw 1" row (the Game section) from Settings. Draw 1 stays the only mode. The `drawMode` user default can go too.
- Bump `control` Version and `CFBundleShortVersionString` to 2.0.0.
- Update `README.md` (card backs section → card art + icon workflow).
- Update `Tests/DEVICE_CHECKLIST.md` with portrait, rotation, bottom bar, icon buttons, custom art + fallback, and new app icon checks.

## Decisions

- "Top header row" means the controls bar only. The stock/waste/foundation row stays at the top of the board.
- One card design, no options. Missing art falls back to v1 drawn cards.
- New game icon is a circular arrow.
- Orientation always follows the device.
- No Draw 3. The Draw mode row is removed from Settings.

## Out of scope (unchanged from v1)

Networking, accounts, ads, analytics, achievements, multiplayer, audio, haptics, Vegas scoring, Draw 3.
