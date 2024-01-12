#!/bin/bash

# The website is built using MkDocs with the Material theme.
# https://squidfunk.github.io/mkdocs-material/
# It requires Python to run.
# Install the packages with the following command:
# python3 -m venv ~/mkdocs
# source ~/mkdocs/bin/activate
# pip install mkdocs mkdocs-material mdx_truly_sane_lists

if [[ "$1" = "--local" ]]; then local=true; fi

if ! [[ ${local} ]]; then
  set -ex

  REPO="git@github.com:uber/simple-store.git"
  DIR=temp-clone

  # Delete any existing temporary website clone
  rm -rf ${DIR}

  # Clone the current repo into temp folder
  git clone --depth 1 ${REPO} ${DIR}

  # Move working directory into temp folder
  cd ${DIR}
  # Fetch for gh-deploy
  git fetch origin gh-pages:gh-pages

  # Generate the API docs
  ./gradlew dokkaHtmlMultiModule --no-configuration-cache
fi

# Copy in special files that GitHub wants in the project root.
cp CHANGELOG.md docs/changelog.md
cp CONTRIBUTING.md docs/contributing.md
cp CODE_OF_CONDUCT.md docs/code-of-conduct.md
cp README.md docs/index.md

# Build the site and push the new files up to GitHub
if ! [[ ${local} ]]; then
  mkdocs gh-deploy
else
  mkdocs serve
fi

# Delete our temp folder
if ! [[ ${local} ]]; then
  cd ..
  rm -rf ${DIR}
fi