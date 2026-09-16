# Z13 Control

Hardware control for the **2025 ASUS ROG Flow Z13** (GZ302E) on Linux: power
profiles, APU power limits, fan curves, keyboard and lightbar RGB, battery
charge limit, live monitoring and firmware toggles.

An app, a panel menu for **GNOME** and **KDE Plasma**, and a `z13`
command-line tool, all talking to a small system service that holds the
privileges so nothing else has to.

![Overview](docs/screenshots/01-overview.png)

## Install

One line, on Ubuntu 24.04+ or Fedora 42+ (GNOME or KDE Plasma 6):

```sh
curl -fsSL https://raw.githubusercontent.com/wabibito/z13-control/main/install.sh | sh
```

It picks the right package for your system, asks for your password once, and
starts the service. Or download the `.deb` (Ubuntu/Debian) or `.rpm`
(Fedora/RHEL) from [Releases](../../releases) and install it by hand:

```sh
sudo apt install ./z13-control_*_all.deb     # Ubuntu / Debian
sudo dnf install ./z13-control-*.noarch.rpm  # Fedora / RHEL
```

**Log out and back in once after installing.** GNOME only picks up the top-bar
menu at login; the app enables it for you. On KDE Plasma the app adds its
widget to your panel the first time it starts.

## What it does

### Live monitoring

APU temperature and power, CPU and GPU load, RAM and GPU memory, fan speeds and
battery, each with a two-minute graph that is already filled in when you open
the app, because the service records it continuously.

### Top-bar menu

![Top-bar menu](docs/screenshots/06-topbar-menu.png)

Temperature in the top bar, and one click away: live readings, power profiles,
power limits and fan presets, lighting, battery limit, auto-switch, alerts and
the panel refresh rate — without opening the app.

### KDE Plasma panel widget

![Plasma widget](docs/screenshots/08-plasma-widget.png)

The same quick controls as a Plasma 6 widget, following your Plasma theme.
It is placed on your panel automatically; right-click the panel → *Add
Widgets* → *Z13 Control* to add it again after removing it. Refresh-rate
switching uses KScreen on Plasma.

### Profiles and power limits

![Performance](docs/screenshots/02-performance.png)

**Quiet, Balanced and Performance** are the firmware's own profiles, shared with
GNOME's power menu. Build **custom profiles** on top of them with their own
power limits and fan curve, and switch automatically when you plug in or unplug.

Power limits use the kernel's own interface and the per-model range it reports,
so values your machine would reject are refused up front. Sustained power above
75 W asks for an administrator password and enforces a fan floor.

### Fans

![Fans](docs/screenshots/03-fans.png)

Drag the eight points, or start from Silent, Balanced or Aggressive. The curve
is re-applied automatically if something else drops it, the current temperature
is marked on the graph, and at high sustained power the enforced minimum is
drawn in orange: your points are raised to it, never lowered.

### Lighting

![Lighting](docs/screenshots/04-lighting.png)

Keyboard and lightbar, together or separately: static, breathe, colour cycle,
rainbow or strobe, with colour, speed and brightness, and a live preview. Lights
can switch off by themselves on battery, after a period of inactivity, or while
the keyboard is detached, and your colours come back when the condition clears.

### System

![System](docs/screenshots/05-system.png)

Battery charge limit, automatic profile switching, boot sound, panel overdrive,
panel refresh rate (with an optional drop to 60 Hz on battery), alerts when the
APU stays hot, and export/import of your profiles and settings.

### Staying up to date

The app checks for new releases once a day and can install them for you:
**System → Updates → Install update**, with a single password prompt. From a
terminal, `z13 update` does the same.

### Command line

```sh
z13 status                      # everything at a glance
z13 monitor                     # live temperature / power / fans
z13 use performance             # switch profile
z13 tdp 65 80 90                # power limits in watts
z13 fan set balanced            # fan preset or your own 8 points
z13 light -m breathe -c cyan --color2 blue
z13 battery 80                  # charge limit
z13 export my-profiles.json     # back up profiles and settings
z13 history usage.csv           # recorded telemetry as CSV
```

`z13 --help` lists everything.

## How it is put together

A root service owns the hardware and authorises every change through polkit, so
no system files or devices are made writable for ordinary users. Everyday
changes are allowed for the person sitting at the machine; raising sustained
power above 75 W asks for an administrator password.

Profile switches go through power-profiles-daemon, so GNOME's power menu, the
CPU's energy setting and the firmware stay in agreement, and changes made from
that menu or with Fn+F5 are followed rather than fought.

Before sleep the lights go off, power is lowered if needed and the fans are
handed back to the embedded controller so they can stop; everything is restored
after resume.

## Requirements

* 2025 ROG Flow Z13 (GZ302E)
* Ubuntu 24.04+ or Fedora 42+ with GNOME or KDE Plasma 6 (Wayland or X11)
* Linux 6.11+ for fan curves and power limits; 6.19+ reports the per-model
  power range this app uses

## Uninstall

```sh
sudo apt remove z13-control     # Ubuntu / Debian
sudo dnf remove z13-control     # Fedora / RHEL
```

Saved profiles stay in `/var/lib/z13-control`.

## License

Copyright 2026 NA Research. Licensed under Apache-2.0 (see LICENSE and NOTICE).
