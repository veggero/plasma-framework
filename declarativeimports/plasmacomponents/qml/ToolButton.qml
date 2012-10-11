/*
*   Copyright (C) 2011 by Daker Fernandes Pinheiro <dakerfp@gmail.com>
*   Copyright (C) 2011 by Marco Martin <mart@kde.org>
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 2, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU Library General Public License for more details
*
*   You should have received a copy of the GNU Library General Public
*   License along with this program; if not, write to the
*   Free Software Foundation, Inc.,
*   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/**Documented API
Inherits:
        Item

Imports:
        QtQuick 1.1
        org.kde.plasma.core

Description:
        A plasma theme based toolbutton.

Properties:
        bool flat:
        Returns true if the button is flat.

        bool checked: false
        Returns true if the button is checked.

        bool checkable:
        Returns true if the button is checkable.

        bool pressed:
        Returns true if the button is pressed.
        alias text:
        Sets the text for the button.

        variant iconSource:
        Sets the icon for the button.
        It can be any image from any protocol supported by the Image element, or a freedesktop-compatible icon name

        string font:
        Sets the font for the button.

	bool enabled:
	Returns whether the button is currently enabled and receives user input.

Signals:
        onClicked:
        The signal is being emmited when the button is being clicked.
**/

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import "private" as Private

