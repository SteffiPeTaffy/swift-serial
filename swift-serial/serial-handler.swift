//
//  serial-handler.swift
//  swift-serial
//
//  Created by Stefanie Grewenig on 30/04/2017.
//  Copyright © 2017 Stefanie Grewenig. All rights reserved.
//

import Foundation
import AVFoundation

class SerialHandler : NSObject, ORSSerialPortDelegate {
    var serialPort: ORSSerialPort?
    let standardInputFileHandle = FileHandle.standardInput
    var soundRecorder: AVAudioRecorder?
    
    
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
            self.setupAndRecord(fileName: "my-first-sound")
            self.handleUserInput(dataFromUser: data as NSData)
        })
        
        openSerialPort(path: path)
        
        RunLoop.current.run() // loop
    }
    
    
    func handleUserInput(dataFromUser: NSData) {
        print(dataFromUser)
        if let string = NSString(data: dataFromUser as Data, encoding: String.Encoding.utf8.rawValue) as String? {
            
            if string.lowercased().contains("exit") {
                print("Bye bye")
                exit(EXIT_SUCCESS)
            }
           
            let when = DispatchTime.now()
            DispatchQueue.main.asyncAfter(deadline: when+0.5) {
                self.switchAllOff()
            }
            
            DispatchQueue.main.asyncAfter(deadline: when+1) {
                self.switchAllOn()
            }
        }
    }
    
    func switchAllOff() {
        let bytes : [UInt8] = [ 0x03, 0x00, 0x00, 0x03]
        let data = Data(bytes:bytes)
        self.serialPort?.send(data as Data)
    }
    
    func switchAllOn() {
        let bytes : [UInt8] = [ 0x06, 0x00, 0xff, 0xf9]
        let data = Data(bytes:bytes)
        self.serialPort?.send(data as Data)
    }
    
    func setupAndRecord(fileName: String) {
        let recordSettings = [ AVFormatIDKey : kAudioFormatAppleLossless,
                               AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                               AVEncoderBitRateKey: 320000,
                               AVNumberOfChannelsKey : 2,
                               AVSampleRateKey : 44100.0 ] as [String : Any]
        
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let uuid = NSUUID().uuidString
        let fileURL = docDirURL.appendingPathComponent("\(fileName)-\(uuid).m4a")
        
        
        do {
            soundRecorder = try AVAudioRecorder.init(url: fileURL, settings: recordSettings)
            soundRecorder?.record(forDuration: 3)
        } catch {
            print("Recorder could not be initialized")
        }
    }
    
    // ORSSerialPortDelegate
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        print("Serial port \(serialPort) received data")

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
