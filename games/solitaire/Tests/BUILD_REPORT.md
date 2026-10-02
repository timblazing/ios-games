# V1 build verification

Built on 2026-10-02 with Theos and the iPhoneOS 10.3 SDK on Linux ARM64.

- Release compilation, linking, stripping, ad-hoc signing, and Debian packaging completed.
- Binary inspection confirms ARM64, an iOS device deployment command, minimum iOS 10.0, SDK 10.3, and an embedded code signature.
- IPA ZIP integrity passed. Every bundled file matches the Debian package.
- Debian archive uses gzip control data and LZMA payload data, avoiding newer zstd package requirements.
- Actual Objective-C rules tests passed under GNUstep Base with libobjc2, including background timer pause/resume.

```text
PASS: 138143 assertions; deal, stock/recycle, moves, flips, undo, persistence, stats, victory, 2400 random steps.
```

The Linux linker emitted simulator warnings for the legacy SDK's combined-architecture text stubs. The resulting executable's deployment metadata was checked separately and targets an ARM64 iOS device.

UIKit rendering, touch interaction, installation on iOS 10.3.3, and sustained 60 FPS on A7 have not been tested here. See DEVICE_CHECKLIST.md.

Package SHA-256 hashes are in `dist/SHA256SUMS`.
