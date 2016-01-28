//
//  SocketSignal.swift
//  NightscouterSocketTest
//
//  Created by Eric Martin on 1/5/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import ReactiveCocoa

private var signal : Signal<[AnyObject], NSError>? = nil

public extension SocketIOClient {
    
    public func rac_socketSignal() -> Signal<[AnyObject], NSError> {
        // if let signal = signal {
           // return signal
        // } else {
            let (tmpSignal, observer) = Signal<[AnyObject], NSError>.pipe()
            
            self.on(WebEvents.disconnect.rawValue) { data, ack in
                print("socketSignal complete")
                observer.sendCompleted()
            }
            
            self.on(WebEvents.dataUpdate.rawValue) { data, ack in
                print("socketSignal dataUpdate for \(self.socketURL)")
                observer.sendNext(data)
            }
            
            signal = tmpSignal
            
            return tmpSignal
            
        }
    //}
}