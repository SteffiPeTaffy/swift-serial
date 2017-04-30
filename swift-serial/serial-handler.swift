//
//  serial-handler.swift
//  swift-serial
//
//  Created by Stefanie Grewenig on 30/04/2017.
//  Copyright © 2017 Stefanie Grewenig. All rights reserved.
//

import Foundation

class SerialHandler : NSObject, ORSSerialPortDelegate {
    var serialPort: ORSSerialPort?
    let standardInputFileHandle = FileHandle.standardInput
    
    
    func openSerialPort(path: String) {
        self.serialPort = ORSSerialPort(path: path)
        self.serialPort?.baudRate = 19200
        self.serialPort?.delegate = self
        self.serialPort?.numberOfStopBits = 1
        serialPort?.open()
    }
    
    
    func runProcessingInput(path: String) {
        setbuf(stdout, nil)
        
        let data = standardInputFileHandle.availableData;
        DispatchQueue.main.async(execute: { () -> Void in
            self.handleUserInput(dataFromUser: data as NSData)
        })
        
        openSerialPort(path: path)
        
        RunLoop.current.run() // loop
    }
    
    
    func handleUserInput(dataFromUser: NSData) {
        if let string = NSString(data: dataFromUser as Data, encoding: String.Encoding.utf8.rawValue) as String? {
            
            if string.lowercased().contains("exit") {
                print("Bye bye")
                exit(EXIT_SUCCESS)
            }
            
            let bytes : [UInt8] = [ 0x01, 0x00, 0x00, 0x01]
            let data = Data(bytes:bytes)
            
            self.serialPort?.send(data as Data)
        }
    }
    
    // ORSSerialPortDelegate
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if let string = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
            print("Serial port \(serialPort) received \(string)")
        }
    }
    
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        self.serialPort = nil
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port \(serialPort) encountered error: \(error)")
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("Serial port \(serialPort) was opened")
    }
    
}
