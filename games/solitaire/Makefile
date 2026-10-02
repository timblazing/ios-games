ARCHS = arm64
TARGET = iphone:clang:10.3:10.0
INSTALL_TARGET_PROCESSES = Solitaire

include $(THEOS)/makefiles/common.mk
APPLICATION_NAME = Solitaire
Solitaire_FILES = $(wildcard Application/*.m Application/Game/*.m Application/Scenes/*.m Application/Nodes/*.m Application/UI/*.m)
Solitaire_FRAMEWORKS = UIKit Foundation SpriteKit CoreGraphics
Solitaire_CFLAGS = -fobjc-arc -fno-exceptions -fno-objc-exceptions -Wall -Wextra -Wno-unused-parameter
Solitaire_RESOURCE_DIRS = Resources
Solitaire_INFOPLIST = Resources/Info.plist
Solitaire_CODESIGN_FLAGS = -SResources/Entitlements.plist
include $(THEOS_MAKE_PATH)/application.mk

after-package::
	@echo "Debian package ready in packages/. Run scripts/package-ipa.sh for an IPA."
