# iPad mini 2 (iOS 10.3.3) Game Development Guide

> Original research notes, kept for reference. Where this disagrees with [AGENTS.md](../AGENTS.md), AGENTS.md wins. In particular, games now build against the iPhoneOS 16.5 SDK with an iOS 10.0 deployment target, because current Xcode can't link against the 10.3 SDK. Solitaire also ships one card design rather than themes.

## Recommended default stack

For a **jailbroken iPad mini 2 on iOS 10.3.3**, the best general-purpose stack is:

- **Theos**
- **Objective-C**
- **UIKit**
- **SpriteKit**
- **iPhoneOS 10.3 SDK**
- Package/install as **IPA** or **DEB**

This is the best fit for small retro-style games because it stays close to the native Apple stack of the iOS 10 era, avoids modern Xcode deployment-target restrictions, and performs well on the iPad mini 2's A7 hardware.

---

## Best stack by game type

| Game type | Recommended stack | Notes |
|---|---|---|
| Sudoku, word games, simple puzzles | UIKit + Objective-C | SpriteKit is optional; standard views are enough |
| Solitaire, card games | SpriteKit + Objective-C | Great for drag/drop, card animations, layering |
| Flappy Bird, Breakout, Pong | SpriteKit + Objective-C | Excellent fit for simple 2D arcade gameplay |
| 8-ball pool | SpriteKit + Objective-C | Built-in 2D physics makes this straightforward |
| Snake, Tetris-style games | SpriteKit + Objective-C | Simple grid/game-loop implementation |
| 2D platformers | SpriteKit + Objective-C | Good sprite animation, collision and camera support |
| Top-down racing | SpriteKit + Objective-C | Good for arcade racers and simple AI |
| Pseudo-3D / Mode-7 racing | SpriteKit + custom math/rendering | More work, but realistic on the hardware |
| Real 3D racing | SceneKit or legacy Unity | Only use if you really need full 3D |
| HTML/JS games | Phaser 3 + WKWebView | Best option if you strongly prefer TypeScript/JavaScript |
| Cross-platform C++ games | Cocos2d-x | Viable but more complexity than SpriteKit |

---

# 1. Native 2D: Theos + SpriteKit

This should be your **default choice**.

## Why

SpriteKit gives you:

- sprites
- touch input
- animations
- particles
- texture atlases
- scenes
- cameras
- 2D physics
- collision detection
- sound
- smooth 60 FPS rendering

It is especially well suited to the kinds of games you mentioned.

### Suggested architecture

```text
MyGame/
├── Makefile
├── control
├── Resources/
│   ├── Images/
│   ├── Sounds/
│   └── Fonts/
│
├── AppDelegate.h
├── AppDelegate.m
│
├── GameViewController.h
├── GameViewController.m
│
├── Scenes/
│   ├── MenuScene.h
│   ├── MenuScene.m
│   ├── GameScene.h
│   └── GameScene.m
│
├── Game/
│   ├── GameState.h
│   ├── GameState.m
│   ├── Player.h
│   └── Player.m
│
└── Nodes/
    ├── CardNode.h
    ├── BallNode.h
    └── ...
```

Keep **game rules separate from SpriteKit rendering** where practical.

---

# 2. UIKit-only games

For games that are mostly interface and logic, you do not need SpriteKit.

Good examples:

- Sudoku
- crossword-style games
- Wordle-like games
- 2048
- Minesweeper
- memory matching
- trivia
- simple board games

Use:

```text
Objective-C
UIKit
Auto Layout
NSUserDefaults
```

This will give you the simplest codebase and lowest overhead.

---

# 3. SpriteKit physics games

SpriteKit is particularly strong for games such as:

- pool
- pinball
- air hockey
- brick breaker
- pachinko
- physics puzzles

Useful SpriteKit classes:

```text
SKScene
SKSpriteNode
SKPhysicsBody
SKPhysicsWorld
SKAction
SKTexture
SKTextureAtlas
SKEmitterNode
```

