//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application;
import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

//! This app uses the Bluetooth Low Energy API to pair with devices.
class DukeSampleApp extends Application.AppBase {
    private var _bleDelegate as BluetoothDelegate?;
    private var _profileManager as ProfileManager?;
    private var _modelFactory as DataModelFactory?;
    private var _viewController as ViewController?;
    var _phoneCommunication as PhoneCommunication;

    //! Constructor
    public function initialize() {
        AppBase.initialize();        
        _phoneCommunication = new PhoneCommunication();
    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {
        _profileManager = new $.ProfileManager();
        _bleDelegate = new $.BluetoothDelegate(_profileManager as ProfileManager);
        _modelFactory = new $.DataModelFactory(_bleDelegate as BluetoothDelegate, _profileManager as ProfileManager, _phoneCommunication as PhoneCommunication);
        _viewController = new $.ViewController(_modelFactory as DataModelFactory);

        BluetoothLowEnergy.setDelegate(_bleDelegate as BluetoothDelegate);
        if (_profileManager != null) {
            _profileManager.registerProfiles();
        }
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
        _viewController = null;
        _modelFactory = null;
        _profileManager = null;
        _bleDelegate = null;
    }

    //! Return the initial views for the app
    //! @return Array Pair [View, InputDelegate]
    public function getInitialView() as [Views] or [Views, InputDelegates] {
        var scanDataModel = _modelFactory.getScanDataModel();
        var scanView = new ScanView(scanDataModel);
        var scanDelegate = new ScanDelegate(scanDataModel, _viewController, _modelFactory);
        return [scanView, scanDelegate];
    }

}
