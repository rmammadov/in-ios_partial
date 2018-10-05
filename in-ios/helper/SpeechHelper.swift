//
//  SpeechHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/23/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import AVFoundation
import MediaPlayer


class SpeechHelper {
    
    static let synthesizer = AVSpeechSynthesizer()
    
    static func play(text: String, language: String) {
        self.setAudioSession()
        self.handleSilentMode()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.4
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        self.synthesizer.speak(utterance)
    }
    
    static func stop() {
        self.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    static func handleSilentMode() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .default)
        }
        catch let error as NSError {
            print("Error: Could not set audio category: \(error), \(error.userInfo)")
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print("Error: Could not setActive to true: \(error), \(error.userInfo)")
        }
    }
    
    static func setAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.soloAmbient)), mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.spokenAudio)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    static func volumeUp() {
        let newValue = AVAudioSession.sharedInstance().outputVolume + 0.0625
        let volume = newValue > 1 ? 1 : newValue
        let mpVolumeView = MPVolumeView(frame: .init(origin: .zero, size: CGSize(width: 100, height: 100)))
        if let slider = mpVolumeView.subviews.first as? UISlider {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                slider.value = volume
            }
        }
    }
    
    static func volumeDown() {
        let newValue = AVAudioSession.sharedInstance().outputVolume - 0.0625
        let volume = newValue < 0 ? 0 : newValue
        let mpVolumeView = MPVolumeView(frame: .init(origin: .zero, size: CGSize(width: 100, height: 100)))
        if let slider = mpVolumeView.subviews.first as? UISlider {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                slider.value = volume
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