For an **8-ball pool game**, SpriteKit is probably the best option on this device.

You can model:

- balls as circular physics bodies
- rails as edge physics bodies
- cue shots as impulses
- friction using physics properties
- pockets as collision/contact zones

---

# 4. 2D arcade games

For:

- Flappy Bird
- Pong
- Breakout
- Snake
- endless runners
- platformers
- shoot-em-ups

Use SpriteKit.

A typical game loop can live in:

```objective-c
- (void)update:(NSTimeInterval)currentTime
{
    // game logic
}
```

Use `SKAction` for most animation instead of manually changing positions every frame.

---

# 5. Racing games

## Top-down racing

SpriteKit is a very good fit.

You can implement:

- track sprites
- checkpoints
- lap timing
- simple opponent AI
- acceleration/braking
- drifting
- collision
- power-ups

This is likely the best racing style for the iPad mini 2.

---

## Pseudo-3D racing

A retro racer inspired by:

- OutRun
- F-Zero
- early Mario Kart
- SNES Mode-7 games

is also possible.

You can fake depth using:

- scaled sprites
- perspective math
- road-segment projection
- horizon movement
- parallax backgrounds

This will look much more impressive than a normal top-down racer while remaining much lighter than real 3D.

---

## Real 3D racing

If you want actual 3D:

### Option A: SceneKit

SceneKit was available during the iOS 10 era and is Apple's native 3D framework.

Use it for:

- simple low-poly environments
- kart models
- cameras
- lights
- basic physics

Recommended only if you specifically want real 3D.

### Option B: legacy Unity

Unity versions from the iOS 10 era can target the device, but this requires maintaining an old Unity/Xcode toolchain.

That is much more cumbersome than SpriteKit or SceneKit.

Use it only if the project becomes substantially more ambitious.

---

# 6. Phaser / TypeScript option

If you would rather stay close to your existing web-development workflow, another strong option is:

```text
TypeScript
Phaser 3
HTML/CSS
WKWebView
Theos native wrapper
```

This can work well for:

- Solitaire
- Flappy Bird
- puzzle games
- platformers
- top-down racing
- pool
- card games

## Advantages

- TypeScript
- familiar web tooling
- extremely fast iteration
- easy asset management
- lots of examples/tutorials
- game logic can potentially be reused elsewhere

## Disadvantages

- older Safari/WKWebView limitations
- WebGL compatibility must be tested
- audio can behave differently on old iOS
- native SpriteKit will generally integrate and perform more predictably

For this iPad specifically, I would still choose **native SpriteKit first**.

Use Phaser if writing Objective-C becomes the part of the project you dislike most.

---

# 7. Cocos2d-x

Cocos2d-x is another historically appropriate choice for iOS 10-era games.

Stack:

```text
C++
Cocos2d-x
OpenGL ES
```

Good for:

- platformers
- arcade games
- tile games
- action games
- cross-platform projects

## Advantages

- mature game-engine architecture
- good performance
- cross-platform
- lots of historical examples

## Disadvantages

- C++
- more setup
- older ecosystem
- unnecessary for most small personal games

I would choose SpriteKit over Cocos2d-x unless you specifically want C++ or cross-platform support.

---

# Development tooling

## Theos

Use Theos as the build/package system.

Typical workflow:

```text
source code
   ↓
Theos
   ↓
clang
   ↓
iOS 10 SDK
   ↓
.app
   ↓
IPA / DEB
   ↓
jailbroken iPad
```

Theos is especially useful because current Xcode versions no longer target iOS 10 directly.

---

## iOS 10 SDK

Use:

```text
iPhoneOS10.3.sdk
```

Keep the project deployment target at or below your installed iOS version.

---

# Objective-C vs Swift

For iOS 10, use:

```text
Objective-C
```

rather than Swift.

Reasons:

- no separate Swift runtime concerns
- historically native to the platform
- very compatible with Theos
- works cleanly with UIKit/SpriteKit
- easier deployment to old jailbroken systems

