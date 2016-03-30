//
//  NewBiteViewController.swift
//  Bite
//
//  Created by Andrew Burns on 1/16/16.
//  Copyright © 2016 Andrew Burns. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class NewTextBiteViewController: UIViewController {
    
    func setSessionPlayerOn()
    {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch _ {
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var nameField: UITextField!
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")

    @IBAction func play(sender: AnyObject) {
        myUtterance = AVSpeechUtterance(string: textView.text )
        myUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        myUtterance.rate = 0.5
        synth.speakUtterance(myUtterance)
    }
    

    @IBAction func save(sender: AnyObject) {
        saveTextBite()
    self.performSegueWithIdentifier("unwindBacktoTableView", sender: self)
    }

    func saveTextBite() {
        if textView.text != " " && nameField.text != " " {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedObjectContext = appDelegate.managedObjectContext
            let newitem = NSEntityDescription.insertNewObjectForEntityForName("TextBite", inManagedObjectContext: managedObjectContext) as! TextBite
            newitem.text = textView.text
            newitem.name = nameField.text
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
      }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setSessionPlayerOn()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
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
