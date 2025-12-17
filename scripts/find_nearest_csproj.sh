#!/usr/bin/env bash
set -euo pipefail

# Reads changed file paths from stdin
# Writes found .csproj paths to cs_proj_paths.txt
# Exits 1 if any file has no corresponding .csproj upwards

: > cs_proj_paths.txt

find_csproj_up() {
  local path="$1"
  local dir
  dir=$(dirname "$path")

  while true; do
    # Find .csproj in this directory (relative)
    matches=()
    while IFS= read -r f; do
      matches+=("$f")
    done < <(find "$dir" -maxdepth 1 -mindepth 1 -name '*.csproj' -printf '%P\n')

    if [ "${#matches[@]}" -gt 0 ]; then
      echo "${dir}/${matches[0]}"
      return 0
    fi

    if [ "$dir" = "." ] || [ "$dir" = "/" ]; then
      break
    fi

    dir=$(dirname "$dir")
  done

  return 1
}

missing=0

while IFS= read -r file; do
  [ -z "$file" ] && continue
  echo "Processing changed file: $file"

  if csproj_path=$(find_csproj_up "$file"); then
    echo "  Found .csproj: $csproj_path"
    echo "$csproj_path" >> cs_proj_paths.txt
  else
    echo "  ERROR: No .csproj found for $file when walking up directories."
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  echo "At least one changed file has no corresponding .csproj. Failing."
  exit 1
fi

echo "All found .csproj paths:"
sort -u cs_proj_paths.txt || true
