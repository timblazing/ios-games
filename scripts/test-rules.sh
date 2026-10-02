#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ $(uname -s) == Darwin ]]; then
  clang -fobjc-arc -framework Foundation Application/Game/*.m Tests/RulesTests.m -o Tests/rules-tests
else
  # Requires GNUstep Base built for libobjc2, with ARC and the modern runtime.
  read -r -a objc_flags <<< "$(gnustep-config --objc-flags)"
  read -r -a base_libs <<< "$(gnustep-config --base-libs)"
  clang -fobjc-arc "${objc_flags[@]}" Application/Game/*.m Tests/RulesTests.m "${base_libs[@]}" -o Tests/rules-tests
fi
Tests/rules-tests
