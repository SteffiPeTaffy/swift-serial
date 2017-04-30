//
//  serial-detector.swift
//  swift-serial
//
//  Created by Stefanie Grewenig on 30/04/2017.
//  Copyright © 2017 Stefanie Grewenig. All rights reserved.
//

import Foundation
import IOKit
import IOKit.serial

class SerialDetector  {
    func findSerialDevices(deviceType: String, serialPortIterator: inout io_iterator_t ) -> kern_return_t {
        var result: kern_return_t = KERN_FAILURE
        let classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue)
        var classesToMatchDict = (classesToMatch!)
            as! Dictionary<String, AnyObject>
        classesToMatchDict[kIOSerialBSDTypeKey] = deviceType as AnyObject
        let classesToMatchCFDictRef = (classesToMatchDict as NSDictionary) as CFDictionary
        result = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatchCFDictRef, &serialPortIterator);
        return result
    }
    
    func isUsbSerialDevice(path:String) -> Bool {
        return path.contains("usbserial") ? true : false
    }
    
    func getUSBSerialDevicePath(portIterator: io_iterator_t) -> String {
        var result = ""
        var serialService: io_object_t
        repeat {
            serialService = IOIteratorNext(portIterator)
            if (serialService != 0) {
                let key: CFString! = "IOCalloutDevice" as CFString
                let bsdPathAsCFtring: AnyObject? =
                    IORegistryEntryCreateCFProperty(serialService, key, kCFAllocatorDefault, 0).takeUnretainedValue()
                let bsdPath = bsdPathAsCFtring as! String?
                if let path = bsdPath {
                    if(isUsbSerialDevice(path: path)) {
                        result = path
                    }
                }
            }
        } while serialService != 0;
        return result
    }
    
    func findUsbSerialDevicePath() -> String {
        var result = "NO_RESULT";
        var portIterator: io_iterator_t = 0
        
        let kernResult = findSerialDevices(deviceType: kIOSerialBSDAllTypes, serialPortIterator: &portIterator)
        
        if kernResult == KERN_SUCCESS {
            result = getUSBSerialDevicePath(portIterator: portIterator)
        }
        
        return result;
    }
}
