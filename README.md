# FM350-GL Master Documentation

Полная документация по настройке и эксплуатации модема Fibocom FM350-GL на OpenWrt с адаптером NC2312.

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
./00_current_config/scripts/check_setup_stage.sh
./00_current_config/scripts/usb_mode_switch.sh
./00_current_config/scripts/monitor_connection.sh
```

## 📖 Разделы

- [Текущая конфигурация](00_current_config/)
- [Исследование 4PDA](01_4pda_research/)
- [База прошивок](02_firmware/)
- [Интеграция NC2312](03_nc2312_integration/)
- [База знаний](04_knowledge_base/)
- [Комьюнити](05_community/)

## 📝 Лицензия

MIT License
