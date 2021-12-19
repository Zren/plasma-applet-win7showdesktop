## v12 - December 19 2021

* Support Plasma 5.21's margins by setting `plasmoid.constraintHints` = `PlasmaCore.Types.CanFillArea` to fill up to the edges of the panel.
* Retain stacking order when unminimizing all (Issue #18)
* Remove (Plasma 5.18) text from "Toggle Lock Widgets" in context menu.
* Generate a `metadata.json`

## v11 - April 14 2020

* Restore minimizeall on second click (Issue #15)
* Add config controls for peeking at desktop on hover (Issue #14)
* Add contextmenu item to lock widgets in Plasma 5.18
* Updated Spanish translations by @wuniversales (Issue #16)
* Updated Dutch translations by @Vistaus (Pull Request #17)

## v10 - February 14 2020

* Detect Plasma 5.18's edit mode in order to hide the move icon (Issue #13)
* Add brazilian portuguese translations by @kryptusql (Issue #12)

## v9 - November 4 2019

* Fix detecting edit mode in Latte-Dock v8 and v9. Kubuntu 18.04 uses Latte v7, so please use win7showdesktop v7 if you're using that distro.
* Add Dutch translations by @Vistaus (Pull Request #6)

## v8 - October 19 2019

* Only show a edge line on the left on a horizontal panel, or the top of the button on a vertical panel.
* Use the desktop theme textColor instead of the buttonBackgroundColor for the edge color.
* 3 colors are now configurable. The edge line color, the hovered color, and the pressed color.
* Enlargen the widget and show a move icon when widgets are unlocked so that it's easier to move or remove the widget.
* Add Spanish translations by @wuniversales (Issue #4)

## v7 - September 18 2017

* Configurable width/height
* Add command presets to trigger the various "Present Windows" Desktop Effects.

## v6 - December 15 2016

* Update the config so that the command text fields scale to the width of the window.
* Dragging something and hovering the show desktop button will activate show desktop.

## v5 - July 25 2016

* The click action is now configurable (show desktop / minimize all / run command).
* Add context menu options to show desktop and minimize all windows.

## v4 - July 7 2016

* KDE 5.6 and below are not supported in this version of win7showdesktop.
* Fix "Show Desktop" in KDE 5.7.
* Replaced the Volume with UI preset requiring xdotool with a qdbus command.
* Added a Switch desktop preset using qdbus.

## v2 - May 13 2016

* First release.
