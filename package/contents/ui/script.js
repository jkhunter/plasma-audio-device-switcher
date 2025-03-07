.pragma library

var Icons = [
    { icon: "audio-card" },
    { icon: "portable" },
    { icon: "computer" },
    { icon: "preferences-system-bluetooth" },
    { icon: "media-removable-symbolic" },
    { icon: "question" },
    { icon: "audio-speakers-symbolic" },
    { icon: "audio-input-microphone" },
    { icon: "audio-headphones" },
    { icon: "audio-headset" },
    { icon: "phone-symbolic" },
    { icon: "handset" },
    { icon: "hands-free" },
    { icon: "tv" },
    { icon: "video-display" },
    { icon: "hifi" },
    { icon: "audio-radio" },
    { icon: "camera-web" },
    { icon: "car" }
]

function getIconFromConfig(configList, description) {
    var items = configList.split(',');
    for (var i = 0; i < items.length; i++) {
         var item = items[i] 
        var definition = item.split(';')
        if(definition.length == 2) {
            if(description == definition[0]) {
                return definition[1]
            } 
        }
    }
    return ""
}

function getDescription(type, model, device, port) {
    // Node nickname, unless it doesn't exist
    if (type !== 0 && type !== 1 && device.properties) {
        const nick = device.properties["node.nick"];
        if (nick) return nick;
    }

    // Port description, unuless it also doesn't exist
    if (type !== 0 && port) {
        const desc = port.description;
        if (desc) return desc;
    }

    // Device description and fallback
    return model.Description;
}

 // Inspired by:
    // https://github.com/KDE/plasma-pa/blob/master/applet/contents/code/icon.js
    // https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/blob/300db779224625144d6279d230c2daa857c967d8/src/modules/alsa/alsa-mixer.c#L2794
    // https://github.com/Apxdono/plasma-audio-device-switcher/commit/762ef92e5129c8b08bd94939bf2e88473217f84e
    
function formFactorIcon(device, port, fallback, useWirePlumberConfig) {
    // On my machine, device.formFactor returns nice values for sources,
    // but mostly useless values for sinks.
    //
    // This code here tries to be "smart" and look at multiple sources for
    // finding the best icon.

    // Some devices (e.g. the Null devices), don't have any ports.
    if (!port) {
        port = {}
    }

    let iconName = device.iconName || ""  // Usually empty, thus useless
    if(useWirePlumberConfig == true) {
        iconName = device.iconName || device.properties["device.icon_name"] || device.properties["device.icon-name"];
    }
    if (iconName) {
        return iconName;
    }

    const data = {
        formFactor:        device.formFactor  || "",  // e.g. "internal", "webcam", "microphone"
        deviceName:        device.name        || "",  // e.g. "alsa_output.pci-0000_00_1f.3.hdmi-stereo-extra1"
        portName:          port.name          || "",  // e.g. "hdmi-output-1"
        deviceDescription: device.description || "",  // e.g. "Built-in Audio Digital Stereo (HDMI 2)"
        portDescription:   port.description   || "",  // e.g. "HDMI / DisplayPort 2"
    }

    // Removing number suffixes:
    data.portName = data.portName.replace(/-[0-9]+$/, "")

    // console.log(JSON.stringify(data, null, 2));  // DEBUG

    const rules = [
        // Generic names and icons. Lowest score.
        {
            icon: "audio-card",
            score: 1,
            formFactor: /^internal$/i,
            portName: /^analog-input$|^analog-input-video|^analog-output(-mono)?$/i
        },
        {
            icon: "audio-card",
            score: 1,
            // LINE in/out don't have good icons.
            portName: /^analog-input-linein|^analog-output-lineout|^multichannel-input|^multichannel-output/i
        },
        {
            icon: "portable",
            score: 2,
            formFactor: /^portable$/i,
        },
        {
            icon: "computer",
            // icon: "computer-symbolic",
            score: 2,
            formFactor: /^computer$/i,
        },
        {
            icon: "preferences-system-bluetooth",
            // icon: "network-bluetooth",
            score: 2,
            deviceName: /^bluez/i,
        },
        {
            icon: "media-removable-symbolic",
            // icon: "drive-removable-media-usb",
            // icon: "drive-removable-media-usb-pendrive",
            score: 2,
            deviceName: /^alsa[^.]+\.usb/i,
        },
        {
            icon: "question",
            score: 1,
            // The Null output and Null input devices.
            deviceName: /^null-/i,
        },

        // Basic audio devices.
        {
            icon: "audio-speakers-symbolic",
            // icon: "speaker",
            score: 3,
            formFactor: /^speaker$/i,
            portName: /^analog-output-speaker/i,
        },
        {
            icon: "audio-input-microphone",
            // icon: "audio-input-microphone-symbolic",
            // icon: "microphone",
            score: 3,
            formFactor: /^microphone$/i,
            portName: /^analog-input-microphone(?!-headset)|analog-input-mic$/i,
        },
        {
            icon: "audio-headphones",
            // icon: "headphone",
            // icon: "headphones",
            score: 3,
            formFactor: /^headphone$/i,
            portName: /^analog-output-headphones?|^virtual-surround-7.1/i,
        },
        {
            icon: "audio-headset",
            // icon: "headset",
            score: 4,
            formFactor: /^headset$/i,
            portName: /^analog-input-microphone-headset|^analog-chat-(input|output)|^steelseries-arctis/i,
        },

        // Mobile phones. Quite unique names.
        {
            // icon: "phone",
            icon: "phone-symbolic",
            score: 3,
            formFactor: /^phone$/i,
        },
        {
            icon: "handset",  // Looks just like the "phone" icon.
            score: 3,
            formFactor: /^handset$/i,
        },
        {
            icon: "hands-free",
            score: 3,
            formFactor: /^hands-free$/i,
        },

        // A/V devices.
        {
            // icon: "video-television",
            icon: "tv",
            // icon: "tv-symbolic",
            score: 4,
            formFactor: /^tv$/i,
        },
        {
            icon: "video-display",
            score: 4,
            portName: /^hdmi-output/i,
        },
        {
            icon: "hifi",
            score: 4,
            formFactor: /^hifi$/i,
            // People using S/PDIF digital signaling are likely using Hi-Fi systems.
            portName: /^iec958-/i,
        },
        {
            icon: "audio-radio",
            // icon: "audio-radio-symbolic",
            // icon: "radio",
            score: 4,
            portName: /^analog-input-radio/,
        },
        {
            icon: "camera-web",
            // icon: "camera-web-symbolic",
            // icon: "webcam",
            score: 4,
            formFactor: /^webcam$/i,
        },

        // Other devices.
        {
            icon: "car",
            score: 4,
            formFactor: /^car$/i,
        },
    ]

    let icon = fallback || "audio-card"
    let score = 0

    // This function may be a bit slow if it is called too often.
    // TODO: Figure out how to cache this result.
    for (const rule of rules) {
        for (const attr of Object.keys(data)) {
            if (rule[attr]) {
                // console.log("TESTING", attr, data[attr], rule[attr])  // DEBUG
                if (rule[attr].test(data[attr])) {
                    // console.log("MATCH!", attr, "=", data[attr], "icon=", rule.icon, "score=", rule.score)  // DEBUG
                    if (rule.score >= score) {
                        icon = rule.icon
                        score = rule.score
                    }
                }
            }
        }
    }

    return icon
}