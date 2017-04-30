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
    var soundRecorder: AVAudioRecorder?
    
    
    func openSerialPort(path: String) {
        self.serialPort = ORSSerialPort(path: path)
        self.serialPort?.baudRate = 19200
        self.serialPort?.delegate = self
        self.serialPort?.numberOfStopBits = 1
        serialPort?.open()
    }
    
    func setupAndRecord(fileName: String) {
        let recordSettings = [ AVFormatIDKey : kAudioFormatAppleLossless,
                               AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                               AVEncoderBitRateKey: 320000,
                               AVNumberOfChannelsKey : 2,
                               AVSampleRateKey : 44100.0 ] as [String : Any]
        
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = docDirURL.appendingPathComponent(fileName)
        
        
        do {
            soundRecorder = try AVAudioRecorder.init(url: fileURL, settings: recordSettings)
            soundRecorder?.record(forDuration: 5)
        } catch {
            print("Recorder could not be initialized")
        }
    }
    
    func setRelays(command: UInt8, address: UInt8, input: UInt8) {
        let checksum: UInt8 = command ^ address ^ input
        let bytes : [UInt8] = [ command, address, input, checksum]
        let data = Data(bytes:bytes)
        self.serialPort?.send(data as Data)
    }
    
    func clearRelayState() {
        setRelays(command: 3, address: 0, input: 0)
    }
    
    func switchRelays(char: UInt8) {
        setRelays(command: 3, address: 0, input: char)
    }
    
    func handleUserInput(stringFromUser: String) {
        if stringFromUser.lowercased().hasPrefix("exit") {
            print("Bye bye")
            exit(EXIT_SUCCESS)
        }
        
        let asUInt8Array = stringFromUser.utf8.map{ UInt8($0) }
        
        var when = DispatchTime.now()
        for char in asUInt8Array {
            when = when + 0.2
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.clearRelayState()
            }
            when = when + 0.2
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.switchRelays(char: char)
            }
        }
    }
    
    func runProcessingInput(path: String) {
        setbuf(stdout, nil)
        
        self.openSerialPort(path: path)
        
        print("Enter the string you want to record or type 'exit' to exit the application.")
        let inputString = readLine()
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.setupAndRecord(fileName: "input-\(inputString!)-\(NSUUID().uuidString).m4a")
            self.handleUserInput(stringFromUser: inputString!)
        })
        
        RunLoop.current.run()
    }
    
    // ORSSerialPortDelegate
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        print("Serial port \(serialPort) received data \(data)")
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
