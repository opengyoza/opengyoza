#!/usr/bin/env bash
set -euo pipefail

HEADER="This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0."

base_ref=${1:-upstream-base}
if ! git rev-parse --verify "${base_ref}" >/dev/null 2>&1; then
  if git rev-parse --verify "v1.6.4" >/dev/null 2>&1; then
    base_ref="v1.6.4"
  else
    base_ref=$(git rev-list --max-parents=0 HEAD | tail -n 1)
  fi
fi

mapfile -t candidates < <(git diff --name-only --diff-filter=A "${base_ref}" -- \
  '*.go' '*.sh' '*.py' '*.rb' '*.js' '*.ts' '*.tsx' '*.jsx' '*.c' '*.h' '*.cpp' '*.hpp' '*.rs' '*.java')

missing=()
for file in "${candidates[@]}"; do
  case "${file}" in
    vendor/*|ui-v2/*|website/*)
      continue
      ;;
  esac
  if ! grep -q "${HEADER}" "${file}"; then
    missing+=("${file}")
  fi
done

if [ ${#candidates[@]} -eq 0 ]; then
  echo "No new source files to audit for MPL headers."
  exit 0
fi

if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing MPL-2.0 header in newly added files:"
  printf '  - %s\n' "${missing[@]}"
  exit 1
fi

echo "All newly added source files include the MPL-2.0 header."
