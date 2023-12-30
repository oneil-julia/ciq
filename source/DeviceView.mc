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

    static enum {
        LED_STATE_OFF = 0,
        LED_STATE_ON = 1,
	
	LED_STATE_COUNT
    }

    private var _dataModel as DeviceDataModel;
    private var yInitialOffsetPercent = 0.40f;
    private var LedDataExpectedSize = 1;
    private var Led4index = 0;
    private var _led4state;

    //! Constructor
    //! @param dataModel The data to show
    public function initialize(dataModel as DeviceDataModel) {
        View.initialize();

        _dataModel = dataModel;
        _led4state = LED_STATE_OFF;
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        System.println("onUpdate()");
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
            drawProfileData(dc, profile.getCustomDataByteArray(), profile.getLedDataByteArray());
        }
    }

    //! Update the screen with the data received
    //! @param dc Device context
    //! @param customData The custom data
    //! @param ledData The LED data
    private function drawProfileData(dc as Dc, customData as ByteArray?, ledData as ByteArray?) as Void {
        System.println("drawCustomValue()");
        var font = Graphics.FONT_SYSTEM_SMALL;
        var fontHeight = dc.getFontHeight(font);
        var yOffset = yInitialOffsetPercent * dc.getHeight() + fontHeight;

        if (customData != null) {
            var dataSize = customData.size();
            System.println("  customData.size() " + dataSize);
            var dataSizeLabel = "dataSize: " + dataSize.toString();
            dc.drawText(dc.getWidth() / 2, yOffset, font, dataSizeLabel, Graphics.TEXT_JUSTIFY_CENTER);
            yOffset += fontHeight;
            if (dataSize > 0) {
                var dataValuesLabel = "";
                var HELLO_WORLD = true;
                if (HELLO_WORLD) {
                    // Treat incoming customData as text
                    var options = {
                        :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
                        :toRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
                        :encoding => StringUtil.CHAR_ENCODING_UTF8
                        };
                    dataValuesLabel = StringUtil.convertEncodedString(customData, options);
                } else {
                    // Treat in incoming customData as numeric
                    for (var i = 0; i < dataSize - 1; i++) {
                        dataValuesLabel += customData[i].format("%d") + ", ";
                    }
                    dataValuesLabel += customData[dataSize - 1].format("%d");
                }
                System.println("  dataValuesLabel " + dataValuesLabel);
                dc.drawText(dc.getWidth() / 2, yOffset, font, dataValuesLabel, Graphics.TEXT_JUSTIFY_CENTER);
                yOffset += fontHeight;
            }
        }

        if (ledData != null) {
            var ledDataSize = ledData.size();
            if (ledDataSize > 0) {
                System.println("  ledData.size() " + ledDataSize);
                if (LedDataExpectedSize != ledDataSize) {
                    System.println("  Warning: ledData.size() " + ledDataSize + ", expected " + LedDataExpectedSize);
                }
                
                var led4Data = ledData[Led4index];
                if (led4Data < LED_STATE_COUNT) {
                    _led4state = led4Data;
                    System.println("  _led4state " + _led4state);
                } else {
                    System.println("  unsupported state led4Data  " + led4Data);
                }
            }
        }
    }
}
