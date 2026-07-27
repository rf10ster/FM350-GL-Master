#!/bin/bash
# deploy_fm350_setup.sh - FM350-GL Master Documentation Safe Deployment
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
ROOT_DIR="$HOME/FM350-GL-Master"
echo -e "${BLUE}=== FM350-GL Master Documentation Safe Deployment ===${NC}"

if [ -d "$ROOT_DIR/.git" ]; then
  cd "$ROOT_DIR"
  echo -e "${GREEN}Using existing repo at $ROOT_DIR${NC}"
else
  mkdir -p "$ROOT_DIR"; cd "$ROOT_DIR"; git init
  echo -e "${GREEN}Initialized new repo at $ROOT_DIR${NC}"
fi

mkdir -p 00_current_config/{guides,scripts,photos,configs}
mkdir -p 01_4pda_research/{fm350_main_thread,nc2312_thread,solutions_database}
mkdir -p 02_firmware/{comparison,tools,backups,files/{official,custom},guides}
mkdir -p 03_nc2312_integration/{hardware,installation,configuration,testing,optimization}
mkdir -p 04_knowledge_base/{at_commands,usb_modes,lifecycle,troubleshooting}
mkdir -p 05_community/{4pda_posts,github_gists}

create_if_missing() {
  local path="$1"
  local content="$2"

  if [ -e "$path" ]; then
    echo -e "${YELLOW}skip:${NC} $path already exists"
    return 0
  fi

  printf "%s\n" "$content" > "$path"
  echo -e "${GREEN}create:${NC} $path"
}

# Create only missing baseline files; never overwrite existing docs.
create_if_missing "README.md" "# FM350-GL Master Documentation"
create_if_missing "CHANGELOG.md" "# Changelog"
create_if_missing "ARCHITECTURE.md" "# FM350-GL Architecture"
create_if_missing "04_knowledge_base/troubleshooting/decision-tree.md" "# Troubleshooting Decision Tree"

if [ -e "00_current_config/scripts/check_setup_stage.sh" ]; then
  chmod +x 00_current_config/scripts/*.sh 2>/dev/null || true
fi

echo
echo -e "${GREEN}Safe deployment completed.${NC}"
echo "Existing content was preserved."
echo "Review with: git status"