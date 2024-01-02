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

    private var InitialYOffsetPercent = 0.12f;
    private var ButtonDimensionsPercent = 0.23f;
    private var ButtonXPaddingPercent = 0.07f;
    private var ButtonYPaddingPercent = 0.05f;
    private var LedDataExpectedSize = 1;
    private var Led4DataIndex = 0;

    private var mDataModel as DeviceDataModel;
    private var mLed4State as Number;
    private var mYOffset as Number;
    private var buttonPositionsSet as Boolean;
    private var mLedButtonPosition as Array<Number>;  // x, y, width, height
    private var mGpio11ButtonPosition as Array<Number>;  // x, y, width, height

    //! Constructor
    //! @param dataModel The data to show
    public function initialize(dataModel as DeviceDataModel) {
        View.initialize();

        mDataModel = dataModel;
        mLed4State = LED_STATE_OFF;
        mYOffset = 0;
        buttonPositionsSet = false;
        mLedButtonPosition = [0, 0, 0, 0];
        mGpio11ButtonPosition = [0, 0, 0, 0];
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
            drawProfileData(dc, profile.getCustomDataByteArray(), profile.getGpioDataByteArray());
            drawButtons(dc);
        }
    }

    //! Update the screen with the data received
    //! @param dc Device context
    //! @param customData The custom data
    //! @param gpioData The LED data
    private function drawProfileData(dc as Dc, customData as ByteArray?, gpioData as ByteArray?) as Void {
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
                    // Treat in incoming customData as numeric, only print the first few
                    var MAX_DISPLAY_COUNT = 5;
                    var displayCount = dataSize > MAX_DISPLAY_COUNT ? MAX_DISPLAY_COUNT - 1 : dataSize - 1;
                    for (var i = 0; i < displayCount; i++) {
                        dataValuesLabel += customData[i].format("%3d") + ",";
                    }
                    dataValuesLabel += customData[displayCount].format("%3d");
                }
                System.println("  dataValuesLabel " + dataValuesLabel);
                dc.drawText(dc.getWidth() / 2, mYOffset, font, dataValuesLabel, Graphics.TEXT_JUSTIFY_CENTER);
                mYOffset += fontHeight;
                setButtonPositions(dc);  // Needs to happen after the custom data has been drawn the first time
            }
        }

        if (gpioData != null) {
            var ledDataSize = gpioData.size();
            if (ledDataSize > 0) {
                System.println("  gpioData.size() " + ledDataSize);
                if (LedDataExpectedSize != ledDataSize) {
                    System.println("  Warning: gpioData.size() " + ledDataSize + ", expected " + LedDataExpectedSize);
                }
                
                var led4Data = gpioData[Led4DataIndex];
                if (led4Data < LED_STATE_COUNT) {
                    mLed4State = led4Data;
                    System.println("  mLed4State " + mLed4State);
                } else {
                    System.println("  unsupported state led4Data  " + led4Data);
                }
            }
        }
    }

    public function drawButtons(dc as Dc) as Void {
        System.println("drawButtons(), mLed4State: " + mLed4State);

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

        dc.setColor(
            Graphics.COLOR_GREEN,
            Graphics.COLOR_BLACK
        );
        dc.fillRectangle(
            mGpio11ButtonPosition[0],
            mGpio11ButtonPosition[1],
            mGpio11ButtonPosition[2],
            mGpio11ButtonPosition[3]
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var font = Graphics.FONT_SYSTEM_XTINY;
        var ledButtonXCenter = mLedButtonPosition[0] + mLedButtonPosition[2] / 2;
        var gpio11ButtonXCenter = mGpio11ButtonPosition[0] + mGpio11ButtonPosition[2] / 2;
        var buttonYCenter = mLedButtonPosition[1] + mLedButtonPosition[3] / 2 - dc.getFontHeight(font) / 2;
        dc.drawText(ledButtonXCenter, buttonYCenter, font, "LED_4", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(gpio11ButtonXCenter, buttonYCenter, font, "GPIO_11", Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function setButtonPositions(dc as Dc) as Void {
        if (!buttonPositionsSet) {
            var screenWidth = dc.getWidth();
            var screenXCenter = screenWidth / 2;
            var screenHeight = dc.getHeight();
            var buttonXPadding = ButtonXPaddingPercent * screenWidth;
            mYOffset += ButtonYPaddingPercent * screenHeight;
            mLedButtonPosition[2] = ButtonDimensionsPercent * screenWidth;  // width
            mLedButtonPosition[3] = ButtonDimensionsPercent * screenHeight;  // height
            mLedButtonPosition[0] = screenXCenter - buttonXPadding - mLedButtonPosition[2];  // x
            mLedButtonPosition[1] = mYOffset;  // y

            mGpio11ButtonPosition[2] = mLedButtonPosition[2]; // width
            mGpio11ButtonPosition[3] = mLedButtonPosition[3]; // height
            mGpio11ButtonPosition[0] = screenXCenter + buttonXPadding;  // x
            mGpio11ButtonPosition[1] = mYOffset;  // y

            mYOffset += mLedButtonPosition[3];
            buttonPositionsSet = true;
        }
    }

    // Using a Selectable / Button Type would be better, but this will work as a hacky solution for now.
    public function onTapEvent(x as Number, y as Number) as Void {
        System.println("onTapEvent()");
        if (x >= mLedButtonPosition[0] && x <= mLedButtonPosition[0] + mLedButtonPosition[2] &&
            y >= mLedButtonPosition[1] && y <= mLedButtonPosition[1] + mLedButtonPosition[3]) {
            mLed4State = mLed4State == LED_STATE_OFF ? LED_STATE_ON : LED_STATE_OFF;
            System.println("  new mLed4State: " + mLed4State);
            var profile = mDataModel.getActiveProfile();
            profile.writeGpioDataByteArray([mLed4State]b);

            WatchUi.requestUpdate();
        }
    }
}
