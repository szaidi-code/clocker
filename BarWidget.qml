import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "szaidi.clocker"

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function refresh() {
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function togglePanel() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }

  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item && panelLoader.item.openFromHotkey) panelLoader.item.openFromHotkey()
  }

  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }

  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  visible: true
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: Style.bar.statusSlot
    active: root.opened
    tooltipText: ""

    // Vector globe icon drawn around the exact geometric center (width/2, height/2)
    // so it always aligns pixel-for-pixel with the bar's openPanelIndicator underline.
    iconComponent: Component {
      Item {
        Canvas {
          id: globeCanvas
          anchors.fill: parent
          property color strokeColor: button.active && button.useActiveColor ? button.activeColor : button.foreground
          onStrokeColorChanged: requestPaint()
          onWidthChanged: requestPaint()
          onHeightChanged: requestPaint()

          onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var cx = width / 2
            var cy = height / 2
            var r = Math.min(width, height) * 0.39
            var lw = Math.max(1.2, Math.min(width, height) * 0.085)

            ctx.strokeStyle = strokeColor.toString()
            ctx.lineWidth = lw
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            // Outer globe circle
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.stroke()

            // Equator line
            ctx.beginPath()
            ctx.moveTo(cx - r, cy)
            ctx.lineTo(cx + r, cy)
            ctx.stroke()

            // Vertical meridian ellipse
            var rx = r * 0.48
            ctx.beginPath()
            ctx.ellipse(cx - rx, cy - r, rx * 2, r * 2)
            ctx.stroke()
          }
        }
      }
    }

    onPressed: function(b) {
      if (b === Qt.RightButton) {
        if (panelLoader.item && panelLoader.item.openAndEdit) {
          panelLoader.item.openAndEdit(0)
        }
      } else if (b === Qt.MiddleButton) {
        root.refresh()
      } else {
        root.togglePanel()
      }
    }
  }
}
