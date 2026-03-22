import QtQuick

QtObject {
    readonly property string fontFamily: "Fira Sans Semibold"
	<* for name, value in colors *>
		readonly property color {{name}}: "{{value.default.hex}}"
	<* endfor *>

    // Keep Quickshell panels aligned with the Waybar glass theme.
    readonly property color waybarBackground: surface
    readonly property color waybarBackgroundAlt: surface_dim
    readonly property color waybarBorder: primary
    readonly property color waybarBorderMuted: on_primary
    readonly property color waybarForeground: on_surface
    readonly property real waybarBorderWidth: 1
    readonly property real waybarRadius: 12
    readonly property real waybarOpacity: 0.8
    readonly property real quickshellPanelOpacity: 0.94
}
