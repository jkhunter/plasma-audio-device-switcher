import QtQuick 
import QtQuick.Layouts 
import QtQuick.Controls 
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "script.js" as Script

RowLayout {
    id: main
    signal deviceIconChanged()
    property string text: ""
    property string icon: ""
    property string default_icon: ""
    
    ToolButton  {
        id: button
        icon.name: main.icon != "" ? main.icon : main.default_icon
        onClicked: menu.open()
        Menu {
            id:menu

            MenuItem {
                id: entry
                text: i18n("Default icon")
                icon.name: main.default_icon //Script.formFactorIcon(device, currentPort, defaultIconName)
                onTriggered: { button.onSelection(entry, true) }
            }
            Repeater {
                id: repeater
                model: Script.Icons
                delegate: MenuItem {
                    id: entry
                    text: modelData.icon
                    icon.name: modelData.icon
                    onTriggered: { button.onSelection(entry, false) }
                }
            }
        }

        function onSelection(id, def) {
            button.icon.name = id.icon.name
            if(def == true) {
                main.icon = ""
            } else {
                main.icon = id.icon.name
            }
            //console.log(main.text)
            main.deviceIconChanged()
        } 
    }
    Label {
        text: parent.text//i18n("Default icon")
    }


}