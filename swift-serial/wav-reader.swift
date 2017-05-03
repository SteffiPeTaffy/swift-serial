//
//  wav-reader.swift
//  swift-serial
//
//  Created by Stefanie Grewenig on 03/05/2017.
//  Copyright © 2017 Stefanie Grewenig. All rights reserved.
//

import Foundation

import AVFoundation

class WavReader {    
    func makeVector(fileName: String) {
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = docDirURL.appendingPathComponent(fileName)
        
        let file = try! AVAudioFile(forReading: fileURL)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: 1, interleaved: false)
        
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 102400)
        try! file.read(into: buf)
        
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        
       // print("floatArray \(floatArray)\n")
        print("length \(floatArray.count)")
        
        
        
        
        
        let firstCharacter = floatArray[2*9000...3*9000];
        
        
        let secondCharacter = floatArray[4*9000...5*9000];

        print(firstCharacter.count, "\n")
        print("--------------------------------------\n")
        print(secondCharacter.count, "\n")
        
        let sum = floatArray.reduce(0) { (result, value) -> Float in
            
             if value > 0 {
                return result + value
            } else {
                return result
            }
        }
        let avg = Float (sum)/Float(floatArray.count)
        print(avg , "\n")

        floatArray.forEach { (value) in
            if value > avg {
                print(value)
            } else {
                print("*", terminator:"")
            }
        }

    }
}
