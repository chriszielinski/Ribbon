Ribbon 🎀
========

<p align="center">
    <img alt="Supported Platforms" src ="https://img.shields.io/badge/platform-iOS%20%7C%20macOS-informational"/>
    <a href="https://github.com/Carthage/Carthage" style="text-decoration:none" target="_blank">
        <img alt="Carthage compatible" src ="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/>
    </a>
    <a href="https://cocoapods.org/pods/Ribbon" style="text-decoration:none" target="_blank">
        <img alt="Pod Version" src ="https://img.shields.io/cocoapods/v/Ribbon.svg?style=flat"/>
    </a>
    <a href="https://travis-ci.org/chriszielinski/Ribbon" style="text-decoration:none" target="_blank">
		<img src="https://travis-ci.org/chriszielinski/Ribbon.svg?branch=master">
	</a>
	<a href="https://sonarcloud.io/dashboard?id=chriszielinski_Ribbon" style="text-decoration:none" target="_blank">
		<img src="https://sonarcloud.io/api/project_badges/measure?project=chriszielinski_Ribbon&metric=alert_status">
	</a>
	<a href="https://sonarcloud.io/component_measures?id=chriszielinski_Ribbon&metric=Coverage" style="text-decoration:none" target="_blank">
	  <img src="https://sonarcloud.io/api/project_badges/measure?project=chriszielinski_Ribbon&metric=coverage">
	</a>
	<a href="https://codebeat.co/projects/github-com-chriszielinski-ribbon-master" style="text-decoration:none" target="_blank">
	   <img alt="codebeat badge" src="https://codebeat.co/badges/8fa0b6cf-73e1-425a-a196-8b62197cfa40"/>
   </a>
	<a href="https://developer.apple.com/swift" style="text-decoration:none" target="_blank">
		<img alt="Swift Version" src ="https://img.shields.io/badge/language-Swift%205-blue.svg"/>
	</a>
	<a href="https://github.com/chriszielinski/Ribbon/blob/master/LICENSE" style="text-decoration:none" target="_blank">
		<img alt="GitHub license" src ="https://img.shields.io/badge/license-MIT-blue.svg"/>
	</a>
    <img alt="PRs Welcome" src="https://img.shields.io/badge/PRs-welcome-blue.svg" />
    <br>
    <br>
    <img src="https://raw.githubusercontent.com/chriszielinski/Ribbon/master/.readme-assets/header.jpg" alt="Header">
    <br>
    <br>
    <b>A simple cross-platform toolbar/custom input accessory view library for iOS & macOS.
    <br>
    Written in Swift.</b>
    <br>
</p>

---

### Looking for...

