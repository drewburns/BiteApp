//
//  NewSoundBiteViewController.swift
//  Bite
//
//  Created by Andrew Burns on 1/16/16.
//  Copyright © 2016 Andrew Burns. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class NewSoundBiteViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    var name: String!
    var filename: String?
    var SoundPlayer : AVAudioPlayer!
    var audioRecorder: AVAudioRecorder?
    var saved = false
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem! {
        didSet {
            saveButton.enabled = false
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        if nameTextField.text != " " {
            saveSoundBite()
            self.performSegueWithIdentifier("unwindBacktoTableView", sender: self)
        }
    }
    
    func saveSoundBite() {
        if nameTextField.text != " " {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedObjectContext = appDelegate.managedObjectContext
            let newitem = NSEntityDescription.insertNewObjectForEntityForName("SoundBite", inManagedObjectContext: managedObjectContext) as! SoundBite
            newitem.name = nameTextField.text
            newitem.filename = filename!
            
            do {
                try managedObjectContext.save()
                self.saved = true
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    
    @IBAction func recordButton(sender: AnyObject) {
        if recordButton.titleLabel?.text == "Record" {
            record()
            recordButton.setTitle("Stop", forState: .Normal)
            playButton.enabled = false
        } else {
            audioRecorder?.stop()
            saveButton.enabled = true
            playButton.enabled = true
            recordButton.setTitle("Record", forState: .Normal)
        }
    }
    
    @IBAction func playButton(sender: AnyObject) {
        preparePlayer()
        SoundPlayer.play()
    }

    
    
    func preparePlayer(){
        
        var error : NSError?
        do {
            //get documnets directory
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let url = NSURL.fileURLWithPath(documentsDirectory).URLByAppendingPathComponent(self.filename!)
            SoundPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch  {
            SoundPlayer = nil
        }
        
        if let err = error{
            
            NSLog("sjkaldfhjakds")
        }
        else{
            
            SoundPlayer.delegate = self
            SoundPlayer.prepareToPlay()
            SoundPlayer.volume = 1.0
        }
        
    }
    
    func record() {
        //init
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        //ask for permission
        if (audioSession.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("granted")
                    
                    //set category and activate recorder session
                    try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try! audioSession.setActive(true)
                    
                    
                    //get documnets directory
                    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                    let url = NSURL.fileURLWithPath(documentsDirectory).URLByAppendingPathComponent(self.filename!)
                    
                    //create AnyObject of settings
                    let settings: [String : AnyObject] = [
                        AVFormatIDKey:Int(kAudioFormatAppleIMA4), //Int required in Swift2
                        AVSampleRateKey:44100.0,
                        AVNumberOfChannelsKey:2,
                        AVEncoderBitRateKey:12800,
                        AVLinearPCMBitDepthKey:16,
                        AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue
                    ]
                    
                    //record
                    do {
                        self.audioRecorder =  try AVAudioRecorder(URL: url, settings: settings)
                        self.audioRecorder!.record()
                    } catch{}
                    
                } else{
                    print("not granted")
                }
            })
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filename = "\(randomStringWithLength(12)).caf"
        print(filename)
        playButton.enabled = false

        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if saved == false {
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let url = NSURL.fileURLWithPath(documentsDirectory).URLByAppendingPathComponent(self.filename!)
            let fileManager:NSFileManager = NSFileManager.defaultManager()
            do {
              try fileManager.removeItemAtPath(String(url))
            } catch {}

        }
    }
    
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
