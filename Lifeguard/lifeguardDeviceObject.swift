//
//  lifeguardDeviceObject.swift
//  bonjourtest
//
//  Created by Aaron Sinclair on 3/05/18.
//  Copyright © 2018 Aaron Sinclair. All rights reserved.
//

import UIKit

class lifeguardDeviceObject: NSObject {
    
    static var deviceArray:Array<String> = []
    static var deviceSelected = 0
    
    class func addDevice(newDevice:String) {
        if (!lifeguardDeviceObject.deviceArray.contains(newDevice)) {
            lifeguardDeviceObject.deviceArray.append(newDevice)
            print("adding \(newDevice)")
        }
    }
    
    class func removeDevice( deviceName:String) {
        //lifeguardDeviceObject.deviceArray.remove(at: atIndex)
        lifeguardDeviceObject.deviceArray = lifeguardDeviceObject.deviceArray.filter { $0 != deviceName}
        
    }
    
    class func removeAll() {
        lifeguardDeviceObject.deviceArray.removeAll()
        
    }
    
}
