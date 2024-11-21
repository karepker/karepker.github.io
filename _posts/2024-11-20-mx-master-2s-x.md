---
title: Configuring my MX Master 2S mouse acceleration directly on the X window manager
layout: post
---

Recently, I switched to using a window manager without a desktop environment so have had to learn to re-configure some parts of my system directly through X that I was previously doing through the desktop environment.

One case where I've had to do this is setting my mouse pointer acceleration.

My understanding of how this all works is that when I was using a desktop environment (most recently, KDE), I could configure my mouse acceleration through KDE settings, which would then pass them through to the X window manager (or Wayland).

Not using a desktop environment means that instead I have to configure settings directly in X, which is more direct though a bit less obvious.

The [Arch Linux wiki][Mouse acceleration] is helpful here, as always, but I'm recording the steps I used to give a little more detail in a specific case:

1. Install `xorg-xinput`.
1. Find the device ID of the mouse via `xinput`. It will give an output that looks like:

    ```console
    $ xinput
    ⎡ Virtual core pointer                          id=2    [master pointer  (3)]
    ⎜   ↳ Virtual core XTEST pointer                id=4    [slave  pointer  (2)]
    ⎜   ↳ Logitech K800                             id=12   [slave  pointer  (2)]
    ⎜   ↳ Logitech MX Master 2S                     id=14   [slave  pointer  (2)]
    ⎜   ↳ AKKO AKKO 3068BT Keyboard                 id=10   [slave  pointer  (2)]
    ⎣ Virtual core keyboard                         id=3    [master keyboard (2)]
        ↳ Virtual core XTEST keyboard               id=5    [slave  keyboard (3)]
        ↳ AKKO AKKO 3068BT Wireless Radio Control   id=8    [slave  keyboard (3)]
        ↳ Logitech K800                             id=13   [slave  keyboard (3)]
        ↳ Logitech MX Master 2S                     id=15   [slave keyboard (3)]
        ↳ AKKO AKKO 3068BT                          id=9    [slave keyboard (3)]
        ↳ Power Button                              id=7    [slave  keyboard (3)]
        ↳ AKKO AKKO 3068BT Keyboard                 id=11   [slave  keyboard (3)]
        ↳ Power Button                              id=6    [slave  keyboard (3)]
    ```

    I'm using an MX Master 2S, so that's device ID 14.

    Side note: Why is it not device ID 15? I'm not sure, but `pointer` seems like a better match than `keyboard`, and I'm not sure why it shows up in that section. Perhaps some functions of the MX Master 2S better match keyboard functions.

    This appears to change between boots (or probably restarts of X).

1. List the properties available for the mouse.

    ```console
    # xinput list-props 14 | grep 'Accel Speed'
    libinput Accel Speed (298):     -0.700000
    libinput Accel Speed Default (299):     0.000000
    ```

    We care about `Accel Speed (298)`

    There's no action that needs to be taken here or anything to remember, we're just confirming that acceleration can be set for this device.

1. Test acceleration speeds

    ```console
    # xinput set-prop 14 "libinput Accel Speed" <speed>
    ```

    Find one that works well.

1. Write a configuration file to persist this setting. Mine has owner and group `root` and permissions 644.

    ```console
    $ cat /etc/X11/xorg.conf.d/99-mx-master-2s.conf
    Section "InputClass"
      Identifier "MX Master 2S"
      MatchIsPointer "on"
      # Do not MatchProduct because the product is UnifyingReceiver.
      MatchVendor "Logitech"
      # https://wiki.archlinux.org/title/Mouse_acceleration#Persistent_configuration
      Option "AccelSpeed" "-0.7"
    EndSection
    ```

    The hard part about this is actually matching the mouse. Device IDs cannot be used here because they are not persistent. Instead, X provides an extremely fiddly way of matching devices via various properties that are hard to discover.

    The `Match` options are documented [on the X.org website][Inputclass section].

    I used the follow query to find the properties for matching:

    1. Find the device node:

        ```console
        # xinput list-props 14 | grep 'Device Node'
                Device Node (271):      "/dev/input/event6"
        ```

    1. List the associated properties:

        ```console
        $ udevadm info --query=property --name=/dev/input/event6
        ...
        ID_VENDOR=Logitech
        ...
        ```

        Apparently when I first created this configuration, I found a `Product` property that was `UnifyingReceiver`. Now, I don't remember which command had that as output and don't see it.

[Mouse acceleration]: https://wiki.archlinux.org/title/Mouse_acceleration
[Inputclass section]: https://www.x.org/archive/X11R7.6/doc/man/man5/xorg.conf.5.xhtml#heading9
