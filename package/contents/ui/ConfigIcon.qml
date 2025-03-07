import QtQuick 6.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 6.0 as QtControls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.private.volume 0.1
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import "script.js" as Script

KCM.SimpleKCM {
    property string cfg_deviceIconList: String(Plasmoid.configuration.deviceIconList)
    property string defaultIconName: plasmoid.configuration.defaultIconName
    property bool sourceInsteadofSink: plasmoid.configuration.sourceInsteadofSink
    readonly property var sinkModelFiltered: PulseObjectFilterModel {
        id: sinkModelFiltered
        filters: []
        filterOutInactiveDevices: true  // ← This avoids showing devices that can't be selected.
        filterVirtualDevices: false
        sourceModel: SinkModel {}
    }
    readonly property var sourceModelFiltered: PulseObjectFilterModel {
        id: sourceModelFiltered
        filters: []
        filterOutInactiveDevices: true  // ← This avoids showing devices that can't be selected.
        filterVirtualDevices: false
        sourceModel: SourceModel {}
    }
    property var filteredModel: sourceInsteadofSink ? sourceModelFiltered : sinkModelFiltered

    function getDeviceIcon(description) {
        return Script.getIconFromConfig(cfg_deviceIconList, description)
    }

    function getDefaultIcon(model, index) {
        return Script.formFactorIcon(model.PulseObject, model.Ports[index], defaultIconName)
    }

    function storeConfiguration(repeater) {
        var new_config = "";
        //console.log(repeater.delegate + " " + repeater.count )
        for (var i = 0; i < repeater.count; i++) {
            var item = repeater.itemAt(i)
            //console.log("icon " + i + ":" + item.icon )
            if(item.icon != "") {
                var entry = item.text + ";" + item.icon;
                if( new_config != "") {
                    new_config += ",";
                }
                new_config += entry;
            }
           
        }
        cfg_deviceIconList = new_config;
        Plasmoid.configuration.deviceIconList = new_config
        //console.log(cfg_deviceIconList);
    }

    GridLayout {
        id: iconGridLayout
        flow: GridLayout.TopToBottom
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        Repeater {
            id: repeater_id
            model: filteredModel
            delegate: ConfigIconRow {
                id: bt
                text: model.Description
                default_icon: getDefaultIcon(model, ActivePortIndex)
                icon: getDeviceIcon(model.Description)
                onDeviceIconChanged: () => storeConfiguration(repeater_id)
            }
        }
     }
    
}