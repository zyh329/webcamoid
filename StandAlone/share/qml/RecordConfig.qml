/* Webcamoid, webcam capture application.
 * Copyright (C) 2011-2016  Gonzalo Exequiel Pedone
 *
 * Webcamoid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Webcamoid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Webcamoid. If not, see <http://www.gnu.org/licenses/>.
 *
 * Web-Site: http://webcamoid.github.io/
 */

import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

ColumnLayout {
    id: recRecordConfig

    function updateFields()
    {
        txtDescription.text = Webcamoid.recordingFormatDescription(Webcamoid.curRecordingFormat)
    }

    function makeFilters()
    {
        var filters = []
        var recordingFormats = Webcamoid.recordingFormats;

        for (var format in recordingFormats) {
            var suffix = Webcamoid.recordingFormatSuffix(recordingFormats[format])
            var filter = Webcamoid.recordingFormatDescription(recordingFormats[format])
                         + " (*."
                         + suffix.join(" *.")
                         + ")"

            filters.push(filter)
        }

        return filters
    }

    function makeDefaultFilter()
    {
        var suffix = Webcamoid.recordingFormatSuffix(Webcamoid.curRecordingFormat)
        var filter = Webcamoid.recordingFormatDescription(Webcamoid.curRecordingFormat)
                     + " (*."
                     + suffix.join(" *.")
                     + ")"

        return filter
    }

    function defaultSuffix()
    {
        return Webcamoid.recordingFormatSuffix(Webcamoid.curRecordingFormat)[0]
    }

    function makeFileName()
    {
        return qsTr("Video %1.%2").arg(Webcamoid.currentTime()).arg(defaultSuffix())
    }

    Connections {
        target: Webcamoid
        onCurRecordingFormatChanged: updateFields()

        onRecordingChanged: {
            if (recording) {
                lblRecordLabel.text = qsTr("Stop recording video")
                imgRecordIcon.source = "qrc:/icons/hicolor/scalable/record-stop.svg"
            } else {
                lblRecordLabel.text = qsTr("Start recording video")
                imgRecordIcon.source = "qrc:/icons/hicolor/scalable/record-start.svg"
            }
        }

        onInterfaceLoaded: {
            Webcamoid.removeInterface("itmRecordControls");
            Webcamoid.embedRecordControls("itmRecordControls", "");
        }
    }

    Label {
        text: qsTr("Description")
        font.bold: true
        Layout.fillWidth: true
    }
    TextField {
        id: txtDescription
        text: Webcamoid.recordingFormatDescription(Webcamoid.curRecordingFormat)
        placeholderText: qsTr("Insert format description")
        readOnly: true
        Layout.fillWidth: true
    }

    ScrollView {
        id: scrollControls
        Layout.fillWidth: true
        Layout.fillHeight: true

        contentItem: RowLayout {
            id: itmRecordControls
            objectName: "itmRecordControls"
            width: scrollControls.viewport.width
        }
    }

    Label {
        id: lblRecordLabel
        text: qsTr("Start recording video")
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: rectangle1
        Layout.fillWidth: true
        Layout.preferredHeight: 48

        gradient: Gradient {
            GradientStop {
                id: gradTop
                position: 0
                color: "#1f1f1f"
            }

            GradientStop {
                id: gradMiddle
                position: 0.5
                color: "#000000"
            }

            GradientStop {
                id: gradBottom
                position: 1
                color: "#1f1f1f"
            }
        }

        Image {
            id: imgRecordIcon
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/icons/hicolor/scalable/record-start.svg"
        }

        MouseArea {
            id: msaRecord
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent

            onEntered: {
                gradTop.color = "#2e2e2e"
                gradMiddle.color = "#0f0f0f"
                gradBottom.color = "#2e2e2e"
            }
            onExited: {
                gradTop.color = "#1f1f1f"
                gradMiddle.color = "#000000"
                gradBottom.color = "#1f1f1f"
                imgRecordIcon.scale = 1
            }
            onPressed: imgRecordIcon.scale = 0.75
            onReleased: imgRecordIcon.scale = 1
            onClicked: {
                if (Webcamoid.recording)
                    Webcamoid.stopRecording();
                else {
                    var filters = recRecordConfig.makeFilters()

                    var fileUrl = Webcamoid.saveFileDialog(qsTr("Save video as..."),
                                             recRecordConfig.makeFileName(),
                                             Webcamoid.standardLocations("movies")[0],
                                             "." + recRecordConfig.defaultSuffix(),
                                             recRecordConfig.makeDefaultFilter())

                    if (fileUrl !== "")
                        Webcamoid.startRecording(fileUrl)
                }
            }
        }
    }
}
