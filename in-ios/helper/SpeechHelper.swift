//
//  SpeechHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/23/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import AVFoundation

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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
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
            try audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
            try audioSession.setMode(AVAudioSessionModeSpokenAudio)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
}
