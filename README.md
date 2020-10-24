# Wingpanel Sensors Indicator

<p align="left">
    <a href="https://paypal.me/Dirli85">
        <img src="https://img.shields.io/badge/Donate-PayPal-green.svg">
    </a>
</p>

----

![Screenshot](data/screenshot1.png)  

### Popover
![Screenshot](data/screenshot2.png)  

---

## Building and Installation

You'll need the following dependencies:

* libglib2.0-dev
* libgee-0.8-dev
* libgtk-3-dev
* libwingpanel-2.0-dev
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build
    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`
    sudo ninja install
