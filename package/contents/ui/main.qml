/*
    Copyright 2017 Andreas Krutzler <andreas.krutzler@gmx.net>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 6.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 6.0 as QtControls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components as PC
import org.kde.plasma.plasmoid 2.0

// plasma pulseaudio plugin
import org.kde.plasma.private.volume 0.1
import org.kde.kirigami as Kirigami
import "script.js" as Script
//import org.kde.ksvg as KSvg
import QtQuick.Shapes

PlasmoidItem {
    id: main


    property var currentDeviceHovered: null
 
    preferredRepresentation: fullRepresentation

    property int labeling: plasmoid.configuration.labeling
    property int naming: plasmoid.configuration.naming
    property bool useVerticalLayout: plasmoid.configuration.useVerticalLayout
    property bool sourceInsteadofSink: plasmoid.configuration.sourceInsteadofSink
    property string cfg_deviceIconList: String(Plasmoid.configuration.deviceIconList)

    readonly property var sinkModelFiltered: PulseObjectFilterModel {
        id: sinkModelFiltered
        filterOutInactiveDevices: true  // ← This avoids showing devices that can't be selected.
        filterVirtualDevices: false
        sourceModel: SinkModel {}
    }
    readonly property var sourceModelFiltered: PulseObjectFilterModel {
        id: sourceModelFiltered
        filterOutInactiveDevices: true  // ← This avoids showing devices that can't be selected.
        filterVirtualDevices: false
        sourceModel: SourceModel {}
    }
    property var filteredModel: sourceInsteadofSink ? sourceModelFiltered : sinkModelFiltered

    property string defaultIconName: plasmoid.configuration.defaultIconName


    function getIcon(device, currentPort, description) {
        var icon = Script.getIconFromConfig(cfg_deviceIconList, description)
        return icon != "" ? icon : Script.formFactorIcon(device, currentPort, defaultIconName)
    }

    function volumePercent(volume) {
        return Math.round(volume / PulseAudio.NormalVolume * 100.0);
    }

       function toVolume(percent) {
        return percent * PulseAudio.NormalVolume / 100
        //return Math.round(volume / PulseAudio.NormalVolume * 100.0);
    }

   // compactRepresentation: CompactIcon{}

 //fullRepresentation: compactRepresentation
    fullRepresentation: GridLayout {
        id: gridLayout
        Layout.minimumWidth: gridLayout.implicitWidth
        Layout.minimumHeight: gridLayout.implicitHeight    
        flow: useVerticalLayout? GridLayout.TopToBottom : GridLayout.LeftToRight
        anchors.fill: parent

        Repeater {
            id: repeater_bt
            model: filteredModel

            //delegate: PC.ToolButton { 
            delegate: QtControls.ToolButton {
                readonly property var device: model.PulseObject
                readonly property var currentPort: model.Ports[ActivePortIndex]
                readonly property string currentDescription: getNaming(model, device, currentPort)

                id: tab
                enabled: currentPort !== null

                text: labeling !== 2 ? currentDescription + (device.muted ? " (muted)" : "") : ""
                icon.name: labeling !== 1 ? getIcon(device, currentPort, model.Description) : ""

                checkable: true
                autoExclusive: true

                hoverEnabled: true
                onHoveredChanged: () =>  {
                    main.currentDeviceHovered = hovered == false ? null: tab.device
                }

                PlasmaCore.ToolTipArea {
                    id: toolTip
                    anchors.fill: parent
                    mainText: tab.currentDescription + (tab.device.muted ? " (muted)" : "")
                    subText: i18n("Volume at %1%", volumePercent(tab.device.volume));
                    textFormat: Text.PlainText
                }

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: -1

                Binding {
                    target: tab
                    property: "checked"
                    value: device.default
                }

                Shape {
                    id: ms
                    width: parent.width
                    height: parent.height
                    property int offset: 5
                    ShapePath {
                        strokeWidth: 2
                        strokeColor: "red"
                        startX: ms.offset; startY: ms.offset
                        PathSvg { path: "L " + ( ms.width - ms.offset ) + " " + ( ms.height - ms.offset ) + " z" }
                    }
                    visible: model.Muted
                }

                MouseArea {
                    property int wheelDelta: 0
                    anchors.fill: parent
                    //hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onPressed: (mouse) => {
                        if (mouse.button == Qt.LeftButton) {
                            device.default = true
                        }
                        else if (mouse.button == Qt.MiddleButton) {
                            model.Muted = !model.Muted
                        }
                    }
                    onWheel: wheel => {
                        var vol = volumePercent(device.volume)
                        const delta = (wheel.inverted ? -1 : 1) * (wheel.angleDelta.y ? wheel.angleDelta.y : -wheel.angleDelta.x);
                        wheelDelta += delta;
                        // Magic number 120 for common "one click"
                        // See: https://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                        while (wheelDelta >= 120) {
                            wheelDelta -= 120;
                            if (wheel.modifiers & Qt.ShiftModifier) {
                                vol += 1
                            } else {
                                vol += 5
                            }
                            vol = Math.min(vol,100)
                        }
                        while (wheelDelta <= -120) {
                            wheelDelta += 120;
                            if (wheel.modifiers & Qt.ShiftModifier) {
                                vol -= 1
                            } else {
                                vol -= 5
                            }
                            //Math.max(vol,0) //does it not works with negative numbers?
                            if(vol < 0) { vol = 0 }
                        }
                        device.volume = toVolume(vol)
                        model.Muted = vol == 0
                    }
                }
            }
        }
    }
}
