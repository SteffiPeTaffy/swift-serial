//
//  main.swift
//  swift-serial
//
//  Created by Stefanie Grewenig on 29/04/2017.
//  Copyright © 2017 Stefanie Grewenig. All rights reserved.
//

import Foundation
import AVFoundation

print("Code2Relay")
print("==========")

let path = SerialDetector().findUsbSerialDevicePath()
if path.isEmpty {
    print("Could not find a connected serial device. Are you sure your device is plugged in?")
    exit(EXIT_FAILURE)
}

let audioFilePath = "input-ab-8275D635-7AD3-4CC6-9700-3D4833B6AF8A.raw"
WavReader().makeVector(fileName: audioFilePath)


//print("Detected usb serial device \(path)")
//SerialHandler().runProcessingInput(path: path)

