# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

def limited_pods
    pod 'Socket.IO-Client-Swift', '~> 4.1.6' # Or latest version
    pod 'DateTools'
end

def global_pods
    pod 'Alamofire'
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
    pod 'ReactiveCocoa', '4.0.4-alpha-4'
    pod 'CryptoSwift'
    pod 'KeychainAccess'
end

target 'Nightscouter' do
    
end

target 'Nightscouter Today' do
    
end

target 'NightscouterKit' do
    limited_pods
    global_pods
end

target 'Nightscouter Watch App' do
    
end

target 'Nightscouter Watch App Extension' do
    
end

target 'NightscouterWatchKit' do
    global_pods
end

