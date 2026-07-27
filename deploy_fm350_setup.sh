#!/bin/bash
# deploy_fm350_setup.sh - FM350-GL Master Documentation Full Deployment
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
ROOT_DIR="$HOME/FM350-GL-Master"
echo -e "${BLUE}=== FM350-GL Master Documentation Deployment ===${NC}"

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

cat > README.md << 'EOF'
# FM350-GL Master Documentation
Полная документация по настройке Fibocom FM350-GL на OpenWrt.
EOF

cat > CHANGELOG.md << 'EOF'
# Changelog
## [1.0.0] - Initial structure
EOF

cat > .gitignore << 'EOF'
.DS_Store
*.log
*.tmp
*.bak
.vscode/
.idea/
*.bin
*.hex
EOF

cat > LICENSE << 'EOF'
MIT License - FM350-GL Master Documentation
EOF

cat > 00_current_config/scripts/check_setup_stage.sh << 'EOF'
#!/bin/bash
echo "FM350-GL Setup Stage Checker"
lsusb | grep "2cb7" || echo "Modem not detected"
ip link show | grep wwan || echo "No wwan interface"
ping -c1 8.8.8.8 &>/dev/null && echo "Internet OK" || echo "No Internet"
EOF

cat > 00_current_config/scripts/usb_mode_switch.sh << 'EOF'
#!/bin/bash
echo "1) Standard  2) Fastboot"
read -p "Choose: " c
[ "$c" = "1" ] && echo 'AT+QCFG="usbnet",0' > /dev/ttyUSB2
[ "$c" = "2" ] && echo 'AT+QCFG="usbnet",3' > /dev/ttyUSB2
EOF

cat > 00_current_config/scripts/monitor_connection.sh << 'EOF'
#!/bin/bash
while true; do
  clear
  date
  lsusb | grep 2cb7
  ip -br addr show | grep wwan
  ping -c1 -W2 8.8.8.8 &>/dev/null && echo Online || echo Offline
  sleep 5
done
EOF

chmod +x 00_current_config/scripts/*.sh

cat > 04_knowledge_base/at_commands/basic_commands.md << 'EOF'
# Basic AT Commands
ATI, AT+CGMM, AT+CGMR, AT+CGSN, AT+CSQ, AT+COPS?, AT+CREG?, AT+QCFG
EOF

cat > 04_knowledge_base/troubleshooting/common_issues.md << 'EOF'
# Common Issues
1. Modem not detected -> check lsusb, power, mode
2. No internet -> check APN, AT+CREG?, AT+CSQ
3. Low speed -> check signal, bands, antennas
EOF

git add .
git commit -m "Initial commit: FM350-GL Master documentation structure" || echo "Nothing to commit"

echo -e "${GREEN}Done. Now run:${NC}"
echo "cd $ROOT_DIR && git remote add origin https://github.com/rf10ster/FM350-GL-Master.git"
echo "git branch -M main && git push -u origin main"