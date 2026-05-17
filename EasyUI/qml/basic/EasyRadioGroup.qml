import QtQuick

// Internal helper — manages mutual exclusion for EasyRadio
QtObject {
    id: groupRoot

    property var radios: []

    function registerRadio(radio) {
        if (!radios.includes(radio))
            radios.push(radio)
    }

    function unregisterRadio(radio) {
        var idx = radios.indexOf(radio)
        if (idx >= 0)
            radios.splice(idx, 1)
    }

    function onRadioClicked(clickedRadio) {
        for (var i = 0; i < radios.length; i++) {
            if (radios[i] !== clickedRadio) {
                radios[i].checked = false
            } else {
                radios[i].checked = true
            }
        }
    }
}
