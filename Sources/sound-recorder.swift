//
//  sound-recorder.swift
//  swift-serial
//
//  Created by Stefanie Grewenig on 01/05/2017.
//  Copyright © 2017 Stefanie Grewenig. All rights reserved.
//

import Foundation
import AVFoundation

class SoundRecorder {
    var soundRecorder: AVAudioRecorder?

    func setupAndRecord(fileName: String, seconds: Double) {
        let recordSettings = [ AVFormatIDKey : kAudioFormatAppleLossless,
                               AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                               AVEncoderBitRateKey: 320000,
                               AVNumberOfChannelsKey : 2,
                               AVSampleRateKey : 44100.0 ] as [String : Any]
        
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = docDirURL.appendingPathComponent(fileName)
        
        
        do {
            soundRecorder = try AVAudioRecorder.init(url: fileURL, settings: recordSettings)
            soundRecorder?.record(forDuration: seconds)
        } catch {
            print("Recorder could not be initialized")
            exit(EXIT_FAILURE)
        }
    }
}
