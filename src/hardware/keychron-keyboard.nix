{ pkgs, ... }:
{
  # Let the Keychron Launcher (WebHID, Chromium browsers) configure the keyboard.
  #
  # These rules live in their own file instead of services.udev.extraRules
  # because extraRules ends up in 99-local.rules, which runs after systemd's
  # 73-seat-late.rules. That is where the uaccess tag is turned into an ACL
  # for the active seat user, so a tag added at 99 is ignored on hotplug.
  #
  # Only the vendor-defined (config) HID interfaces are tagged. The keyboard
  # input interfaces stay root-only so user processes cannot read keystrokes.
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "keychron-udev-rules";
      destination = "/etc/udev/rules.d/70-keychron.rules";

      text = ''
        # Keychron K3 Max, wired (iface 01: VIA raw-HID, usage page 0xFF60)
        SUBSYSTEM=="hidraw", ENV{ID_VENDOR_ID}=="3434", ENV{ID_MODEL_ID}=="0a38", ENV{ID_USB_INTERFACE_NUM}=="01", TAG+="uaccess"

        # Keychron Link 2.4GHz dongle (iface 01: usage page 0x8C, iface 03: VIA raw-HID 0xFF60)
        SUBSYSTEM=="hidraw", ENV{ID_VENDOR_ID}=="3434", ENV{ID_MODEL_ID}=="d030", ENV{ID_USB_INTERFACE_NUM}=="01|03", TAG+="uaccess"

        # Raw USB access (WebUSB/libusb via /dev/bus/usb). Not needed for WebHID
        # configuration; it grants the whole device, including detaching the
        # kernel HID driver and reading keystrokes. Uncomment only if a firmware
        # update in the Launcher fails without it.
        # SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_VENDOR_ID}=="3434", ENV{ID_MODEL_ID}=="0a38", TAG+="uaccess"
        # SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_VENDOR_ID}=="3434", ENV{ID_MODEL_ID}=="d030", TAG+="uaccess"
      '';
    })
  ];
}
