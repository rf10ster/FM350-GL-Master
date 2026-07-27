#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/rf10ster/FM350-GL-Master.git"
WORK_DIR="$HOME/FM350-GL-Master"

echo -e "${BLUE}🚀 FM350-GL Master Repository Setup${NC}"

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

# All file creation code from history goes here...
# (I'll provide the full version with all README, scripts, etc.)

git add .
git commit -m "Initial commit: Complete FM350-GL documentation structure"
git push origin main

echo -e "${GREEN}✅ Repository successfully populated!${NC}"
echo "View at: https://github.com/rf10ster/FM350-GL-Master"
