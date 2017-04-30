//
//  main.swift
//  swift-serial
//
//  Created by Stefanie Grewenig on 29/04/2017.
//  Copyright © 2017 Stefanie Grewenig. All rights reserved.
//

import Foundation

class SerialHandler : NSObject, ORSSerialPortDelegate {
    var serialPort: ORSSerialPort?
    let standardInputFileHandle = FileHandle.standardInput
    
    func runProcessingInput() {
        setbuf(stdout, nil)
        
        let data = standardInputFileHandle.availableData;
        DispatchQueue.main.async(execute: { () -> Void in
            self.handleUserInput(dataFromUser: data as NSData)
        })
        
        self.serialPort = ORSSerialPort(path: "/dev/cu.usbserial-A505B9PT") // please adjust to your handle
        self.serialPort?.baudRate = 19200
        self.serialPort?.delegate = self
        self.serialPort?.numberOfStopBits = 1
        serialPort?.open()
        
        RunLoop.current.run() // loop
    }
    
    
    func handleUserInput(dataFromUser: NSData) {
        if let string = NSString(data: dataFromUser as Data, encoding: String.Encoding.utf8.rawValue) as String? {
            
            if string.lowercased().hasPrefix("exit") {
                print("Quitting...")
                exit(EXIT_SUCCESS)
            }
            
            print("This data \(dataFromUser) wil be send.")
            self.serialPort?.send(dataFromUser as Data)
        }
    }
    
    // ORSSerialPortDelegate
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        print("Serial port did receive data.")
        if let string = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
            print("Serial port (\(serialPort)) received \(string)")
        }
    }
    
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        self.serialPort = nil
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port (\(serialPort)) encountered error: \(error)")
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("Serial port \(serialPort) was opened")
    }
}


print("Starting serial test program")
print("To exit type: 'exit'")
SerialHandler().runProcessingInput()
