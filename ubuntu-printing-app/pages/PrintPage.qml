/*
 * Copyright 2016, 2017 Canonical Ltd.
 *
 * This file is part of ubuntu-printing-app.
 *
 * ubuntu-printing-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * ubuntu-printing-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored-by: Andrew Hayzen <andrew.hayzen@canonical.com>
 */
import QtQuick 2.4
import QtQuick.Layouts 1.1

import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu_Printing_App 1.0
import Ubuntu.Settings.Printers 0.1

import "../components"

Page {
    id: page
    anchors {
        fill: parent
    }
    header: PageHeader {
        id: pageHeader
        leadingActionBar {
            actions: [
                Action {
                    iconName: "back"

                    onTriggered: Qt.quit()
                }
            ]
        }
        title: printing.pdfMode ? i18n.tr("Page Setup") : i18n.tr("Printer Options")
    }

    property Document currentDocument: null
    property QtObject printing: null

    ScrollView {
        id: scrollView
        anchors {
            bottom: printRow.top
            left: parent.left
            right: parent.right
            top: page.header.bottom
        }

        ColumnLayout {
            id: columnLayout
            spacing: units.gu(1)
            width: page.width

            PreviewRow {
                document: currentDocument
                Layout.fillHeight: true
                printerJob: printing.printerJob
                view: scrollView
            }

            SelectorRow {
                id: printerSelector
                delegate: OptionSelectorDelegate {
                    text: name
                }
                model: Printers.allPrintersWithPdf
                text: i18n.tr("Printer")

                onSelectedIndexChanged: printing.printerSelectedIndex = selectedIndex

                Component.onCompleted: printing.printerSelectedIndex = selectedIndex
             }

            TextFieldRow {
                enabled: !printing.pdfMode
                inputMethodHints: Qt.ImhDigitsOnly
                text: i18n.tr("Copies")
                validator: IntValidator {
                    bottom: 1
                    top: 999
                }
                value: printing.printerJob.copies

                onValueChanged: {
                    if (acceptableInput) {
                        printing.printerJob.copies = Number(value);
                    }
                }
            }

//                CheckBoxRow {
////                    checked: printer.collate
//                    checkboxText: i18n.tr("Collate")
//                    enabled: printerJob.copies > 1 //&& !printer.pdfMode

////                    onCheckedChanged: printer.collate = checked
//                }

            SelectorRow {
                id: duplexSelector
                enabled: printing.printer && !printing.pdfMode ? printing.printer.supportedDuplexModes.length > 1 : false
                model: printing.printer ? printing.printer.supportedDuplexModes : [""]
                text: i18n.tr("Two-sided")

                onSelectedIndexChanged: {
                    if (printing.printerJob.duplexMode !== selectedIndex) {
                        printing.printerJob.duplexMode = selectedIndex
                    }
                }

                Binding {
                    target: duplexSelector
                    property: "selectedIndex"
                    when: printing.printerJob && duplexSelector.enabled
                    value: printing.printerJob.duplexMode
                }
            }

            SelectorRow {
                id: pageRangeSelector
                enabled: !printing.pdfMode
                model: [i18n.tr("All"), i18n.tr("Range")]
                modelValue: [PrinterEnum.AllPages, PrinterEnum.PageRange]
                selectedIndex: 0
                text: i18n.tr("Pages")

                onSelectedValueChanged: printing.printerJob.printRangeMode = selectedValue
            }

            TextFieldRow {
                enabled: !printing.pdfMode
                validator: RegExpValidator {
//                        regExp: ""  // TODO: validate to only 0-9||9-0||0 ,
                }
                visible: pageRangeSelector.selectedValue === PrinterEnum.PageRange

                onValueChanged: printing.printerJob.printRange = value
            }

            LabelRow {
                enabled: !printing.pdfMode
                secondaryText: i18n.tr("eg 1-3,8")
                visible: pageRangeSelector.selectedValue === PrinterEnum.PageRange
            }

//                SelectorRow {
//                    enabled: !printer.pdfMode
//                    model: [1, 2, 4, 6, 9]
//                    selectedIndex: 0
//                    text: i18n.tr("Pages per side")
//                }

            SelectorRow {
                id: colorModelSelector
                enabled: printing.printer && !printing.pdfMode ? printing.printer.supportedColorModels.length > 1 : false
                model: printing.printer ? printing.printer.supportedColorModels : [""]
                text: i18n.tr("Color")

                onSelectedIndexChanged: {
                    if (printing.printerJob.colorModel !== selectedIndex) {
                        printing.printerJob.colorModel = selectedIndex
                    }
                }

                Binding {
                    target: colorModelSelector
                    property: "selectedIndex"
                    when: printing.printerJob && colorModelSelector.enabled
                    value: printing.printerJob.colorModel
                }
            }

            SelectorRow {
                id: qualitySelector
                enabled: printing.printer && !printing.pdfMode ? printing.printer.supportedPrintQualities.length > 1 : false
                model: printing.printer ? printing.printer.supportedPrintQualities : [""]
                text: i18n.tr("Quality")

                onSelectedIndexChanged: {
                    if (printing.printerJob.quality !== selectedIndex) {
                        printing.printerJob.quality = selectedIndex
                    }
                }

                Binding {
                    target: qualitySelector
                    property: "selectedIndex"
                    when: printing.printerJob && qualitySelector.enabled
                    value: qualitySelector.quality
                }
            }

            Item {
                height: units.gu(2)
                width: parent.width
            }
        }
    }

    PrintRow {
        id: printRow
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
        }
        pdfMode: printing.pdfMode
        sheets: document.count

        onCancel: Qt.quit()
        onConfirm: {
            if (printing.pdfMode) {
                // TODO: check if .toLocalFilepath() needs to be called?
                pageStack.push(Qt.resolvedUrl("ContentPeerPickerPage.qml"), {"url": document.url});
            } else {
                printing.printerJob.printFile(document.url);  // TODO: check document is valid raise error if not?
            }
        }
    }
}
