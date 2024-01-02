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

    private var InitialYOffsetPercent = 0.17f;
    private var LedButtonDimensionsPercent = 0.23f;
    private var LedButtonPaddingPercent = 0.05f;
    private var LedDataExpectedSize = 1;
    private var Led4DataIndex = 0;

    private var mDataModel as DeviceDataModel;
    private var mLed4State as Number;
    private var mYOffset as Number;
    private var mLedButtonPosition as Array<Number>;  // x, y, width, height

    //! Constructor
    //! @param dataModel The data to show
    public function initialize(dataModel as DeviceDataModel) {
        View.initialize();

        mDataModel = dataModel;
        mLed4State = LED_STATE_OFF;
        mYOffset = 0;
        mLedButtonPosition = [0, 0, 0, 0];
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        System.println("onUpdate()");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var isConnected = mDataModel.isConnected();
        var statusString;
        if (isConnected) {
            statusString = "Connected";
        } else {
            statusString = "Waiting for\nConnection...";
        }

        dc.drawText(dc.getWidth() / 2, InitialYOffsetPercent * dc.getHeight(), Graphics.FONT_MEDIUM, statusString, Graphics.TEXT_JUSTIFY_CENTER);

        var profile = mDataModel.getActiveProfile();
        if (isConnected && (profile != null)) {
            drawProfileData(dc, profile.getCustomDataByteArray(), profile.getLedDataByteArray());
            drawLedButton(dc);
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
        mYOffset = InitialYOffsetPercent * dc.getHeight() + fontHeight;

        if (customData != null) {
            var dataSize = customData.size();
            System.println("  customData.size() " + dataSize);
            var dataSizeLabel = "dataSize: " + dataSize.toString();
            dc.drawText(dc.getWidth() / 2, mYOffset, font, dataSizeLabel, Graphics.TEXT_JUSTIFY_CENTER);
            mYOffset += fontHeight;
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
                dc.drawText(dc.getWidth() / 2, mYOffset, font, dataValuesLabel, Graphics.TEXT_JUSTIFY_CENTER);
                mYOffset += fontHeight;
                if (mLedButtonPosition[0] == 0) {
                    // LED button position hasn't been set so do that now
                    var screenWidth = dc.getWidth();
                    var screenHeight = dc.getHeight();
                    mYOffset += LedButtonPaddingPercent * screenHeight;
                    mLedButtonPosition[2] = LedButtonDimensionsPercent * screenWidth;  // width
                    mLedButtonPosition[3] = LedButtonDimensionsPercent * screenHeight;  // height
                    mLedButtonPosition[0] = (screenWidth - mLedButtonPosition[2]) / 2;  // x
                    mLedButtonPosition[1] = mYOffset;  // y
                    mYOffset += mLedButtonPosition[3];
                }
            }
        }

        if (ledData != null) {
            var ledDataSize = ledData.size();
            if (ledDataSize > 0) {
                System.println("  ledData.size() " + ledDataSize);
                if (LedDataExpectedSize != ledDataSize) {
                    System.println("  Warning: ledData.size() " + ledDataSize + ", expected " + LedDataExpectedSize);
                }
                
                var led4Data = ledData[Led4DataIndex];
                if (led4Data < LED_STATE_COUNT) {
                    mLed4State = led4Data;
                    System.println("  mLed4State " + mLed4State);
                } else {
                    System.println("  unsupported state led4Data  " + led4Data);
                }
            }
        }
    }

    public function drawLedButton(dc as Dc) as Void {
        System.println("drawLedButton(), mLed4State: " + mLed4State);
        dc.setColor(
            mLed4State == LED_STATE_OFF ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_YELLOW,
            Graphics.COLOR_BLACK
        );
        dc.fillRectangle(
            mLedButtonPosition[0],
            mLedButtonPosition[1],
            mLedButtonPosition[2],
            mLedButtonPosition[3]
        );
    }

    // Using a Selectable / Button Type would be better, but this will work as a hacky solution for now.
    public function onTapEvent(x as Number, y as Number) as Void {
        System.println("onTapEvent()");
        if (x >= mLedButtonPosition[0] && x <= mLedButtonPosition[0] + mLedButtonPosition[2] &&
            y >= mLedButtonPosition[1] && y <= mLedButtonPosition[1] + mLedButtonPosition[3]) {
            mLed4State = mLed4State == LED_STATE_OFF ? LED_STATE_ON : LED_STATE_OFF;
            System.println("  new mLed4State: " + mLed4State);
            var profile = mDataModel.getActiveProfile();
            profile.writeLedDataByteArray([mLed4State]b);

            WatchUi.requestUpdate();
        }
    }
}
