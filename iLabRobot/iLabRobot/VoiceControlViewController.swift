//
//  VoiceControlViewController.swift
//  iLabRobot
//
//  Created by JohnBryant on 6/2/16.
//  Copyright © 2016 JohnBryant. All rights reserved.
//

import UIKit
import AVFoundation

class RecordedAudio: NSObject
{
    var filePathUrl: NSURL!
    var title: String!
}

class VoiceControlViewController : UIViewController, AVAudioRecorderDelegate, IFlySpeechRecognizerDelegate {
    
    @IBOutlet weak var waveformView: SiriWaveformView!
    @IBOutlet weak var recordLabel: UILabel!
    
    var iFlySpeechUnderstander: IFlySpeechUnderstander!
    var iFlyUnderStand: IFlyTextUnderstander!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio = RecordedAudio()
    var isRecording: Bool = false {
        didSet {
            if isRecording {
                recordLabel.text = "点击停止识别"
                waveformView.waveColor = UIColor(red:0.928, green:0.103, blue:0.176, alpha:1)
            } else {
                recordLabel.text = "点击开始识别"
                waveformView.waveColor = UIColor.blackColor()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "语音控制"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        audioRecorder = self.audioRecorder(NSURL(fileURLWithPath:"/dev/null"))
        audioRecorder.record()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(VoiceControlViewController.updateMeters))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }


    func updateMeters() {
        audioRecorder.updateMeters()
        let normalizedValue = pow(10, audioRecorder.averagePowerForChannel(0) / 20)
        waveformView.updateWithLevel(CGFloat(normalizedValue))
    }
    
    @IBAction func tapVoiceForm(sender: UITapGestureRecognizer) {
        if isRecording {
            stopRecordingAudio()
        } else {
            recordAudio()
        }
        
        isRecording = !isRecording
    }
    
    func recordAudio() {
        
    }
    
    func stopRecordingAudio() {
        
    }
    
    func audioRecorder(filePath: NSURL) -> AVAudioRecorder {
        let recorderSettings: [String : AnyObject] = [
            AVSampleRateKey: 44100.0,
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue
        ]
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        let audioRecorder = try! AVAudioRecorder(URL: filePath, settings: recorderSettings)
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        
        return audioRecorder
    }
    
    
    
    // 开始识别回调
    func onBeginOfSpeech() {
        print("正在录音")
    }
    
    // 停止识别回调
    func onEndOfSpeech() {
        print("停止录音")
    }
    
    func onError(errorCode: IFlySpeechError!) {
        print("error")
    }
    
    // 语义理解结果回调
    func onResults(results: [AnyObject]!, isLast: Bool) {
        print("识别结果")
    }
    
    // 取消回调
    func onCancel() {
        print("识别取消")
    }
    
    
    
}
