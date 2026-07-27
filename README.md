# FM350-GL Master Documentation

Полная документация по настройке и эксплуатации модема Fibocom FM350-GL на OpenWrt с адаптером NC2312.

EN: Complete documentation for Fibocom FM350-GL setup and operation on OpenWrt with NC2312 adapter.

## 📋 Структура проекта

```
FM350-GL-Master/
├── 00_current_config/       # Текущая конфигурация
│   ├── guides/              # Пошаговые инструкции
│   ├── scripts/             # Рабочие скрипты
│   ├── photos/              # Фотографии установки
│   └── configs/             # Конфигурационные файлы
├── 01_4pda_research/        # Исследование 4PDA
│   ├── fm350_main_thread/
│   ├── nc2312_thread/
│   └── solutions_database/
├── 02_firmware/             # Прошивки
│   ├── comparison/
│   ├── tools/
│   ├── backups/
│   ├── files/
│   └── guides/
├── 03_nc2312_integration/   # Интеграция NC2312
│   ├── hardware/
│   ├── installation/
│   ├── configuration/
│   ├── testing/
│   └── optimization/
├── 04_knowledge_base/       # База знаний
│   ├── at_commands/
│   ├── usb_modes/
│   ├── lifecycle/
│   └── troubleshooting/
└── 05_community/            # Материалы комьюнити
    ├── 4pda_posts/
    └── github_gists/
```

## 🚀 Быстрый старт

```bash
cat ARCHITECTURE.md
cat 00_current_config/guides/01-preflight-checks.md
cat 00_current_config/guides/02-initial-setup.md
cat 00_current_config/guides/07-backup-and-restore-after-flash.md
./00_current_config/scripts/check_setup_stage.sh
./00_current_config/scripts/usb_mode_switch.sh
./00_current_config/scripts/monitor_connection.sh
```

## 🧭 Каноничный путь (v1.1)

1. Прочитать архитектуру и правила профилей: `ARCHITECTURE.md`
2. Выполнить preflight: `00_current_config/guides/01-preflight-checks.md`
3. Настроить через ATC primary: `00_current_config/guides/02-initial-setup.md`
4. При необходимости использовать DHCP fallback: `00_current_config/configs/uci-dhcp-profile.conf`

EN:

1. Read canonical architecture: `ARCHITECTURE.md`
2. Run preflight: `00_current_config/guides/01-preflight-checks.md`
3. Apply ATC primary setup: `00_current_config/guides/02-initial-setup.md`
4. Use DHCP fallback only if needed: `00_current_config/configs/uci-dhcp-profile.conf`

## ⚙️ Reference Configs

- `00_current_config/configs/uci-atc-profile.conf`
- `00_current_config/configs/uci-dhcp-profile.conf`

## 🧾 Field Records

- `00_current_config/records/2026-07-27-exp-001-atc-stabilization.md`
- `00_current_config/records/2026-07-27-inc-001-session-failed.md`
- Use templates from `00_current_config/guides/03-incident-report-template.md` and `00_current_config/guides/04-experiment-record-template.md`

## 💾 Backup and Restore

- Firmware backup/restore runbook:
    - `00_current_config/guides/07-backup-and-restore-after-flash.md`
- Backup script:
    - `00_current_config/scripts/create_router_backup.sh`
- Restore helper script:
    - `00_current_config/scripts/restore_router_backup.sh`

## 🧪 Marker-Gated A/B Runner

For controlled ATC baseline-vs-candidate tests use:

```bash
sh 00_current_config/scripts/run_exp_ab_marker_series.sh \
    fm350-router 20 12 EXP029 5 5
```

Arguments:

1. router alias
2. max trials
3. marker window (seconds)
4. experiment tag (artifact prefix)
5. minimum informative BASE windows (optional, default 0)
6. minimum informative CAND windows (optional, default 0)

Method guarantees:

- marker-gated counting between START/END boundaries
- USB-confounder invalidation (`valid=0`)
- informative filter (`informative=1` only if churn/signal exists)
- silent-window flag (`silent=1` for empty/no-signal windows)
- baseline restore after every run with hash verification

Outputs:

- CSV: `00_current_config/records/<TAG>_artifacts/<TAG>_ab_results.csv`
- logs: `00_current_config/records/<TAG>_artifacts/<TAG>_{BASE|CAND}_T*.log`
- summaries printed in terminal:
    - valid+informative mean churn
    - silent-window rate by branch

## 📖 Разделы

- [Текущая конфигурация](00_current_config/)
- [Backup/Restore после прошивки](00_current_config/guides/07-backup-and-restore-after-flash.md)
- [Исследование 4PDA](01_4pda_research/)
- [База прошивок](02_firmware/)
- [Интеграция NC2312](03_nc2312_integration/)
- [База знаний](04_knowledge_base/)
- [Комьюнити](05_community/)
- [Каноничная архитектура](ARCHITECTURE.md)

## 📝 Лицензия

MIT License
