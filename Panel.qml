import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "szaidi.clocker"
  ipcTarget: "szaidi.clocker"
  manageIpc: false

  property var anchorItem: null
  property bool openedFromHotkey: false
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  readonly property string homeDir: Quickshell.env("HOME") || "/home/szaidi"
  readonly property string panelScript: decodeURIComponent(Qt.resolvedUrl("bin/clocker-panel.sh").toString().replace(/^file:\/\//, ""))
  readonly property string zonesPath: homeDir + "/.config/clocker/zones.conf"

  // State from clocker-panel.sh
  property var zones: []
  property int selectedIndex: 0
  property string offsetExpr: ""
  property bool offsetValid: true
  property bool use12h: false
  property string copiedLabel: ""

  // Search city state (modeled after omarchy.weather)
  property bool editingLocation: false
  property int editingSlot: 0
  property var locationSuggestions: []
  property int suggestionIndex: 0
  property var ianaZones: []

  // Inline time scroller state
  property bool editingOffset: false

  readonly property var heroZone: (zones && zones.length > 0)
    ? zones[Math.min(selectedIndex, zones.length - 1)]
    : null
  readonly property string heroCityName: heroZone
    ? Model.cityDisplayName(heroZone.label, heroZone.tz, heroZone.city)
    : "New York"

  readonly property color fgColor: root.bar ? root.bar.foreground : Color.foreground
  readonly property string fontFam: root.bar ? root.bar.fontFamily : Style.font.family
  readonly property int padX: Style.space(20)

  function open() {
    openedFromHotkey = false
    setCenterHoverRevealSuppressed(false)
    root.controller.show()
    root.refresh()
  }

  function openFromHotkey() {
    openedFromHotkey = true
    root.controller.show()
    root.refresh()
    Qt.callLater(function() {
      if (root.opened) setCenterHoverRevealSuppressed(true)
    })
  }

  function openAndEdit(slotIdx) {
    openFromHotkey()
    Qt.callLater(function() {
      startEditingLocation(slotIdx)
    })
  }

  function close() {
    setCenterHoverRevealSuppressed(false)
    if (root.editingLocation) root.cancelEditingLocation()
    if (root.editingOffset) root.cancelEditingOffset()
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.openFromHotkey()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function setCenterHoverRevealSuppressed(value) {
    if (root.bar && typeof root.bar.setCenterHoverRevealSuppressed === "function")
      root.bar.setCenterHoverRevealSuppressed(value)
    else if (root.bar && "centerHoverRevealSuppressed" in root.bar)
      root.bar.centerHoverRevealSuppressed = value
  }

  function refresh() {
    if (panelProc.running) panelProc.running = false
    if (root.offsetExpr !== "") {
      panelProc.command = ["bash", root.panelScript, "--offset", root.offsetExpr]
    } else {
      panelProc.command = ["bash", root.panelScript]
    }
    panelProc.running = true
  }

  function setFormat12h(enable12h) {
    root.use12h = enable12h
    formatSaveProc.command = ["bash", root.panelScript, "--set-format", enable12h ? "12h" : "24h"]
    formatSaveProc.running = true
  }

  // ---- City Search / Slot Picker ----
  function startEditingLocation(slotIdx) {
    if (root.editingOffset) cancelEditingOffset()
    if (slotIdx !== undefined && slotIdx !== null) {
      root.editingSlot = Math.max(0, Math.min(2, slotIdx))
      root.selectedIndex = root.editingSlot
    } else {
      root.editingSlot = Math.max(0, Math.min(2, root.selectedIndex))
    }
    root.editingLocation = true
    root.suggestionIndex = 0
    root.locationSuggestions = Model.searchCities("", root.ianaZones)
    Qt.callLater(function() {
      locationField.text = ""
      locationField.forceActiveFocus()
    })
  }

  function cancelEditingLocation() {
    root.editingLocation = false
    root.locationSuggestions = []
    Qt.callLater(function() {
      if (keyCatcher) keyCatcher.forceActiveFocus()
    })
  }

  function updateCitySuggestions() {
    root.locationSuggestions = Model.searchCities(locationField.text, root.ianaZones)
    root.suggestionIndex = 0
  }

  function pickSuggestion(suggestion) {
    if (!suggestion) return
    saveSlotProc.command = [
      "bash",
      root.panelScript,
      "--set-slot",
      String(root.editingSlot),
      suggestion.label,
      suggestion.tz
    ]
    saveSlotProc.running = true
    root.selectedIndex = root.editingSlot
    cancelEditingLocation()
  }

  function commitLocationSearch() {
    if (root.locationSuggestions.length > 0) {
      var idx = Math.max(0, Math.min(root.suggestionIndex, root.locationSuggestions.length - 1))
      pickSuggestion(root.locationSuggestions[idx])
    } else {
      cancelEditingLocation()
    }
  }

  // ---- Time Scroller (+5h, -90m, 15:00, tomorrow 9am) ----
  function startEditingOffset() {
    if (root.editingLocation) cancelEditingLocation()
    root.editingOffset = true
    Qt.callLater(function() {
      offsetField.text = root.offsetExpr
      offsetField.selectAll()
      offsetField.forceActiveFocus()
    })
  }

  function cancelEditingOffset() {
    root.editingOffset = false
    Qt.callLater(function() {
      if (keyCatcher) keyCatcher.forceActiveFocus()
    })
  }

  function applyOffset(expr) {
    root.offsetExpr = String(expr || "").trim()
    root.editingOffset = false
    root.refresh()
    Qt.callLater(function() {
      if (keyCatcher) keyCatcher.forceActiveFocus()
    })
  }

  function copyZone(z) {
    if (!z) return
    var txt = root.use12h ? (z.copyText12 || z.copyText) : (z.copyText24 || z.copyText)
    copyProc.command = ["wl-copy", txt]
    copyProc.running = true
    root.copiedLabel = z.label
    copiedResetTimer.restart()
  }

  Component.onCompleted: {
    ianaProc.running = true
    refresh()
  }

  Process {
    id: panelProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var raw = String(text || "").trim()
        if (!raw) return
        try {
          var parsed = JSON.parse(raw)
          if (Array.isArray(parsed.zones)) {
            root.zones = parsed.zones.slice(0, 3)
          }
          if (typeof parsed.use12h === "boolean") {
            root.use12h = parsed.use12h
          }
          root.offsetValid = parsed.offsetValid !== false
        } catch (e) {}
      }
    }
  }

  Process {
    id: saveSlotProc
    onExited: function() {
      root.refresh()
    }
  }

  Process {
    id: formatSaveProc
  }

  Process {
    id: ianaProc
    command: ["timedatectl", "list-timezones"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var lines = String(text || "").split("\n")
        var clean = []
        for (var i = 0; i < lines.length; i++) {
          var t = lines[i].trim()
          if (t) clean.push(t)
        }
        root.ianaZones = clean
      }
    }
  }

  Process {
    id: copyProc
  }

  Timer {
    id: copiedResetTimer
    interval: 1600
    onTriggered: root.copiedLabel = ""
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  FileView {
    path: root.zonesPath
    watchChanges: true
    printErrors: false
    onFileChanged: {
      reload()
      root.refresh()
    }
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.openFromHotkey() }
    function close(): void { root.close() }
    function show(): void { root.openFromHotkey() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function edit(): void { root.openAndEdit(0) }
    function refresh(): void { root.refresh() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(560))
    contentHeight: panel.fittedContentHeight(clockerColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: root.editingLocation || root.editingOffset
      onReturnRequested: root.startEditingLocation(root.selectedIndex)
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Flickable {
        id: clockerScroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: clockerColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
          id: clockerColumn
          width: clockerScroll.width
          spacing: Style.space(14)

          // ---- Hero Row: Aligned to [padX .. width - padX] ----
          Item {
            id: heroSection
            width: parent.width - root.padX * 2
            anchors.horizontalCenter: parent.horizontalCenter
            height: Math.max(heroLeft.implicitHeight, heroRight.implicitHeight)

            Row {
              id: heroLeft
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(10)

              Text {
                textFormat: Text.PlainText
                anchors.verticalCenter: parent.verticalCenter
                text: "󰖟"
                color: root.fgColor
                font.family: root.fontFam
                font.pixelSize: 36
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(2)

                Row {
                  spacing: Style.space(5)

                  Text {
                    id: heroTimeText
                    textFormat: Text.PlainText
                    text: root.heroZone
                      ? (root.use12h ? root.heroZone.time12 : root.heroZone.time24)
                      : "—"
                    color: root.fgColor
                    font.family: root.fontFam
                    font.pixelSize: 34
                    font.bold: true
                  }

                  Text {
                    visible: root.use12h && !!root.heroZone
                    anchors.baseline: heroTimeText.baseline
                    textFormat: Text.PlainText
                    text: root.heroZone ? root.heroZone.ampm : ""
                    color: Qt.darker(root.fgColor, 1.35)
                    font.family: root.fontFam
                    font.pixelSize: Style.font.body
                    font.bold: true
                  }
                }

                Text {
                  textFormat: Text.PlainText
                  text: root.offsetExpr !== ""
                    ? (root.offsetValid ? ("SCROLLED · " + root.offsetExpr.toUpperCase()) : "INVALID OFFSET")
                    : "LIVE WORLD TIME"
                  color: !root.offsetValid
                    ? Color.urgent
                    : (root.offsetExpr !== "" ? Color.accent : Qt.darker(root.fgColor, 1.45))
                  font.family: root.fontFam
                  font.pixelSize: Style.font.caption
                  font.letterSpacing: 1
                }
              }
            }

            Column {
              id: heroRight
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(10)

              // Top right controls: [City Search Button] + [12H | 24H Segmented Toggle]
              Row {
                anchors.right: parent.right
                spacing: Style.space(8)

                // Clickable city selector pill
                Rectangle {
                  height: Style.space(24)
                  width: Math.min(Style.space(190), locBtnRow.implicitWidth + Style.space(16))
                  radius: Style.cornerRadius
                  color: root.editingLocation
                    ? Style.hoverFillFor(root.fgColor, Color.accent)
                    : (locBtnMouse.containsMouse ? Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.08) : "transparent")
                  border.width: 1
                  border.color: root.editingLocation
                    ? Color.accent
                    : Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.18)

                  Row {
                    id: locBtnRow
                    anchors.centerIn: parent
                    spacing: Style.space(6)

                    Text {
                      text: ""
                      color: root.editingLocation ? Color.accent : Qt.darker(root.fgColor, 1.3)
                      font.family: root.fontFam
                      font.pixelSize: Style.font.caption
                      anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                      textFormat: Text.PlainText
                      width: Math.min(implicitWidth, Style.space(135))
                      elide: Text.ElideRight
                      text: (root.heroCityName + " (" + (root.heroZone ? root.heroZone.label : "NYC") + ")").toUpperCase()
                      color: root.editingLocation ? Color.accent : root.fgColor
                      font.family: root.fontFam
                      font.pixelSize: Style.font.caption
                      font.letterSpacing: 0.8
                      anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                      text: ""
                      color: root.editingLocation ? Color.accent : Qt.darker(root.fgColor, 1.45)
                      font.family: root.fontFam
                      font.pixelSize: Style.font.caption
                      anchors.verticalCenter: parent.verticalCenter
                    }
                  }

                  MouseArea {
                    id: locBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (root.editingLocation) root.cancelEditingLocation()
                      else root.startEditingLocation(root.selectedIndex)
                    }
                  }
                }

                // 12H / 24H Segmented Toggle Control
                Rectangle {
                  height: Style.space(24)
                  width: fmtToggleRow.implicitWidth + Style.space(4)
                  radius: Style.cornerRadius
                  color: Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.04)
                  border.width: 1
                  border.color: Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.18)

                  Row {
                    id: fmtToggleRow
                    anchors.centerIn: parent
                    spacing: Style.space(2)

                    Rectangle {
                      width: Style.space(34)
                      height: Style.space(20)
                      radius: Math.max(2, Style.cornerRadius - 2)
                      color: root.use12h
                        ? Style.hoverFillFor(root.fgColor, Color.accent)
                        : (btn12Mouse.containsMouse ? Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.08) : "transparent")

                      Text {
                        anchors.centerIn: parent
                        textFormat: Text.PlainText
                        text: "12H"
                        color: root.use12h ? Color.accent : Qt.darker(root.fgColor, 1.4)
                        font.family: root.fontFam
                        font.pixelSize: Style.font.caption
                        font.bold: root.use12h
                      }

                      MouseArea {
                        id: btn12Mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setFormat12h(true)
                      }
                    }

                    Rectangle {
                      width: Style.space(34)
                      height: Style.space(20)
                      radius: Math.max(2, Style.cornerRadius - 2)
                      color: !root.use12h
                        ? Style.hoverFillFor(root.fgColor, Color.accent)
                        : (btn24Mouse.containsMouse ? Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.08) : "transparent")

                      Text {
                        anchors.centerIn: parent
                        textFormat: Text.PlainText
                        text: "24H"
                        color: !root.use12h ? Color.accent : Qt.darker(root.fgColor, 1.4)
                        font.family: root.fontFam
                        font.pixelSize: Style.font.caption
                        font.bold: !root.use12h
                      }

                      MouseArea {
                        id: btn24Mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setFormat12h(false)
                      }
                    }
                  }
                }
              }

              // Hero metadata columns aligned to the right edge
              Row {
                visible: !!root.heroZone
                anchors.right: parent.right
                spacing: Style.space(24)

                Column {
                  spacing: Style.space(2)
                  Text {
                    text: "DATE"
                    color: Qt.darker(root.fgColor, 1.5)
                    font.family: root.fontFam
                    font.pixelSize: Style.font.caption
                    font.letterSpacing: 1
                  }
                  Text {
                    textFormat: Text.PlainText
                    text: root.heroZone ? (root.heroZone.dayShort + ", " + root.heroZone.dateShort) : "—"
                    color: root.fgColor
                    font.family: root.fontFam
                    font.pixelSize: Style.font.body
                  }
                }

                Column {
                  spacing: Style.space(2)
                  Text {
                    text: "OFFSET"
                    color: Qt.darker(root.fgColor, 1.5)
                    font.family: root.fontFam
                    font.pixelSize: Style.font.caption
                    font.letterSpacing: 1
                  }
                  Text {
                    textFormat: Text.PlainText
                    text: root.heroZone
                      ? (root.heroZone.utcOffset + (root.heroZone.dayMarker ? (" (" + root.heroZone.dayMarker + ")") : ""))
                      : "—"
                    color: root.fgColor
                    font.family: root.fontFam
                    font.pixelSize: Style.font.body
                  }
                }
              }
            }
          }

          // ---- Dedicated Full-Width City Search Drawer (when editingLocation is active) ----
          Column {
            id: searchSection
            visible: root.editingLocation
            width: parent.width - root.padX * 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.space(8)

            Rectangle {
              width: parent.width
              height: Style.spacing.hairline
              color: root.fgColor
              opacity: 0.12
            }

            // Slot selector row + Search input aligned on one clean bar
            Item {
              width: parent.width
              height: Style.space(30)

              Row {
                id: slotSelectorRow
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(6)

                Repeater {
                  model: [0, 1, 2]

                  Rectangle {
                    required property int modelData
                    readonly property var slotZone: root.zones.length > modelData ? root.zones[modelData] : null
                    readonly property bool isTarget: root.editingSlot === modelData
                    width: slotPillLabel.implicitWidth + Style.space(14)
                    height: Style.space(26)
                    radius: Style.cornerRadius
                    color: isTarget
                      ? Style.hoverFillFor(root.fgColor, Color.accent)
                      : (slotMouse.containsMouse ? Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.08) : "transparent")
                    border.width: 1
                    border.color: isTarget
                      ? Color.accent
                      : Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.18)

                    Text {
                      id: slotPillLabel
                      anchors.centerIn: parent
                      textFormat: Text.PlainText
                      text: "Slot " + (modelData + 1) + (parent.slotZone ? (" · " + parent.slotZone.label) : "")
                      color: parent.isTarget ? Color.accent : Qt.darker(root.fgColor, 1.3)
                      font.family: root.fontFam
                      font.pixelSize: Style.font.caption
                      font.bold: parent.isTarget
                    }

                    MouseArea {
                      id: slotMouse
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        root.editingSlot = modelData
                        locationField.forceActiveFocus()
                      }
                    }
                  }
                }
              }

              TextField {
                id: locationField
                anchors.left: slotSelectorRow.right
                anchors.leftMargin: Style.space(10)
                anchors.right: closeSearchBtn.left
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: "Search city or timezone for Slot " + (root.editingSlot + 1) + "…"
                foreground: root.fgColor
                font.family: root.fontFam

                onTextChanged: if (root.editingLocation) root.updateCitySuggestions()

                Keys.onPressed: function(event) {
                  if (event.key === Qt.Key_Escape) {
                    root.cancelEditingLocation()
                    event.accepted = true
                  } else if (event.key === Qt.Key_Down) {
                    if (root.suggestionIndex < root.locationSuggestions.length - 1) root.suggestionIndex++
                    event.accepted = true
                  } else if (event.key === Qt.Key_Up) {
                    if (root.suggestionIndex > 0) root.suggestionIndex--
                    event.accepted = true
                  } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.commitLocationSearch()
                    event.accepted = true
                  }
                }
              }

              Rectangle {
                id: closeSearchBtn
                width: Style.space(26)
                height: Style.space(26)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                radius: Style.cornerRadius
                color: closeSearchArea.containsMouse ? Style.hoverFillFor(root.fgColor, Color.accent) : "transparent"
                border.width: 1
                border.color: Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.15)

                Text {
                  anchors.centerIn: parent
                  text: "✕"
                  font.family: root.fontFam
                  color: Qt.darker(root.fgColor, 1.35)
                  font.pixelSize: Style.font.caption
                }

                MouseArea {
                  id: closeSearchArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.cancelEditingLocation()
                }
              }
            }

            // Suggestions list with left city name & right-aligned country/IANA zone
            Column {
              visible: root.locationSuggestions.length > 0
              width: parent.width
              spacing: Style.space(2)

              Repeater {
                model: root.locationSuggestions

                Rectangle {
                  required property var modelData
                  required property int index
                  width: parent.width
                  height: Style.space(28)
                  radius: Style.cornerRadius
                  color: index === root.suggestionIndex
                    ? Style.hoverFillFor(root.fgColor, Color.accent)
                    : "transparent"

                  Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Style.space(10)
                    anchors.verticalCenter: parent.verticalCenter
                    textFormat: Text.PlainText
                    text: modelData.name
                    color: index === root.suggestionIndex
                      ? Style.hoverStateColor(root.fgColor, Color.accent)
                      : root.fgColor
                    font.family: root.fontFam
                    font.pixelSize: Style.font.body
                  }

                  Text {
                    anchors.right: parent.right
                    anchors.rightMargin: Style.space(10)
                    anchors.verticalCenter: parent.verticalCenter
                    textFormat: Text.PlainText
                    text: modelData.description
                    color: Qt.darker(root.fgColor, 1.5)
                    font.family: root.fontFam
                    font.pixelSize: Style.font.caption
                  }

                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: root.suggestionIndex = index
                    onClicked: root.pickSuggestion(modelData)
                  }
                }
              }
            }
          }

          // ---- Hairline divider ----
          Rectangle {
            width: parent.width - root.padX * 2
            anchors.horizontalCenter: parent.horizontalCenter
            height: Style.spacing.hairline
            color: root.fgColor
            opacity: 0.12
          }

          // ---- 3 Favorite Cities Cards (Aligned to [padX .. width - padX]) ----
          Row {
            id: citiesRow
            width: parent.width - root.padX * 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.space(10)

            Repeater {
              model: root.zones

              Rectangle {
                required property var modelData
                required property int index
                readonly property bool isSelected: index === root.selectedIndex
                readonly property string cityFriendly: Model.cityDisplayName(modelData.label, modelData.tz, modelData.city)
                width: Math.floor((citiesRow.width - Style.space(20)) / 3)
                height: cardCol.implicitHeight + Style.space(22)
                radius: Style.cornerRadius
                color: isSelected
                  ? Style.hoverFillFor(root.fgColor, Color.accent)
                  : (cardHover.hovered ? Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.05) : "transparent")
                border.width: 1
                border.color: isSelected
                  ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.45)
                  : Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.12)

                HoverHandler {
                  id: cardHover
                  cursorShape: Qt.PointingHandCursor
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: {
                    root.selectedIndex = index
                    root.copyZone(modelData)
                  }
                }

                Column {
                  id: cardCol
                  width: parent.width - Style.space(24)
                  anchors.centerIn: parent
                  spacing: Style.space(4)

                  // Row 1: City Name on left, Day Marker + Search Button on right
                  Item {
                    width: parent.width
                    height: Style.space(18)

                    Text {
                      anchors.left: parent.left
                      anchors.right: cardHeaderRight.left
                      anchors.rightMargin: Style.space(4)
                      anchors.verticalCenter: parent.verticalCenter
                      textFormat: Text.PlainText
                      elide: Text.ElideRight
                      text: cityFriendly.toUpperCase()
                      color: Qt.darker(root.fgColor, 1.3)
                      font.family: root.fontFam
                      font.pixelSize: Style.font.caption
                      font.letterSpacing: 0.8
                    }

                    Row {
                      id: cardHeaderRight
                      anchors.right: parent.right
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: Style.space(4)

                      Text {
                        visible: modelData.dayMarker !== ""
                        anchors.verticalCenter: parent.verticalCenter
                        textFormat: Text.PlainText
                        text: modelData.dayMarker
                        color: Color.accent
                        font.family: root.fontFam
                        font.pixelSize: Style.font.caption
                        font.bold: true
                      }

                      Rectangle {
                        width: Style.space(18)
                        height: Style.space(18)
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 4
                        color: editCityMouse.containsMouse
                          ? Style.hoverFillFor(root.fgColor, Color.accent)
                          : "transparent"

                        Text {
                          anchors.centerIn: parent
                          text: ""
                          color: editCityMouse.containsMouse ? Color.accent : Qt.darker(root.fgColor, 1.5)
                          font.family: root.fontFam
                          font.pixelSize: Style.font.caption
                        }

                        MouseArea {
                          id: editCityMouse
                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor
                          onClicked: root.startEditingLocation(index)
                        }
                      }
                    }
                  }

                  // Row 2: Big Time + AM/PM aligned on baseline
                  Row {
                    spacing: Style.space(5)

                    Text {
                      id: cardTimeLabel
                      textFormat: Text.PlainText
                      text: root.use12h ? modelData.time12 : modelData.time24
                      color: root.fgColor
                      font.family: root.fontFam
                      font.pixelSize: Style.font.display
                      font.bold: true
                    }

                    Text {
                      visible: root.use12h
                      anchors.baseline: cardTimeLabel.baseline
                      textFormat: Text.PlainText
                      text: modelData.ampm
                      color: Qt.darker(root.fgColor, 1.35)
                      font.family: root.fontFam
                      font.pixelSize: Style.font.caption
                      font.bold: true
                    }
                  }

                  // Row 3: Code + UTC offset (or Copied toast)
                  Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    text: root.copiedLabel === modelData.label
                      ? "✓ Copied to clipboard"
                      : (modelData.label + " · " + modelData.utcOffset)
                    color: root.copiedLabel === modelData.label
                      ? Color.accent
                      : Qt.darker(root.fgColor, 1.4)
                    font.family: root.fontFam
                    font.pixelSize: Style.font.caption
                  }

                  // Row 4: IANA Timezone
                  Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    text: modelData.tz
                    color: Qt.darker(root.fgColor, 1.65)
                    font.family: root.fontFam
                    font.pixelSize: Style.font.caption
                  }
                }
              }
            }
          }

          // ---- Hairline divider ----
          Rectangle {
            width: parent.width - root.padX * 2
            anchors.horizontalCenter: parent.horizontalCenter
            height: Style.spacing.hairline
            color: root.fgColor
            opacity: 0.12
          }

          // ---- Bottom Bar: Quick Time Scroller (Aligned to [padX .. width - padX]) ----
          Item {
            id: bottomBar
            width: parent.width - root.padX * 2
            anchors.horizontalCenter: parent.horizontalCenter
            height: Style.space(28)

            Row {
              visible: !root.editingOffset
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(6)

              Repeater {
                model: [
                  { label: "Live", expr: "" },
                  { label: "+1h", expr: "+1h" },
                  { label: "+3h", expr: "+3h" },
                  { label: "+5h", expr: "+5h" },
                  { label: "Tomorrow 9am", expr: "tomorrow 9am" }
                ]

                Rectangle {
                  required property var modelData
                  readonly property bool activeChip: root.offsetExpr === modelData.expr
                  width: chipText.implicitWidth + Style.space(14)
                  height: Style.space(24)
                  radius: Style.cornerRadius
                  color: activeChip
                    ? Style.hoverFillFor(root.fgColor, Color.accent)
                    : (chipMouse.containsMouse ? Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.08) : "transparent")
                  border.width: 1
                  border.color: activeChip
                    ? Color.accent
                    : Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.16)

                  Text {
                    id: chipText
                    anchors.centerIn: parent
                    textFormat: Text.PlainText
                    text: modelData.label
                    color: parent.activeChip ? Color.accent : Qt.darker(root.fgColor, 1.3)
                    font.family: root.fontFam
                    font.pixelSize: Style.font.caption
                    font.bold: parent.activeChip
                  }

                  MouseArea {
                    id: chipMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.applyOffset(modelData.expr)
                  }
                }
              }
            }

            // Right-aligned Custom Offset Pill Button matching preset chip height
            Rectangle {
              visible: !root.editingOffset
              height: Style.space(24)
              width: customOffRow.implicitWidth + Style.space(14)
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              radius: Style.cornerRadius
              color: customOffMouse.containsMouse
                ? Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.08)
                : "transparent"
              border.width: 1
              border.color: Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.16)

              Row {
                id: customOffRow
                anchors.centerIn: parent
                spacing: Style.space(6)

                Text {
                  text: "󰥔"
                  color: Qt.darker(root.fgColor, 1.35)
                  font.family: root.fontFam
                  font.pixelSize: Style.font.caption
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  textFormat: Text.PlainText
                  text: "Custom (+5h, 15:00…)"
                  color: Qt.darker(root.fgColor, 1.3)
                  font.family: root.fontFam
                  font.pixelSize: Style.font.caption
                  anchors.verticalCenter: parent.verticalCenter
                }
              }

              MouseArea {
                id: customOffMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.startEditingOffset()
              }
            }

            // Custom offset input field when active
            Item {
              visible: root.editingOffset
              anchors.fill: parent

              TextField {
                id: offsetField
                anchors.left: parent.left
                anchors.right: cancelOffBtn.left
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: "+5h, -90m, 15:00, tomorrow 9am (empty for Live)"
                foreground: root.fgColor
                font.family: root.fontFam

                Keys.onPressed: function(event) {
                  if (event.key === Qt.Key_Escape) {
                    root.cancelEditingOffset()
                    event.accepted = true
                  } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.applyOffset(offsetField.text)
                    event.accepted = true
                  }
                }
              }

              Rectangle {
                id: cancelOffBtn
                width: Style.space(26)
                height: Style.space(26)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                radius: Style.cornerRadius
                color: cancelOffMouse.containsMouse ? Style.hoverFillFor(root.fgColor, Color.accent) : "transparent"
                border.width: 1
                border.color: Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.15)

                Text {
                  anchors.centerIn: parent
                  text: "✕"
                  color: Qt.darker(root.fgColor, 1.35)
                  font.family: root.fontFam
                  font.pixelSize: Style.font.caption
                }

                MouseArea {
                  id: cancelOffMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.cancelEditingOffset()
                }
              }
            }
          }
        }
      }
    }
  }
}