Swift is possible, but it adds unnecessary compatibility overhead.

---

# Useful native frameworks

## SpriteKit

Primary 2D engine.

```text
SpriteKit.framework
```

Use for rendering, input, animation and physics.

## UIKit

Use for:

- menus
- settings
- dialogs
- navigation
- app lifecycle

## GameplayKit

Useful for:

- state machines
- randomization
- pathfinding
- entity/component architecture
- simple AI

You will not need it for every game.

## AVFoundation

Use when you need more control over:

- music
- sound effects
- audio playback

For simple games, SpriteKit's sound actions may be enough.

## SceneKit

Use only for actual 3D projects.

---

# Recommended game progression

If the goal is to learn the stack while making useful games, I would build them in roughly this order:

### 1. Flappy Bird clone

Learn:

- SpriteKit scene
- sprites
- touch input
- movement
- collisions
- scoring
- restarting

### 2. Solitaire

Learn:

- complex game state
- drag-and-drop
- layering
- animations
- custom card assets
- save state

### 3. Breakout or Pong

Learn:

- SpriteKit physics
- impulses
- contact delegates

### 4. 8-ball pool

Learn:

- more advanced physics
- trajectory visualization
- turn logic
- collisions
- friction

### 5. Top-down racer

Learn:

- cameras
- world coordinates
- AI
- checkpoints
- lap logic
- acceleration

### 6. Retro pseudo-3D racer

Learn:

- custom rendering math
- scaling/perspective
- road projection
- sprite depth

---

# Asset workflow

Recommended asset formats:

```text
PNG     sprites/UI
JPG     large static backgrounds if transparency is unnecessary
CAF     short sound effects
M4A     music
TTF     custom fonts
```

For sprites, create textures around the actual size they will appear on screen.

Avoid loading huge modern-resolution assets and scaling them down at runtime.

The iPad mini 2 display is Retina, so prepare assets appropriately while keeping texture memory reasonable.

---

# Custom card / sprite themes

For games such as Solitaire, keep user-customizable assets outside the gameplay logic.

Example:

```text
Resources/
└── Themes/
    ├── Default/
    │   ├── card-back.png
    │   └── background.png
    │
    ├── Dark/
    │   ├── card-back.png
    │   └── background.png
    │
    └── Custom/
        ├── card-back.png
        └── background.png
```

Store the selected theme using:

```text
NSUserDefaults
```

This makes it easy to add additional themes later.

---

# Performance rules for the iPad mini 2

The A7 is capable, but design around its age.

Prefer:

- 2D rendering
- texture atlases
- limited particle counts
- static backgrounds
- reusable nodes
- simple shaders or no shaders
- 60 FPS when practical

Avoid:

- enormous textures
- excessive transparency layers
- modern GPU-heavy shaders
- large particle effects
- huge numbers of physics bodies
- unnecessary per-frame object allocation

For simple 2D games, this device should still be quite capable.

---

# Recommended overall stack

For most of the games you described, use:

```text
Theos
├── Objective-C
├── UIKit
├── SpriteKit
├── GameplayKit (optional)
└── iPhoneOS10.3 SDK
```

Use:

```text
SceneKit
```

only when you need actual 3D.

Use:

```text
Phaser 3 + TypeScript + WKWebView
```

if you strongly prefer web development over Objective-C.

Use legacy Unity only for a significantly more ambitious 3D project.

---

# Final recommendation

For this particular jailbroken iPad mini 2, I would make **SpriteKit the engine for almost everything**.

It is a particularly good match for:

- Solitaire
- Flappy Bird
- pool
- Sudoku
- arcade games
- platformers
- top-down racers

The resulting stack is small, native, historically appropriate for iOS 10, and avoids dragging a large legacy game engine into small projects.

**Default stack:**

```text
Objective-C + SpriteKit + UIKit
built with Theos + iOS 10.3 SDK
```

That is the stack I would standardize on for a collection of custom retro iPad games.
