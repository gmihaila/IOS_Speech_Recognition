//
//  ViewController.swift
//  Speech_Recognition
//
//  Created by George Mihaila on 3/12/18.
//  Copyright © 2018 George Mihaila. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet var Output_Text: UITextView!
    @IBOutlet weak var Record_Button_Label: UIButton!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    var bestString = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func Talk_Texr(_ sender: UIButton) {
        let utterance = AVSpeechUtterance(string: self.bestString)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//        utterance.rate = 0.1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    @IBAction func Clear_Text(_ sender: UIButton) {
        self.bestString = "Say Something!"
        self.Output_Text.text! = self.bestString
    }
    
    @IBAction func Recored_Button(_ sender: UIButton) {
        if !isRecording {
            self.recordAndRecognizeSpeech()
            isRecording = true
            self.Record_Button_Label.setTitle("Stop Listening!", for: .normal)
        } else {
            self.cancelRecording()
            isRecording = false
            self.Record_Button_Label.setTitle("Start Listening!", for: .normal)

        }
    }
    
    func recordAndRecognizeSpeech(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        //prepare and start the recording using the audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("Audio Engine started!")
        } catch {
            print( "There has been an audio engine error.")
            return print(error)
        }
        
        //make a few more checks to make sure the recognizer is available for the device and for the locale
        guard let myRecognizer = SFSpeechRecognizer() else {
            print("Speech recognition is not supported for your current locale.")
            return
        }
        
        if !myRecognizer.isAvailable {
            print( "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        
        //call the recognitionTask method on the recognizer
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                self.bestString = result.bestTranscription.formattedString
                print("Text recognized: \n \(self.bestString)")
                self.Output_Text.text! = self.bestString
                
            } else if let error = error {
                print( "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    
    func cancelRecording() {
        audioEngine.stop()
        let node = audioEngine.inputNode
        node.removeTap(onBus: 0)
        
        recognitionTask?.cancel()
    }
    
}
