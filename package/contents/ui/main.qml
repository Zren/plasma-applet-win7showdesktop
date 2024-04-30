/*
	SPDX-FileCopyrightText: 2014 Ashish Madeti <ashishmadeti@gmail.com>
	SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
	SPDX-FileCopyrightText: 2019 Chris Holland <zrenfire@gmail.com>
	SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>

	SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.3

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

import org.kde.plasma.plasmoid

PlasmoidItem {
	id: root

	preferredRepresentation: fullRepresentation
	toolTipSubText: activeController.description

	Plasmoid.icon: "transform-move"
	Plasmoid.title: activeController.title
	Plasmoid.onActivated: {
		if (isPeeking) {
			isPeeking = false;
			peekController.toggle();
		}
		activeController.toggle();
	}

	Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

	Layout.minimumWidth: Kirigami.Units.iconSizes.medium
	Layout.minimumHeight: Kirigami.Units.iconSizes.medium

	Layout.maximumWidth: vertical ? Layout.minimumWidth : Math.max(1, Plasmoid.configuration.size)
	Layout.maximumHeight: vertical ? Math.max(1, Plasmoid.configuration.size) : Layout.minimumHeight

	Layout.preferredWidth: Layout.maximumWidth
	Layout.preferredHeight: Layout.maximumHeight

	Plasmoid.constraintHints: Plasmoid.CanFillArea

	readonly property bool inPanel: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.RightEdge, PlasmaCore.Types.BottomEdge, PlasmaCore.Types.LeftEdge]
			.includes(Plasmoid.location)

	readonly property bool vertical: Plasmoid.location === PlasmaCore.Types.RightEdge || Plasmoid.location === PlasmaCore.Types.LeftEdge

	readonly property Controller primaryController: {
		if (Plasmoid.configuration.click_action == "minimizeall") {
			return minimizeAllController;
		} else if (Plasmoid.configuration.click_action == "showdesktop") {
			return peekController;
		} else {
			return commandController;
		}
	}

	readonly property Controller activeController: {
		if (minimizeAllController.active) {
			return minimizeAllController;
		} else {
			return primaryController;
		}
	}

	property bool isPeeking: false

	MouseArea {
		id: mouseArea
		anchors.fill: parent

		activeFocusOnTab: true
		hoverEnabled: true

		onClicked: Plasmoid.activated();

		onEntered: {
			if (Plasmoid.configuration.peekingEnabled)
				peekTimer.start();
		}
		onExited: {
			peekTimer.stop();
			if (isPeeking) {
				isPeeking = false;
				peekController.toggle();
			}
		}

		// org.kde.plasma.volume
		property int wheelDelta: 0
		onWheel: wheel => {
			const delta = (wheel.inverted ? -1 : 1) * (wheel.angleDelta.y ? wheel.angleDelta.y : -wheel.angleDelta.x);
			wheelDelta += delta;
			// Magic number 120 for common "one click"
			// See: https://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
			while (wheelDelta >= 120) {
				wheelDelta -= 120;
				performMouseWheelUp();
			}
			while (wheelDelta <= -120) {
				wheelDelta += 120;
				performMouseWheelDown();
			}
		}

		Keys.onPressed: {
			switch (event.key) {
			case Qt.Key_Space:
			case Qt.Key_Enter:
			case Qt.Key_Return:
			case Qt.Key_Select:
				Plasmoid.activated();
				break;
			}
		}

		Accessible.name: Plasmoid.title
		Accessible.description: toolTipSubText
		Accessible.role: Accessible.Button

		PeekController {
			id: peekController
		}

		MinimizeAllController {
			id: minimizeAllController
		}

		CommandController {
			id: commandController
		}

		Kirigami.Icon {
			anchors.fill: parent
			active: mouseArea.containsMouse || activeController.active
			visible: Plasmoid.containment.corona.editMode
			source: Plasmoid.icon
		}

		// also activate when dragging an item over the plasmoid so a user can easily drag data to the desktop
		DropArea {
			anchors.fill: parent
			onEntered: activateTimer.start()
			onExited: activateTimer.stop()
		}

		Timer {
			id: activateTimer
			interval: 250 // to match TaskManager
			onTriggered: Plasmoid.activated()
		}

		Timer {
			id: peekTimer
			interval: Plasmoid.configuration.peekingThreshold
			onTriggered: {
				if (!minimizeAllController.active && !peekController.active) {
					isPeeking = true;
					peekController.toggle();
				}
			}
		}

		state: {
			if (mouseArea.containsPress) {
				return "pressed";
			} else if (mouseArea.containsMouse || mouseArea.activeFocus) {
				return "hover";
			} else {
				return "normal";
			}
		}

		component ButtonSurface : Rectangle {
			property var containerMargins: {
				let item = this;
				while (item.parent) {
					item = item.parent;
					if (item.isAppletContainer) {
						return item.getMargins;
					}
				}
				return undefined;
			}

			anchors {
				fill: parent
				property bool returnAllMargins: true
				// The above makes sure margin is returned even for side margins
				// that would be otherwise turned off.
				topMargin: !vertical && containerMargins ? -containerMargins('top', returnAllMargins) : 0
				leftMargin: vertical && containerMargins ? -containerMargins('left', returnAllMargins) : 0
				rightMargin: vertical && containerMargins ? -containerMargins('right', returnAllMargins) : 0
				bottomMargin: !vertical && containerMargins ? -containerMargins('bottom', returnAllMargins) : 0
			}
			Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }
		}

		ButtonSurface {
			id: hoverSurface
			color: Plasmoid.configuration.hoveredColor
			opacity: mouseArea.state === "hover" ? 1 : 0
		}

		ButtonSurface {
			id: pressedSurface
			color: Plasmoid.configuration.pressedColor
			opacity: mouseArea.state === "pressed" ? 1 : 0
		}

		ButtonSurface {
			id: edgeLine
			color: "transparent"
			border.color: Plasmoid.configuration.edgeColor
			border.width: 1
		}

		// Active/not active indicator
		KSvg.FrameSvgItem {
			property var containerMargins: {
				let item = this;
				while (item.parent) {
					item = item.parent;
					if (item.isAppletContainer) {
						return item.getMargins;
					}
				}
				return undefined;
			}

			anchors {
				fill: parent
				property bool returnAllMargins: true
				// The above makes sure margin is returned even for side margins
				// that would be otherwise turned off.
				topMargin: !vertical && containerMargins ? -containerMargins('top', returnAllMargins) : 0
				leftMargin: vertical && containerMargins ? -containerMargins('left', returnAllMargins) : 0
				rightMargin: vertical && containerMargins ? -containerMargins('right', returnAllMargins) : 0
				bottomMargin: !vertical && containerMargins ? -containerMargins('bottom', returnAllMargins) : 0
			}
			imagePath: "widgets/tabbar"
			visible: opacity > 0
			prefix: {
				let prefix;
				switch (Plasmoid.location) {
				case PlasmaCore.Types.LeftEdge:
					prefix = "west-active-tab";
					break;
				case PlasmaCore.Types.TopEdge:
					prefix = "north-active-tab";
					break;
				case PlasmaCore.Types.RightEdge:
					prefix = "east-active-tab";
					break;
				default:
					prefix = "south-active-tab";
				}
				if (!hasElementPrefix(prefix)) {
					prefix = "active-tab";
				}
				return prefix;
			}
			opacity: activeController.active ? 1 : 0

			Behavior on opacity {
				NumberAnimation {
					duration: Kirigami.Units.shortDuration
					easing.type: Easing.InOutQuad
				}
			}
		}

		PlasmaCore.ToolTipArea {
			id: toolTip
			anchors.fill: parent
			mainText: Plasmoid.title
			subText: toolTipSubText
			textFormat: Text.PlainText
		}
	}

	// org.kde.plasma.mediacontrollercompact
	Plasma5Support.DataSource {
		id: executeSource
		engine: "executable"
		connectedSources: []
		onNewData: disconnectSource(sourceName) // cmd finished
		function getUniqueId(cmd) {
			// Note: we assume that 'cmd' is executed quickly so that a previous call
			// with the same 'cmd' has already finished (otherwise no new cmd will be
			// added because it is already in the list)
			// Workaround: We append spaces onto the user's command to workaround this.
			var cmd2 = cmd
			for (var i = 0; i < 10; i++) {
				if (executeSource.connectedSources.includes(cmd2)) {
					cmd2 += ' '
				}
			}
			return cmd2
		}
	}

	function exec(cmd) {
		executeSource.connectSource(executeSource.getUniqueId(cmd))
	}

	function performMouseWheelUp() {
		root.exec(Plasmoid.configuration.mousewheel_up)
	}

	function performMouseWheelDown() {
		root.exec(Plasmoid.configuration.mousewheel_down)
	}

	Plasmoid.contextualActions: [
		PlasmaCore.Action {
			text: i18n("Toggle Lock Widgets")
			icon.name: "object-locked"
			onTriggered: {
				var cmd = 'qdbus org.kde.plasmashell /PlasmaShell evaluateScript "lockCorona(!locked)"'
				root.exec(cmd)
			}
		},
		PlasmaCore.Action {
			text: minimizeAllController.titleInactive
			checkable: true
			checked: minimizeAllController.active
			toolTip: minimizeAllController.description
			enabled: !peekController.active
			onTriggered: minimizeAllController.toggle()
		},
		PlasmaCore.Action {
			text: peekController.titleInactive
			checkable: true
			checked: peekController.active
			toolTip: peekController.description
			enabled: !minimizeAllController.active
			onTriggered: peekController.toggle()
		}
	]
}
