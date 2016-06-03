//
//  VoiceControlViewController.swift
//  iLabRobot
//
//  Created by JohnBryant on 6/2/16.
//  Copyright © 2016 JohnBryant. All rights reserved.
//

import UIKit

class RecordedAudio: NSObject
{
    var filePathUrl: NSURL!
    var title: String!
}

class VoiceControlViewController : UIViewController, AVAudioRecorderDelegate, IFlySpeechRecognizerDelegate {
    
    @IBOutlet weak var waveformView: SiriWaveformView!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var voiceText: UITextView!
    
    var iFlySpeechUnderstander: IFlySpeechUnderstander!
    
    var voiceResult = ""
    var understandResult: [String]!
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
    
    
    @IBAction func resetVoice(sender: AnyObject) {
        if !isRecording {
            self.voiceText.text = ""
        }
    }
    
    @IBAction func sendCommand(sender: AnyObject) {
        if !isRecording && self.voiceResult != "" {
            let confirmVC = self.storyboard?.instantiateViewControllerWithIdentifier("confirmViewController") as! ConfirmVoiceCommand
            confirmVC.underStandResult = self.understandResult
            confirmVC.voiceResult = self.voiceResult
            self.navigationController?.pushViewController(confirmVC, animated: true)
        } else {
            let alert = UIAlertController(title: "没有识别结果", message: "", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确认", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "语音控制"
        iFlySpeechUnderstander = IFlySpeechUnderstander.sharedInstance() as IFlySpeechUnderstander
        iFlySpeechUnderstander.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        audioRecorder = self.audioRecorder(NSURL(fileURLWithPath:"/dev/null"))
        audioRecorder.record()
        
        self.initRecognizer()
        
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
    }
    
    
    // 启动语音语义理解
    func recordAudio() {
        self.voiceText.text = ""
        self.voiceResult = ""
        self.voiceText.resignFirstResponder()
        
        iFlySpeechUnderstander.setParameter(IFLY_AUDIO_SOURCE_MIC, forKey: "audio_source")
        
        let ret = iFlySpeechUnderstander.startListening()
        print(iFlySpeechUnderstander.startListening())
        if ret {
            print("启动语音识别服务成功")
        } else {
            print("哈哈启动识别服务失败，请稍后重试")
        }
    }
    
    func stopRecordingAudio() {
        iFlySpeechUnderstander.stopListening()
        voiceText.resignFirstResponder()
        isRecording = false
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
    
    // 初始化：设置识别参数
    func initRecognizer() {
        if self.iFlySpeechUnderstander == nil {
            iFlySpeechUnderstander = IFlySpeechUnderstander.sharedInstance() as IFlySpeechUnderstander
        }
        iFlySpeechUnderstander.delegate = self

        if iFlySpeechUnderstander != nil {
            let instance = IATConfig()
            iFlySpeechUnderstander.setParameter(instance.speechTimeout, forKey: IFlySpeechConstant.SPEECH_TIMEOUT())
            iFlySpeechUnderstander.setParameter(instance.vadEos, forKey: IFlySpeechConstant.VAD_EOS())
            iFlySpeechUnderstander.setParameter(instance.vadBos, forKey: IFlySpeechConstant.VAD_BOS())
            iFlySpeechUnderstander.setParameter(instance.sampleRate, forKey: IFlySpeechConstant.SAMPLE_RATE())
            
            if instance.language == IATConfig.chinese() {
                iFlySpeechUnderstander.setParameter(instance.language, forKey: IFlySpeechConstant.LANGUAGE())
                iFlySpeechUnderstander.setParameter(instance.accent, forKey: IFlySpeechConstant.ACCENT())
            } else if instance.language == IATConfig.english() {
                iFlySpeechUnderstander.setParameter(instance.language, forKey: IFlySpeechConstant.LANGUAGE())
            }
        iFlySpeechUnderstander.setParameter(instance.dot, forKey: IFlySpeechConstant.ASR_PTT())
        }
    }
    
    func onKeyBoardDown() {
        voiceText.resignFirstResponder()
    }
    
    // 开始识别回调
    func onBeginOfSpeech() {
        isRecording = true
        print("正在录音")
    }
    
    // 停止识别回调
    func onEndOfSpeech() {
        isRecording = false
        print("停止录音")
    }
    
    func onError(errorCode: IFlySpeechError!) {
        print("error")
    }
    
    // 语义理解结果回调
    func onResults(results: [AnyObject]!, isLast: Bool) {
        print("识别结果: \(results)")
        var result = ""
        var dic = [:]
        if let voiceResults = results {
            dic = voiceResults[0] as! NSDictionary
            for (key, _) in dic {
                result += "\(key)"
            }
        }
        
        self.understandResult = resolveVoiceResult(result)
        for k in understandResult {
            print("k: \(k)")
            self.voiceResult += k
        }
        self.understandResult.popLast()
        self.voiceText.text = voiceResult
        self.voiceText.resignFirstResponder()

    }
    
    // 取消回调
    func onCancel() {
        print("识别取消")
    }
    
    func resolveVoiceResult(string: String) -> [String] {
        var result = [String]()
        let stringRemove1 = string.stringByReplacingOccurrencesOfString("{", withString: "")
        let stringRemove2 = stringRemove1.stringByReplacingOccurrencesOfString("[", withString: "")
        let stringRemove3 = stringRemove2.stringByReplacingOccurrencesOfString("]", withString: "")
        let stringRemove4 = stringRemove3.stringByReplacingOccurrencesOfString("}", withString: "")
//        let stringRemove5 = stringRemove4.stringByReplacingOccurrencesOfString("\"", withString: "")
        let Array = stringRemove4.componentsSeparatedByString(",")
        for e in Array {
            if e.containsString("\"w\"") {
                let ee = e.componentsSeparatedByString(":")
                let eee = ee[1].stringByReplacingOccurrencesOfString("\"", withString: "")
                result.append(eee)
            }
        }
        return result
    }
    
    
    
}
