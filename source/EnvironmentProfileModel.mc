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

    private var _custom_data_byte_array as ByteArray;
    private var _led_data_byte_array as ByteArray;

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
        _custom_data_byte_array = []b;
        _led_data_byte_array = []b;

        var service = _service;
        if (service != null) {
            var characteristics = service.getCharacteristics();
            var characteristic = characteristics.next() as Characteristic;
            while (null != characteristic) {
                _pendingNotifies = _pendingNotifies.add(characteristic);
                characteristic = characteristics.next() as Characteristic;
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
                System.println("onCharacteristicChanged(), DUKE_CUSTOM_CHARACTERISTIC, data.size()=" + data.size());
                processCustomData(data);
                break;
            case _profileManager.DUKE_LED_CHARACTERISTIC:
                System.println("onCharacteristicChanged(), DUKE_LED_CHARACTERISTIC, data.size()=" + data.size());
                processLedData(data);
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

    //! Get the custom data ByteArray
    //! @return The custom data ByteArray
    public function getCustomDataByteArray() as ByteArray? {
        if (_custom_data_byte_array.size() > 0) {
            return _custom_data_byte_array;
        }
        return null;
    }

    //! Get the custom data ByteArray
    //! @return The custom data ByteArray
    public function getLedDataByteArray() as ByteArray? {
        if (_led_data_byte_array.size() > 0) {
            return _led_data_byte_array;
        }
        return null;
    }

    //! Write the next notification to the descriptor
    private function activateNextNotification() as Void {
        if (_pendingNotifies.size() == 0) {
            System.println("activateNextNotification, _pendingNotifies.size() == 0");
            return;
        }

        System.println("activateNextNotification, _pendingNotifies.size(): " + _pendingNotifies.size());
        var char = _pendingNotifies[0];
        var cccd = char.getDescriptor(BluetoothLowEnergy.cccdUuid());
        if (cccd != null) {
            cccd.requestWrite([0x01, 0x00]b);
        }
    }

    //! Process a CCCD write operation
    private function processCccdWrite() as Void {
        System.println("processCccdWrite, _pendingNotifies.size(): " + _pendingNotifies.size());
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
        System.println("processCustomData(), data.size()=" + data.size());
        _custom_data_byte_array = []b;
        _custom_data_byte_array.addAll(data);
        WatchUi.requestUpdate();
    }

    //! Process and set the custom data processLedData
    //! @param data The new custom data
    private function processLedData(data as ByteArray) as Void {
        System.println("processLedData(), data.size()=" + data.size());
        _led_data_byte_array = []b;
        _led_data_byte_array.addAll(data);
        WatchUi.requestUpdate();
    }
}
