# Nightscouter

[![Available on the Apple App Store](https://devimages.apple.com.edgekey.net/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg)](https://itunes.apple.com/us/app/nightscouter/id1010503247?ls=1&mt=8)
[![Join the chat at https://gitter.im/someoneAnyone/Nightscouter2](https://badges.gitter.im/someoneAnyone/Nightscouter2.svg)](https://gitter.im/someoneAnyone/Nightscouter2?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) 

This repo is Version 2.0 of Nightscouter, rewritten from the ground up. Things will not work.

An Native iOS app used for displaying CGM data from a Nightscout website data. To build and run for your self, you'll need to have a valid Apple Developer account to generate the proper entitlements needed to share data between the Today Widget and the main App.

Don't want to build and install on your own? Nightscouter is now available on the [ AppStore] (https://itunes.apple.com/us/app/nightscouter/id1010503247?ls=1&mt=8).

## Requirements
- Xcode Version 7.3 with Swift 2.2
- iOS 9.2 or better
- watchOS 2.2 if you want to use  Watch
- iPhone 5, 5s, 6, 6 Plus (Will work on iPads but not specifically optimized for it yet)
- Nightscout Remote Monitor versions 0.7.0 & 0.8.0 (https://github.com/nightscout/cgm-remote-monitor)
- Dexcom CGM (other uploaders are supported but are not tested)

## Features
- Multiple Nightscout Remote Monitor web sites can be added and viewed within the App.
- Get at a glance information from the Notification Center using the Nightscouter Today Widget.
- Uses the settings and configurations for blood sugar thresholds from your remote monitor. No need to enter them in again.
- Force touch on the app icon for application shortcuts.
- Background for application updates. (updates when Apple wakes the app)
-  Watch App for quick acess to Nightscout data. This includes an App, Glance, and complications. You can pick which site to use for the complication and "at a glance" views on the watch by force touching the "bg compas" in the watch app. Please note that complications will only update hourly due to limitations from Apple.

## ToDo (currently in no order)
* [x] Research and create proof of concept for SocketIOClient for iOS
* [x] Adopt CocoaPods (SwiftyJSON, CryptoSwift)
* [ ] Retain 1.0 functionalty
* [ ] Get more developers to help, so I can focus on UI. ;-)
* [ ] Refactor out old code and rewrite using protocol composition where appropriate.
* [ ] Consolidate data storage to something other NSDefaults. CoreData and CloudKit are likely candidates.
* [ ] Unit test
* [ ] Integrate a native iOS chart that supports more than the current android one.
* [ ] Adopt NSOperations for better network handling and managment of intense operations (complication timeline).
* [ ] Create mechanisms for smarter updates (track deltas) and only retain one updating object in the model instead of per view controller.
* [ ] Unit tests! Did I say that twice?
* [ ] Push Notifications
* [ ] Better layouts for iPad
* [ ] Allow users to ovveride server settings like units, custom titles, and show hide features.
* [ ] tvOS support
* [ ] macOS notification center support.
* [ ] Alarming based on BG thresholds

##Questions?
Feel free to post an [issue].
[issue]: https://github.com/someoneAnyone/Nightscouter/issues

##License
Nightscouter is available under the MIT license. See the LICENSE file for more info.

##Contributing
We can always use a hand! For information on how you can contribute, please check out the [gitter room](https://gitter.im/someoneAnyone/Nightscouter2?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge).

##Contributors (Thank you!)
[@ericmarkmartin](https://github.com/ericmarkmartin)
