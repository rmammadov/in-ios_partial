//
//  SpeechHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/23/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import AVFoundation
import MediaPlayer


class SpeechHelper: NSObject {
    
    static let shared = SpeechHelper()
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        setAudioSession()
        handleSilentMode()
    }
    
    let synthesizer = AVSpeechSynthesizer()
    
    func play(text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        synthesizer.delegate = self
        synthesizer.speak(utterance)
    }
    
    func play(translation: Translation?) {
        guard let translation = translation else { return }
        play(text: translation.labelTextToSpeech, language: translation.locale)
    }
    
    func stop() {
        self.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    func handleSilentMode() {
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
    
    func setAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.soloAmbient)), mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.spokenAudio)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    func volumeUp() {
        let newValue = AVAudioSession.sharedInstance().outputVolume + 0.0625
        let volume = newValue > 1 ? 1 : newValue
        let mpVolumeView = MPVolumeView(frame: .init(origin: .zero, size: CGSize(width: 100, height: 100)))
        if let slider = mpVolumeView.subviews.first as? UISlider {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                slider.value = volume
            }
        }
    }
    
    func volumeDown() {
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


extension SpeechHelper: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        //TODO: Disable action from gaze tracker interface when playing audio.
        UIApplication.shared.beginIgnoringInteractionEvents() // Disable the click interface when playing audio.
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
