//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

class EnvironmentProfileModel {
    private var _service as Service?;
    private var _profileManager as ProfileManager;
    private var _pendingNotifies as Array<Characteristic>;

    private var _custom_array as Array<Numeric>;

    //! Constructor
    //! @param delegate The BLE delegate for the model
    //! @param profileManager The profile manager for this model
    //! @param device The current device
    public function initialize(delegate as BluetoothDelegate, profileManager as ProfileManager, device as Device) {
        delegate.notifyDescriptorWrite(self);
        delegate.notifyCharacteristicChanged(self);

        _profileManager = profileManager;
        _service = device.getService(profileManager.DUKE_CUSTOM_SERVICE);

        _pendingNotifies = [] as Array<Characteristic>;
        _custom_array = [] as Array<Numeric>;

        var service = _service;
        if (service != null) {
            var characteristic = service.getCharacteristic(profileManager.DUKE_CUSTOM_CHARACTERISTIC);
            if (null != characteristic) {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }
        }

        activateNextNotification();
    }

    //! Handle a characteristic being changed
    //! @param char The characteristic that changed
    //! @param data The updated data of the characteristic
    public function onCharacteristicChanged(char as Characteristic, data as ByteArray) as Void {
        switch (char.getUuid()) {
            case _profileManager.DUKE_CUSTOM_CHARACTERISTIC:
                System.println("onCharacteristicChanged(), data.size()=" + data.size());
                processCustomData(data);
                break;
        }
    }

    //! Handle the completion of a write operation on a descriptor
    //! @param descriptor The descriptor that was written
    //! @param status The BluetoothLowEnergy status indicating the result of the operation
    public function onDescriptorWrite(descriptor as Descriptor, status as Status) as Void {
        if (BluetoothLowEnergy.cccdUuid().equals(descriptor.getUuid())) {
            processCccdWrite();
        }
    }

    //! Get the custom array
    //! @return The custom array
    public function getCustomArray() as Array? {
        return _custom_array;
    }

    //! Write the next notification to the descriptor
    private function activateNextNotification() as Void {
        if (_pendingNotifies.size() == 0) {
            return;
        }

        var char = _pendingNotifies[0];
        var cccd = char.getDescriptor(BluetoothLowEnergy.cccdUuid());
        if (cccd != null) {
            cccd.requestWrite([0x01, 0x00]b);
        }
    }

    //! Process a CCCD write operation
    private function processCccdWrite() as Void {
        if (_pendingNotifies.size() > 1) {
            _pendingNotifies = _pendingNotifies.slice(1, _pendingNotifies.size());
            activateNextNotification();
        } else {
            _pendingNotifies = [] as Array<Characteristic>;
        }

    }

    //! Process and set the custom data
    //! @param data The new custom data
    private function processCustomData(data as ByteArray) as Void {
        System.println("processCustomData(), data.size()=" + data.size() + ", _custom_array.size()=" + _custom_array.size());
        var customArraySize = _custom_array.size();
        for (var i = 0; i < data.size(); i++) {
            var options = {
                :offset => i
            };
            var dataValue = data.decodeNumber(Lang.NUMBER_FORMAT_UINT8, options);
            System.println("i=" + i + ", dataValue=" + dataValue);
            if (i >= customArraySize) {
                _custom_array.add(dataValue);
            } else {
                _custom_array[i] = dataValue;
            }
            System.println("_custom_array[" + i + "]=" + _custom_array[i]);
        }
        WatchUi.requestUpdate();
    }
}
