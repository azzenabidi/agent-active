import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "azzen.agent-active"

  readonly property string omarchyPath: Quickshell.env("HOME") + "/.local/share/omarchy"
  readonly property string soundPath: "/usr/share/sounds/freedesktop/stereo/complete.oga"

  property bool agentActive: false
  property string activeAgents: ""

  function parseLine(line) {
    var s = String(line || "").trim()
    if (s.length === 0) return

    if (s.charAt(0) === "-") {
      var agent = s.substring(1)
      playSound()
      sendNotification(agent)
      return
    }

    var names = s.split(/\s+/).filter(Boolean)
    root.agentActive = names.length > 0
    root.activeAgents = names.join(", ")
  }

  function playSound() {
    Quickshell.execDetached(["paplay", root.soundPath])
  }

  function sendNotification(agent) {
    var cmd = "addr=$(hyprctl clients -j | jq -r '.[] | select(.class == \"org.omarchy.agent\") | .address' | head -1) && " +
      "hyprctl dispatch \"hl.dsp.focus({ window = \\\"address:$addr\\\" })\""
    Quickshell.execDetached([
      root.omarchyPath + "/bin/omarchy-notification-send",
      "-g", "\uf06a9",
      "-u", "low",
      "--exec", cmd,
      agent + " finished",
      "Click to focus " + agent + " window"
    ])
  }

  visible: agentActive
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: watchProc
    running: true
    command: ["bash", Quickshell.env("HOME") + "/.config/omarchy/plugins/azzen.agent-active/agent-watch.sh"]
    stdout: SplitParser {
      onRead: (data) => root.parseLine(data)
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf06a9"
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    tooltipText: root.agentActive
      ? "Agent active: " + root.activeAgents
      : "No agent running"
    onPressed: {}
  }
}
