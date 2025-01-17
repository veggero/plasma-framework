/*
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2017 The Qt Company Ltd.

    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/


import QtQuick 2.9
import QtQuick.Controls @QQC2_VERSION@
import QtQuick.Templates @QQC2_VERSION@ as T
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.9 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

T.ScrollView {
    id: controlRoot

    clip: true

    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0, contentHeight + topPadding + bottomPadding)


    //create a background only after Component.onCompleted, see on the component creation below for explanation
    Component.onCompleted: {
        if (!controlRoot.background) {
            controlRoot.background = backgroundComponent.createObject(controlRoot);
        }
    }

 
    data: [
        Kirigami.WheelHandler {
            target: controlRoot.contentItem
        },
        Component {
            id: backgroundComponent
            Rectangle {
                color: PlasmaCore.Theme.viewBackgroundColor
                visible: false
                anchors.fill:parent
            }
        }
    ]

    PlasmaComponents3.ScrollBar.vertical: PlasmaComponents3.ScrollBar {
        id: verticalScrollBar
        readonly property Flickable flickableItem: controlRoot.contentItem
        onFlickableItemChanged: {
            flickableItem.clip = true;
        }
        parent: controlRoot
        x: controlRoot.mirrored ? 0 : controlRoot.width - width
        y: controlRoot.topPadding
        height: controlRoot.availableHeight
        active: controlRoot.ScrollBar.horizontal || controlRoot.ScrollBar.horizontal.active
    }

    PlasmaComponents3.ScrollBar.horizontal: PlasmaComponents3.ScrollBar {
        parent: controlRoot
        x: controlRoot.leftPadding
        y: controlRoot.height - height
        width: controlRoot.availableWidth
        active: controlRoot.ScrollBar.vertical || controlRoot.ScrollBar.vertical.active
    }
}
