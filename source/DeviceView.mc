//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

class DeviceView extends WatchUi.View {


    private var _dataModel as DeviceDataModel;
    var yInitialOffsetPercent = 0.40f;

    //! Constructor
    //! @param dataModel The data to show
    public function initialize(dataModel as DeviceDataModel) {
        View.initialize();

        _dataModel = dataModel;
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        var statusString;
        if (_dataModel.isConnected()) {
            statusString = "Connected";
        } else {
            statusString = "Waiting for\nConnection...";
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawText(dc.getWidth() / 2, yInitialOffsetPercent * dc.getHeight(), Graphics.FONT_MEDIUM, statusString, Graphics.TEXT_JUSTIFY_CENTER);

        var profile = _dataModel.getActiveProfile();
        if (_dataModel.isConnected() && (profile != null)) {
            drawCustomValue(dc, profile.getCustomArray());
        }
    }

    //! Draw the indicator with the given bitmap and text
    //! @param dc Device context
    //! @param data The data
    private function drawCustomValue(dc as Dc, data as Array?) as Void {
        var font = Graphics.FONT_SYSTEM_SMALL;
        var fontHeight = dc.getFontHeight(font);
        var yOffset = yInitialOffsetPercent * dc.getHeight() + fontHeight;

        if (data == null) {
            System.println("drawCustomValue(), null data");
            dc.drawText(dc.getWidth() / 2, yOffset, font, "null data", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            var dataSize = data.size();
            System.println("drawCustomValue(), data.size()=" + dataSize);
            var dataSizeLabel = "dataSize: " + dataSize.toString();
            dc.drawText(dc.getWidth() / 2, yOffset, font, dataSizeLabel, Graphics.TEXT_JUSTIFY_CENTER);
            yOffset += fontHeight;
            if (dataSize > 0) {
                var dataValuesLabel = "";
                var HELLO_WORLD = true;
                if (HELLO_WORLD) {
                    // Treat the incoming data as text
                    for (var i = 0; i < dataSize - 1; i++) {
                        var myChar = data[i].toChar();
                        dataValuesLabel += myChar;
                    }
                } else {
                    // Treat in incoming data as numeric
                    for (var i = 0; i < dataSize - 1; i++) {
                        dataValuesLabel += data[i].format("%d") + ", ";
                    }
                    dataValuesLabel += data[dataSize - 1].format("%d");
                }
                dc.drawText(dc.getWidth() / 2, yOffset, font, dataValuesLabel, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
    }
}
