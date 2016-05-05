source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!


def limited_pods
inhibit_all_warnings!
    pod 'Socket.IO-Client-Swift'
    pod 'Charts', '~> 2.2'

    #pod 'DateTools'
end

def global_pods
inhibit_all_warnings!
    pod 'Alamofire'
    pod 'SwiftyJSON', '~> 2.3'
    pod 'CryptoSwift'
    pod 'KeychainAccess'
    pod 'ReactiveCocoa', '~> 4.1'
end


# iOS9 App with some UI.
target 'Nightscouter' do
    platform :ios, '9.0'
    limited_pods
    global_pods
    pod 'Operations', '~> 2.10'

end

# iOS9 Today Extension with some UI.
target 'Nightscouter Today' do
    platform :ios, '9.0'
    limited_pods
    global_pods

end

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
target 'NightscouterKit (watchOS)' do
    platform :watchos, '2.0'
    global_pods
end