- A type-safe, XPC-available [SourceKitten](https://github.com/jpsim/SourceKitten) (SourceKit) interface with some sugar? Check out [Sylvester](https://github.com/chriszielinski/Sylvester) 😼.
- A Floating Action Button for macOS? Check out [Fab.](https://github.com/chriszielinski/Fab) 🛍️.
- An Expanding Bubble Text Field for macOS? Check out [BubbleTextField](https://github.com/chriszielinski/BubbleTextField) 💬.
- An integrated spotlight-based onboarding and help library for macOS? Check out [Enlighten](https://github.com/chriszielinski/Enlighten) 💡.

---

Features
========

> 🎡 **Try:** Includes an iOS & macOS demo.

- Provide items either programmatically or from a JSON configuration file.
- Dark mode.
- \+ more!

#### iOS

- Supports push buttons—a segmented item's subitems become push buttons. 
- iOS 13: [action] items use the new [context menu interaction](https://developer.apple.com/design/human-interface-guidelines/ios/controls/context-menus/):

   > **Note:** Due to an internal assertion, the keyboard can no longer remain visible during the interaction.

   <img src="https://raw.githubusercontent.com/chriszielinski/Ribbon/master/.readme-assets/ios13.gif" height="450" alt="iOS 13 Context Menu Interaction">

#### macOS

- Supports push, [action], & segmented control toolbar items.
- Provides `NSMenuItem`s for each item.


[action]:
   https://developer.apple.com/design/human-interface-guidelines/macos/buttons/pull-down-buttons#action-buttons


Requirements
============

- iOS 10.0+ (12.0+ for dark mode)
- macOS 10.12+ (10.13+ for full functionality)


Installation
============
`Ribbon` is available for installation using Carthage or CocoaPods.

[Carthage](https://github.com/Carthage/Carthage)
------------------------------------------------

```ruby
github "chriszielinski/Ribbon"
```

[CocoaPods](http://cocoapods.org/)
----------------------------------

```ruby
pod "Ribbon"
```


Usage
=====

There are two ways of integrating `Ribbon` into your project:


Configuration File
------------------

> 🔥 The recommended approach.

The configuration file makes for a quick & easy integration. The default configuration filename is `ribbon-configuration.json` and should be copied into the target's bundle resources (in the _Copy Bundle Resources_ build phase).

The JSON below defines a single action item and toolbar configuration—which is only relevant for the macOS platform.

> 🧐 **See:** [_Demos/Shared/ribbon-configuration.json_](https://github.com/chriszielinski/Ribbon/blob/master/Demos/Shared/ribbon-configuration.json) for a more comprehensive example.

```json
{
    "items": [
        {
            "action": "actionItemHandler",
            "controlKind": "action",
            "identifier": "action-item-identifier",
            "imageName": "NSActionTemplate",
            "keyEquivalent": "a",
            "keyEquivalentModifier": ["command", "shift"],
            "title": "Action Item",
            "toolTip": "The action button's tool-tip.",
            "subitems": [
                {
                    "action": "firstActionSubitemHandler",
                    "identifier": "first-action-subitem",
                    "imageName": "hand.thumbsup",
                    "keyEquivalent": "1",
                    "keyEquivalentModifier": ["command"],
                    "title": "First Action Subitem",
                    "toolTip": "The first action's tool-tip."
                },
                {
                    "action": "secondActionSubitemHandler",
                    "identifier": "second-action-subitem",
                    "imageName": "hand.thumbsdown",
                    "keyEquivalent": "2",
                    "keyEquivalentModifier": ["command"],
                    "title": "Second Action Subitem",
                    "toolTip": "The second action's tool-tip."
                }
            ]
        }
    ],
    "toolbar": {
        "displayMode": "iconOnly",
        "sizeMode": "regular",
        "identifier": "toolbar-identifier",
        "defaultItems" : ["NSToolbarFlexibleSpaceItem", "action-item-identifier"]
    }
}
```

Integration into your view controller is as simple as:

> 📌 **Note:** The code below is an abstraction and **will not** compile.

```swift
import Ribbon

class YourViewController ... {

    ...
    
    var ribbon: Ribbon!

    override func viewDidLoad() {
        ribbon = try! Ribbon.loadFromMainBundle(target: self)

        #if canImport(UIKit)
        textView.inputAccessoryView = ribbon
        #endif
    }
    
    #if canImport(AppKit)
    override func viewWillAppear() {
        view.window?.toolbar = ribbon.toolbar

        super.viewWillAppear()
    }
    #endif
    
    @objc
    func actionItemHandler() { }

    @objc
    func firstActionSubitemHandler() { }

    @objc
    func secondActionSubitemHandler() { }

}
```


Programmatically
----------------

> 📌 **Note:** The code below is an abstraction and **will not** compile.

```swift
import Ribbon

class YourViewController ... {

    ...
    
    var ribbon: Ribbon!

    override func viewDidLoad() {
        let firstActionSubitem = RibbonItem(subItemTitle: "First Action Subitem")
        firstActionSubitem.action = #selector(firstActionSubitemHandler)
        let secondActionSubitem = RibbonItem(subItemTitle: "Second Action Subitem")
        secondActionSubitem.action = #selector(secondActionSubitemHandler)

        let actionItem = RibbonItem(controlKind: .action,
                                    title: "Action Item",
                                    subitems: [firstActionSubitem, secondActionSubitem])
        actionItem.action = #selector(actionItemHandler)
        ribbon = Ribbon(items: [actionItem], target: self)

        #if canImport(UIKit)
        textView.inputAccessoryView = ribbon
        #endif
    }
    
    #if canImport(AppKit)
    override func viewWillAppear() {
        view.window?.toolbar = ribbon.toolbar

        super.viewWillAppear()
    }
    #endif
    
    @objc
    func actionItemHandler() { }

    @objc
    func firstActionSubitemHandler() { }

    @objc
    func secondActionSubitemHandler() { }

}
```


// ToDo:
========

- [ ] Add documentation.
- [ ] Implement `UIKeyCommand`.


Community
=========

- Found a bug? Open an [issue](https://github.com/chriszielinski/ribbon/issues).
- Feature idea? ~~Open an [issue](https://github.com/chriszielinski/ribbon/issues).~~ Do it yourself & PR when done 😅 (or you can open an issue 🙄).
- Want to contribute? Submit a [pull request](https://github.com/chriszielinski/ribbon/pulls).


Acknowledgements
================

* Based on Rudd Fawcett's [`RFKeyboardToolbar`](https://github.com/ruddfawcett/RFKeyboardToolbar).


Contributors
============

- [Chris Zielinski](https://github.com/chriszielinski) — Original author.


Frameworks & Libraries
======================

`Ribbon` depends on the wonderful contributions of the Swift community, namely:

* **[realm/SwiftLint](https://github.com/realm/SwiftLint)** — A tool to enforce Swift style and conventions.


License
=======

`Ribbon` is available under the MIT license, see the [LICENSE](https://github.com/chriszielinski/ribbon/blob/master/LICENSE) file for more information.
