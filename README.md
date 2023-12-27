# Duke Project Example - Connect IQ App

Install the Garmin Monkey C Extension:
Name: Monkey C
Id: Garmin.monkey-c
Description: Monkey C Language Support
Version: 1.0.10
Publisher: Garmin
VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c


Once you open the CIQ project in Studio Code, you may encounter errors when trying to execute Monkey C commands such as:

_Workspace not found.
Connect IQ project not found. Be sure your project has a monkey.jungle file and the project's Jungle Files setting is correct._

If so, use File -> Add Folder to Workspace and select the connect_iq_app folder.
Reference:
https://forums.garmin.com/developer/connect-iq/f/discussion/285079/can-t-build-or-debug-vscode-project


DJE TODO -- Add notes here on how / what to flash to use another dev-kit or a USB dongle as the CIQ simulator's BLE connectivity
