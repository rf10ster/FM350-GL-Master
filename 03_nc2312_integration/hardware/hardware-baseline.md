# NC2312 Hardware Baseline (RU/EN)

RU: Минимальный hardware baseline перед интеграцией FM350-GL через NC2312.
EN: Minimal hardware baseline before integrating FM350-GL via NC2312.

## Scope

- physical fit and connector compatibility
- power and thermal baseline
- first boot detection checks

## Pre-Install Checklist

1. Adapter revision recorded (board mark/photo).
2. Modem form-factor/key compatibility confirmed.
3. Host USB/M.2 path identified.
4. Stable power source prepared.
5. Antenna paths documented.

## Power Baseline

- avoid weak USB hubs for first bring-up
- prefer direct host USB connection for initial validation
- if brownouts suspected: reduce load and retest before software changes

## Thermal Baseline

- ensure airflow around adapter and modem
- avoid enclosed no-vent setup during first soak tests
- record ambient temperature at start/end of test window

## First Detection Procedure

1. Attach hardware with power off where possible.
2. Boot host/router.
3. Verify detection:
   - `lsusb | grep -Ei 'fibocom|2cb7|0e8d'`
   - `ls -la /dev/ttyUSB*`
   - `dmesg | tail -50`

## Baseline Evidence

- clear photo of adapter + modem installation
- detection command outputs
- date/time and host model
- chosen profile target (`wan_fm350_atc` or fallback)

## Stop Conditions

Stop and open incident report if any are true:

1. repeated connect/disconnect loop in `dmesg`
2. no ttyUSB device appears after confirmed USB detection
3. device overheats or reboots under low load
