source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!


def limited_pods
    pod 'Socket.IO-Client-Swift', '~> 4.1.6' # Or latest version
    # ReactiveCocoa will not work on watchOS for some reason.
    pod 'ReactiveCocoa', '4.0.4-alpha-4'

    pod 'DateTools'
end

def global_pods
    pod 'Alamofire'
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
    pod 'CryptoSwift'
    pod 'KeychainAccess'
    # pod 'ReactiveCocoa', '4.0.4-alpha-4'
end


# iOS9 App with some UI.
target 'Nightscouter' do
    platform :ios, '9.0'
    limited_pods
    global_pods
end

# iOS9 Today Extension with some UI.
#target 'Nightscouter Today' do
#    platform :ios, '9.0'
#end

# iOS9 Based Cocoa Touch Framework used in 'Nightscouter' and 'Nightscouter Today'.
target 'NightscouterKit' do
    platform :ios, '9.0'

    limited_pods
    global_pods
end

# watchOS2 App
target 'Nightscouter Watch App' do
    platform :watchos, '2.0'
    global_pods
end

# watchOS2 App Extension
target 'Nightscouter Watch App Extension' do
    platform :watchos, '2.0'
    global_pods
end

# watchOS2 App Framework
target 'NightscouterWatchKit' do
    platform :watchos, '2.0'
    global_pods
end