//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Lang;
import Toybox.WatchUi;

class DeviceDelegate extends WatchUi.BehaviorDelegate {
    private var _deviceDataModel as DeviceDataModel;
    private var _parentView as DeviceView;

    //! Constructor
    //! @param deviceDataModel The device data model
    public function initialize(deviceDataModel as DeviceDataModel, parentView as DeviceView) {
        BehaviorDelegate.initialize();

        _deviceDataModel = deviceDataModel;
        _parentView = parentView;
        _deviceDataModel.pair();
    }

    //! Handle the back behavior
    //! @return true if handled, false otherwise
    public function onBack() as Boolean {
        _deviceDataModel.unpair();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    public function onTap(clickEvent as ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        if (coords.size() == 2) {
            System.println("onTap: " + coords[0] + "," + coords[1]);
           _parentView.onTapEvent(coords[0], coords[1]);
        }
        return true;
    }
}