Item {
    id: button

    // Commmon API
    property bool flat: true
    property bool checked: defaultAction ? defaultAction.checked : false
    property bool checkable: defaultAction ? defaultAction.checkable : false
    property alias pressed: mouse.pressed
    property alias text: label.text
    property alias iconSource: icon.source
    property alias font: label.font

    signal clicked()

    // Plasma extensiuons
    property QtObject defaultAction


    enabled: defaultAction==undefined||defaultAction.enabled

    implicitWidth: {
        if (label.paintedWidth == 0) {
            return implicitHeight
        } else {
            return icon.width + label.paintedWidth + delegate.margins.left + delegate.margins.right + ((icon.valid) ? delegate.margins.left : 0)
        }
    }
    implicitHeight: Math.max(theme.defaultFont.mSize.height*1.6, Math.max(icon.height, label.paintedHeight) + delegate.margins.top/2 + delegate.margins.bottom/2)

    // TODO: needs to define if there will be specific graphics for
    //     disabled buttons
    opacity: enabled ? 1.0 : 0.5

    Keys.onSpacePressed: internal.userPressed = true
    Keys.onReturnPressed: internal.userPressed = true
    Keys.onReleased: {
        internal.userPressed = false
        if (event.key == Qt.Key_Space ||
            event.key == Qt.Key_Return)
            internal.clickButton()
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            shadow.state = "focus"
        } else if (checked) {
            shadow.state = "hidden"
        } else {
            shadow.state = "shadow"
        }
    }

    QtObject {
        id: internal
        property bool userPressed: false

        function clickButton()
        {
            if (!button.enabled) {
                return
            }

            if (defaultAction && defaultAction.checkable) {
                defaultAction.checked = !defaultAction.checked
            } else if (button.checkable) {
                button.checked = !button.checked
            }

            if (button.KeyNavigation.tab || button.KeyNavigation.backtab) {
                // Only focus the button if it is set up for keyboard
                // navigation. This avoid getting a strange focus frame around
                // buttons which are usually not focusable, such as buttons in
                // a toolbar.
                button.forceActiveFocus();
            }
            button.clicked()

            if (defaultAction) {
                defaultAction.trigger()
            }
        }
    }

    Loader {
        id: delegate
        anchors.fill:parent
        property QtObject margins: item.margins
        property string shadowState: "shadow"
        sourceComponent: {
            if (label.text.length == 0 && button.width == button.height) {
                return roundButtonComponent
            } else {
                return buttonComponent
            }
        }
    }

    Component {
        id: buttonComponent
        Item {
            anchors.fill: parent
            property alias margins: surface.margins
            Private.ButtonShadow {
                id: shadow
                anchors.fill: parent
                visible: !flat
                state: delegate.shadowState
            }

            PlasmaCore.FrameSvgItem {
                id: surface

                anchors.fill: parent
                imagePath: "widgets/button"
                prefix: (internal.userPressed || checked) ? "pressed" : "normal"
                //internal: if there is no hover status, don't paint on mouse over in touchscreens
                opacity: (internal.userPressed || checked || !flat || (shadow.hasOverState && mouse.containsMouse && button.enabled)) ? 1 : 0
                Behavior on opacity {
                    PropertyAnimation { duration: 250 }
                }
            }
        }
    }

    Component {
        id: roundButtonComponent
        Item {
            anchors.fill: parent
            property QtObject margins: QtObject {
                property int left: width/8
                property int top: width/8
                property int right: width/8
                property int bottom: width/8
            }
            Private.RoundShadow {
                id: roundShadow
                visible: !flat
                anchors.fill: parent
                state: delegate.shadowState
            }

            PlasmaCore.Svg {
                id: buttonSvg
                imagePath: "widgets/actionbutton"
            }

            PlasmaCore.SvgItem {
                id: buttonItem
                svg: buttonSvg
                elementId: (internal.userPressed || checked) ? "pressed" : "normal"
                width: parent.height
                height: width
                //internal: if there is no hover status, don't paint on mouse over in touchscreens
                opacity: (internal.userPressed || checked || !flat || (roundShadow.hasOverState && mouse.containsMouse)) ? 1 : 0
                Behavior on opacity {
                    PropertyAnimation { duration: 250 }
                }
            }
        }
    }

    Item {
        anchors {
            fill: parent
            leftMargin: delegate.margins.left
            topMargin: delegate.margins.top
            rightMargin: delegate.margins.right
            bottomMargin: delegate.margins.bottom
        }

        Private.IconLoader {
            id: icon

            anchors {
                verticalCenter: parent.verticalCenter
                left: label.text ? parent.left : undefined
                horizontalCenter: label.text ? undefined : parent.horizontalCenter
            }
            height: roundToStandardSize(parent.height)
            width: height
        }

        Text {
            id: label

            //FIXME: why this is needed?
            onPaintedWidthChanged: {
                icon.anchors.horizontalCenter = label.paintedWidth > 0 ? undefined : icon.parent.horizontalCenter
                icon.anchors.left = label.paintedWidth > 0 ? icon.parent.left : undefined
            }

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: icon.valid ? icon.right : parent.left
                leftMargin: icon.valid ? delegate.margins.left : 0
                right: parent.right
            }
            font.capitalization: theme.defaultFont.capitalization
            font.family: theme.defaultFont.family
            font.italic: theme.defaultFont.italic
            font.letterSpacing: theme.defaultFont.letterSpacing
            font.pointSize: theme.defaultFont.pointSize
            font.strikeout: theme.defaultFont.strikeout
            font.underline: theme.defaultFont.underline
            font.weight: theme.defaultFont.weight
            font.wordSpacing: theme.defaultFont.wordSpacing

            color: mouse.containsMouse ? theme.buttonTextColor : theme.textColor
            Behavior on color { ColorAnimation { duration: 100 } }

            horizontalAlignment: icon.valid ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true

        onPressed: internal.userPressed = true
        onReleased: internal.userPressed = false
        onCanceled: {
            internal.userPressed = false
            delegate.shadowState = "shadow"
        }
        onClicked: internal.clickButton()

        onEntered: {
            if (!flat) {
                delegate.shadowState = "hover"
            }
        }
        onExited: {
            if (!flat) {
                if (button.activeFocus) {
                    delegate.shadowState = "focus"
                } else if (checked) {
                    delegate.shadowState = "hidden"
                } else {
                    delegate.shadowState = "shadow"
                }
            }
        }
    }
}

