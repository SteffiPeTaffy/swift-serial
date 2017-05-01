//
//  main.swift
//  swift-serial
//
//  Created by Stefanie Grewenig on 29/04/2017.
//  Copyright © 2017 Stefanie Grewenig. All rights reserved.
//

import Foundation


print("Code2Relay")
print("==========")

let path = SerialDetector().findUsbSerialDevicePath()
if path.isEmpty {
    print("Could not find a connected serial device. Are you sure your device is plugged in?")
    exit(EXIT_FAILURE)
}

print("Detected usb serial device \(path)")

SerialHandler().runProcessingInput(path: path)

