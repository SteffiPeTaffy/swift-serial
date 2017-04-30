//
//  main.swift
//  swift-serial
//
//  Created by Stefanie Grewenig on 29/04/2017.
//  Copyright © 2017 Stefanie Grewenig. All rights reserved.
//

import Foundation

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
        
        self.serialPort = ORSSerialPort(path: "/dev/cu.Repleo-PL2303-00401414") // please adjust to your handle
        self.serialPort?.baudRate = 9600
        self.serialPort?.delegate = self
        serialPort?.open()
        
        RunLoop.current.run() // loop
    }
    
    
    func handleUserInput(dataFromUser: NSData) {
        if let string = NSString(data: dataFromUser as Data, encoding: String.Encoding.utf8.rawValue) as String? {
            
            if string.lowercased().hasPrefix("exit") {
                print("Quitting...")
                exit(EXIT_SUCCESS)
            }
            self.serialPort?.send(dataFromUser as Data)
        }
    }
    
    // ORSSerialPortDelegate
    
    func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
        if let string = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
            print("\(string)")
        }
    }
    
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        self.serialPort = nil
    }
    
    func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
        print("Serial port (\(serialPort)) encountered error: \(error)")
    }
    
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        print("Serial port \(serialPort) was opened")
    }
}


print("Starting serial test program")
print("To exit type: 'exit'")
SerialHandler().runProcessingInput()
