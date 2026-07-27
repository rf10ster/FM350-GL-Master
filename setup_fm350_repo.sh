#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_URL="https://github.com/rf10ster/FM350-GL-Master.git"
WORK_DIR="$HOME/FM350-GL-Master"

echo -e "${BLUE}FM350-GL Master Repository Setup (safe bootstrap)${NC}"

# Clone or use existing
if [ -d "$WORK_DIR/.git" ]; then
    cd "$WORK_DIR"
    echo -e "${GREEN}✓ Using existing repository${NC}"
else
    git clone "$REPO_URL" "$WORK_DIR"
    cd "$WORK_DIR"
    echo -e "${GREEN}✓ Repository cloned${NC}"
fi

# Create full directory structure
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

# Safe bootstrap: only create files that do not exist.
create_if_missing "CHANGELOG.md" "# Changelog"
create_if_missing "README.md" "# FM350-GL Master Documentation"
create_if_missing "ARCHITECTURE.md" "# FM350-GL Architecture"
create_if_missing "04_knowledge_base/troubleshooting/decision-tree.md" "# Troubleshooting Decision Tree"

if [ -d "00_current_config/scripts" ]; then
    chmod +x 00_current_config/scripts/*.sh 2>/dev/null || true
fi

echo
echo -e "${BLUE}Safe bootstrap complete.${NC}"
echo "No existing file was overwritten."
echo "Review changes with: git status"
echo "Commit manually when ready."

exit 0
