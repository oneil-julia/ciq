# Duke Project Example - Connect IQ App

Install the Garmin Monkey C Extension:
Name: Monkey C
Id: Garmin.monkey-c
Description: Monkey C Language Support
Version: 1.0.10
Publisher: Garmin
VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c


Once you open the CIQ project in Studio Code, you may encounter errors when trying to execute Monkey C commands such as:
```
Workspace not found.
Connect IQ project not found. Be sure your project has a monkey.jungle file and the project's Jungle Files setting is correct.
```

If so, use **File** -> **Add Folder** to Workspace and select the _DukeSampleApp_ folder.
Reference:
https://forums.garmin.com/developer/connect-iq/f/discussion/285079/can-t-build-or-debug-vscode-project


Using a second dev-kit or nRF USB Dongle for BLE connectivity with the Connect IQ Simulator makes debugging much easier than debugging on watch hardware.  In order to do so, follow the instructions at https://developer.garmin.com/connect-iq/core-topics/bluetooth-low-energy/ to flash the appropriate firmware to the second dev-kit or nRF USB Dongle (most of our work done using an nRF USB Dongle).
