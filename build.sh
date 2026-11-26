#!/usr/bin/env sh
# Build index.html (standalone page for GitHub Pages) from src/page.html.
# src/page.html has no <!doctype>/<head>/<body>: that is the format the Claude Artifact publisher expects,
# so the same file is published as the Artifact as-is, and wrapped here for the plain web.
set -e
cd "$(dirname "$0")"
{
  printf '<!doctype html>\n<html lang="zh-Hant">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n</head>\n<body>\n'
  cat src/page.html
  printf '\n</body>\n</html>\n'
} > index.html
echo "built index.html"
