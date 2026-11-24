{
  flake.modules.nixos.system = {
    # The kernel binds the Orb's HID mute LED to the "audio-mute" trigger,
    # which follows the laptop speaker mute and makes the mic mute itself.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*::mute", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0ad5", ATTR{trigger}="none"
    '';
  };
}
