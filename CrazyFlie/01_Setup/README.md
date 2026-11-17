[BACK TO THE CRAZYFLIE SECTION](../README.md) · [CHEAT SHEET](../cfCmdCheatSheets.MD)

# 1 — Setup: from a box of parts to a connected drone

At the end of this chapter you have a drone that answers. Not one that flies:
one that appears in a scan, reports its battery, prints its firmware version
into a console, and accepts a Python script. Everything in chapter 2 assumes
this chapter worked.

Two tools do the work, and it is worth knowing which is which from the start:

| Tool | What it is | What you use it for |
| --- | --- | --- |
| **cfclient** | the Bitcraze GUI, a desktop application | flashing, radio settings, looking at parameters and log variables, a first manual flight |
| **cflib** | a Python library | everything you write yourself |

They speak the same protocol over the same radio, which is exactly why they
cannot be used at the same time. See [1.9](#19-one-rule-never-both-at-once).

---

## Table of Contents

- [1 — Setup: from a box of parts to a connected drone](#1--setup-from-a-box-of-parts-to-a-connected-drone)
  - [1.1 What you need](#11-what-you-need)
  - [1.2 Python and the virtual environment](#12-python-and-the-virtual-environment)
  - [1.3 Installing cflib and cfclient](#13-installing-cflib-and-cfclient)
  - [1.4 The Crazyradio](#14-the-crazyradio)
  - [1.5 The Bitcraze GUI (cfclient), tab by tab](#15-the-bitcraze-gui-cfclient-tab-by-tab)
    - [1.5.1 The connection bar](#151-the-connection-bar)
    - [1.5.2 The tabs](#152-the-tabs)
    - [1.5.3 The two dialogs in the Connect menu](#153-the-two-dialogs-in-the-connect-menu)
    - [1.5.4 The Supervisor button](#154-the-supervisor-button)
  - [1.6 Flashing the firmware](#16-flashing-the-firmware)
  - [1.7 The radio URI](#17-the-radio-uri)
    - [1.7.1 What a URI is made of](#171-what-a-uri-is-made-of)
    - [1.7.2 The drone in this lab](#172-the-drone-in-this-lab)
    - [1.7.3 Writing the settings with Configure 2.x](#173-writing-the-settings-with-configure-2x)
    - [1.7.4 Finding a drone whose settings you do not know](#174-finding-a-drone-whose-settings-you-do-not-know)
  - [1.8 First contact: the five minute check](#18-first-contact-the-five-minute-check)
  - [1.9 One rule: never both at once](#19-one-rule-never-both-at-once)
  - [1.10 Troubleshooting](#110-troubleshooting)
  - [References](#references)

---

## 1.1 What you need

| Hardware | Note |
| --- | --- |
| Crazyflie 2.1 Brushless | the drone this lab flies. It has to be armed before the motors turn — chapter 2, section 2.4 |
| Crazyradio PA / Crazyradio 2.0 (USB) | the drone's own USB port carries power and flashing, not flight telemetry |
| USB cable | for charging and for flashing |
| A charged battery | a weak battery is the single most common cause of "it refuses to arm" |
| Flow deck v2 (optional) | needed for every example that holds a height |
| Multiranger deck (optional) | needed for the Push Demo at the end of chapter 2 |

| Software | Version |
| --- | --- |
| Python | 3.10 or newer |
| Visual Studio Code | any recent version |
| cflib | installed with pip, see [1.3](#13-installing-cflib-and-cfclient) |
| cfclient | the Bitcraze GUI, installer or pip |

---

## 1.2 Python and the virtual environment

A virtual environment is not optional in a lab where many people share a
machine: it keeps this course's packages away from everything else installed
on the computer.

```bash
mkdir crazyflie-lab
cd crazyflie-lab
python -m venv venv
```

Activate it. This is the one command that differs per platform, and it has to
be repeated in every new terminal:

```bash
# Windows (PowerShell)
venv\Scripts\Activate.ps1

# Windows (cmd)
venv\Scripts\activate.bat

# macOS / Linux
source venv/bin/activate
```

The prompt now starts with `(venv)`. If it does not, nothing you install next
lands where you think it does.

```bash
python -m pip install --upgrade pip
```

In VS Code, pick the interpreter from this folder: `Ctrl+Shift+P` →
`Python: Select Interpreter` → the one with `venv` in its path. Otherwise the
terminal and the Run button use two different Pythons, and only one of them
has cflib.

---

## 1.3 Installing cflib and cfclient

```bash
pip install cflib
```

That is the library your own scripts import. Check it:

```bash
python -c "import cflib; print('cflib ok')"
```

The GUI is a separate program:

```bash
pip install cfclient
```

On Windows the installer from <https://www.bitcraze.io/downloads/> is the
easier route, because the GUI brings a Qt stack with it that does not always
build from source. Either way, start it with:

```bash
cfclient
```

If the window opens, the GUI is installed. It will not find a drone yet —
that is the next section.

---

## 1.4 The Crazyradio

Plug the dongle in before starting cfclient, and leave it in. The drone's own
USB port is for charging and flashing; all flight communication goes through
this dongle.

| Platform | What is needed |
| --- | --- |
| Windows | a USB driver for the dongle. If cfclient reports no radio, install it with Zadig, following the [Bitcraze wiki](https://wiki.bitcraze.io/doc:crazyradio:install_windows_zadig). |
| Linux | udev rules, so the dongle is usable without root — see the [cflib installation guide](https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/installation/install/). |
| macOS | nothing. |

A radio that the computer does not see looks exactly like a drone that is
switched off. Rule out the dongle first.

---

## 1.5 The Bitcraze GUI (cfclient), tab by tab

The GUI is not a toy that sits beside the real work. It is the fastest
debugger you have: every parameter you can set from Python is visible here,
every log variable you can subscribe to is listed here, and the console shows
what the firmware itself thinks.

### 1.5.1 The connection bar

Along the top:

| Element | What it does |
| --- | --- |
| **Address** | the address to look for. The field starts at the factory default `0xE7E7E7E7E7`; the drones in this lab answer at `0xE7E7E7E7AA`. |
| **Scan** | searches for drones at that address and fills the drop-down with the URIs it found |
| the drop-down | the URIs found, for example `radio://0/33/2M/E7E7E7E7AA` |
| **Connect** / **Disconnect** | opens and closes the link to the selected URI |
| battery and link quality | battery voltage, and link quality in percent. A link quality that collapses while the drone is three metres away is a radio problem, not a code problem. |

### 1.5.2 The tabs

| Tab | What it is for | When you will need it |
| --- | --- | --- |
| **Flight control** | manual flight with a gamepad, flight mode, trim, assisted modes, and the arming button | first flight, and whenever you want to know whether a problem is yours or the drone's |
| **Console** | the firmware's own text output, including the firmware version on connect and warnings about decks | always. Read it before asking anyone anything. |
| **Parameters** | every parameter, readable and writable by name | finding the exact name you later pass to `cf.param.set_value()` |
| **Log TOC** | the list of every log variable the firmware offers | finding the exact name you later pass to `LogConfig.add_variable()` |
| **Log blocks** | the saved logging configurations | setting up a recording before you fly |
| **Plotter** | plots a log block live | watching height or range sensors while someone else flies |
| **Tuning** | controller settings | not in this course |
| **LED ring**, **Color LED** | the LED decks | not in this course |
| **Loco Positioning**, **Lighthouse Positioning** | the external positioning systems | later, if the lab uses them |

Two tabs do most of the work in this course: **Log TOC** and **Parameters**.
Names differ between firmware builds, and guessing a name in Python gets you
an exception with no hint. Looking it up here takes ten seconds.

### 1.5.3 The two dialogs in the Connect menu

These are not tabs; they are in the **Connect** menu:

- **Bootloader** — flashes firmware onto the drone. Used in
  [1.6](#16-flashing-the-firmware).
- **Configure 2.x** — writes radio channel, bandwidth and address into the
  drone's own memory, plus roll and pitch trim. Used in
  [1.7](#17-the-radio-uri).

### 1.5.4 The Supervisor button

In the Flight control tab there is a button that arms and disarms the drone.
On a drone set to arm itself it may read "Auto armed" instead. The same button
recovers a drone after a crash.

Remember that it exists. Chapter 2 is largely about what this button does, and
how to do it from Python — it is the difference between a motor that spins and
one that silently refuses.

**Checkpoint.** Open cfclient, scan, connect to the drone, and read three
things: the firmware version in the Console tab, the battery voltage in the
connection bar, and the value of one parameter of your choice in the
Parameters tab. If all three work, the toolchain is sound.

---

## 1.6 Flashing the firmware

Flash before you do anything else, so that every drone in the lab runs the
same firmware. Mismatched firmware is the reason two identical scripts behave
differently on two identical drones.

1. Connect the drone to the computer **by USB**, and switch it off.
2. cfclient → **Connect** → **Bootloader**.
3. Put the drone into bootloader mode: hold the power button for about one
   and a half seconds, until the blue tail LEDs blink. The dialog will tell
   you when it has found the drone.
4. Choose the firmware. Either the newest release that the dialog offers, or a
   local file:

   | Drone | File in this repository |
   | --- | --- |
   | Crazyflie 2.1 Brushless | `firmware/firmware-cf21bl-2025.12.zip` |

5. Flash, and wait until the dialog says it is done. Then restart the drone.

Take the **cf21bl** file, not the **cf2** one. The brushed build in
`firmware/firmware-cf2-2025.12.zip` is for the older brushed Crazyflie, and
its motor mixing and ESC protocol are different ones. Check the file name
twice; the dialog will flash whatever you hand it.

Flashing needs the Crazyradio. The USB cable alone will not do it.

---

## 1.7 The radio URI

### 1.7.1 What a URI is made of

Everything the radio needs is in one string:

```text
radio://0/33/2M/E7E7E7E7AA
   |     |  |  |      |
   |     |  |  |      +--- address, 5 bytes = 10 hex digits
   |     |  |  +---------- data rate: 250K, 1M or 2M
   |     |  +------------- channel, 0 to 125
   |     +---------------- which radio dongle, 0 for the first one
   +-------------------- interface
```

Two traps live in that string:

- The address is **exactly 10 hex digits**. `E7E7E7E7E7E7` is twelve and
  cannot work, however plausible it looks.
- Channel, data rate and address must match what is written **inside the
  drone**. The URI does not configure the drone, it only addresses it.

### 1.7.2 The drone in this lab

| Drone | Channel | Rate | Address | URI |
| --- | --- | --- | --- | --- |
| Crazyflie 2.1 Brushless | 33 | 2M | `E7E7E7E7AA` | `radio://0/33/2M/E7E7E7E7AA` |

Note that neither the channel nor the address is the factory default, which is
channel 80 and address `0xE7E7E7E7E7`. A scan at the default address finds
nothing here, and that is not a fault.

This one string appears in every script of chapter 2, and nowhere else is it
written out again. If your drone uses different values, change them in
`cflab.py` once (chapter 2, section 2.5) and every example follows.

### 1.7.3 Writing the settings with Configure 2.x

1. Connect the drone by USB (or by radio, if you still know its current URI).
2. cfclient → **Connect** → **Configure 2.x**.
3. Set channel, bandwidth and address from the table above.
4. Press the write button. The values go into the drone's memory.
5. Restart the drone, pull the USB cable, and connect over the radio.

Give each drone in the room a different channel or address. Two drones on the
same URI will both answer, and the result looks like a drone with a mind of
its own.

### 1.7.4 Finding a drone whose settings you do not know

Put the address you suspect into the **Address** field and press **Scan**. The
drop-down shows every URI that answered. Try `0xE7E7E7E7AA` first, then the
factory default `0xE7E7E7E7E7`. If nothing answers at either, connect by USB
instead and read the real settings in Configure 2.x.

---

## 1.8 First contact: the five minute check

Run through this list before every lab session. It takes five minutes and
saves an hour.

- [ ] Battery charged, drone switched on, standing level and still
- [ ] Crazyradio plugged in
- [ ] cfclient scans and finds the drone's URI
- [ ] Connect succeeds, battery voltage looks sensible
- [ ] The Console tab shows the firmware version, and no deck warnings
- [ ] Propellers undamaged, and free to turn by hand
- [ ] cfclient **disconnected** again before any Python script is started

---

## 1.9 One rule: never both at once

One radio, one link. If cfclient holds the connection, your script cannot get
it, and the error you get back says nothing useful about why. Disconnect in
cfclient before running Python, and stop your script before connecting in
cfclient.

This one rule explains most of the mysterious failures in the first lab
session.

---

## 1.10 Troubleshooting

| Symptom | First thing to check |
| --- | --- |
| cfclient does not start | is the virtual environment active? `pip install cfclient` in it? |
| No radio found | dongle plugged in, and on Windows the driver installed (Zadig) |
| Scan finds nothing | drone on? battery charged? the address in the Address field? drone standing still while it boots? |
| Connect fails straight away | another program holds the link — cfclient open twice, or a script still running |
| Connects, then drops out | battery, distance, or a channel shared with another drone in the room |
| Python cannot connect, cfclient can | the script's URI does not match, or cfclient is still connected |
| `ModuleNotFoundError: cflib` | wrong interpreter selected in VS Code, or venv not active |
| Firmware flashing does not start | bootloader mode not entered (hold the power button ~1.5 s), or no Crazyradio |

---

## References

- Crazyflie client (cfclient) user guide:
  <https://www.bitcraze.io/documentation/repository/crazyflie-clients-python/master/userguides/userguide_client>
- Flight control tab, including the Supervisor (arming) button:
  <https://www.bitcraze.io/documentation/repository/crazyflie-clients-python/master/userguides/userguide_client/flightcontrol_tab/>
- cflib installation:
  <https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/installation/install/>
- Crazyradio on Windows, with Zadig:
  <https://wiki.bitcraze.io/doc:crazyradio:install_windows_zadig>
- Getting started with the Crazyflie 2.1 Brushless:
  <https://www.bitcraze.io/documentation/tutorials/getting-started-with-crazyflie-brushless/>
- Downloads:
  <https://www.bitcraze.io/downloads/>

---

Next: [2 — Basic movements](../02_BasicMovements/README.md)
