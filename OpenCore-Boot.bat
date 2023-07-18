@echo off
rem Original project:
rem https://github.com/kholia/OSX-KVM
rem
rem qemu-img create -f qcow2 mac_hdd_ng.img 128G
rem -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27  # Note: Use this line for High Sierra. Replace line 34 with this
rem
rem NOTE: Without TSC disabled, macOS crashes.

set MY_OPTIONS="+xsave,-tsc"

set ALLOCATED_RAM="2049"

set REPO_PATH="."
set OVMF_DIR="."

qemu-system-x86_64^
  -accel whpx -m "%ALLOCATED_RAM%" -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,"%MY_OPTIONS%"^
  -machine q35^
  -usb -device usb-kbd -device usb-tablet^
  -device usb-ehci,id=ehci^
  -device nec-usb-xhci,id=xhci^
  -global nec-usb-xhci.msi=off^
  -global ICH9-LPC.acpi-pci-hotplug-with-bridge-support=off^
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"^
  -bios %OVMF_DIR%/ovmf.fd ^
  -smbios type=2^
  -device ich9-intel-hda -device hda-duplex^
  -device ich9-ahci,id=sata^
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="%REPO_PATH%/OpenCore/OpenCore.qcow2"^
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot^
  -device ide-hd,bus=sata.3,drive=InstallMedia^
  -drive id=InstallMedia,if=none,file="%REPO_PATH%/BaseSystem.img",format=raw^
  -drive id=MacHDD,if=none,file="%REPO_PATH%/mac_hdd_ng.img",format=qcow2^
  -device ide-hd,bus=sata.4,drive=MacHDD^
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27^
  -monitor stdio^
  -device vmware-svga
  -vga virtio
