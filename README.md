# ios-games

Retro iOS games: small native games for a jailbroken iPad mini 2 (A7, iOS 10.3.3, TNS Sockport, rootful semi-untethered).

| Game | Status |
|---|---|
| [Solitaire](games/solitaire/) | v2 built ([spec](games/solitaire/docs/V2_SPEC.md)); device checks pending |

## Stack

Every game uses the same stack: Objective-C, UIKit, and SpriteKit, built with Theos on macOS (ARM64, iOS 10.0 deployment target, iPad only). Current Xcode can't link against the iPhoneOS 10.3 SDK, so games build with the 16.5 SDK that the Theos installer provides; see [Solitaire's build notes](games/solitaire/README.md#build). Modern iOS devices are not a target. See [docs/ipad-mini-2-ios10-game-development-guide.md](docs/ipad-mini-2-ios10-game-development-guide.md).

## Layout

- `games/<name>/` holds one self-contained Theos project: its own `Makefile`, `control`, `Resources/`, `scripts/`, tests, and build output. Build and package from inside that folder.
- `docs/` holds notes shared across games.
- `.clang-format` applies to all games.

## Install on the iPad

With TNS Sockport active and AppSync Unified installed, use Legacy iOS Kit: `./restore.sh` → App Management → Install IPA (ideviceinstaller) → pick `games/<name>/dist/*.ipa`.
