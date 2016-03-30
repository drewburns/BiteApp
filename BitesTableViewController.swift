//
//  BitesTableViewController.swift
//  Bite
//
//  Created by Andrew Burns on 1/16/16.
//  Copyright © 2016 Andrew Burns. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class BitesTableViewController: UITableViewController, AVAudioPlayerDelegate {

    var SoundPlayer : AVAudioPlayer!
    
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
    
    @IBAction func refresh(sender: AnyObject) {
        refresh()
    }
    var soundBites = [SoundBite]() {
        didSet {
            soundBites = soundBites.reverse()
        }
    }
    var textBites = [TextBite]()  {
        didSet {
            textBites = textBites.reverse()
        }
    }
    var segment: UISegmentedControl?
    var typeOfBite = "Sound"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: (self.navigationController?.navigationBar.bounds.height)!))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo.png")
        imageView.image = image
        navigationItem.titleView = imageView
        // Setup the gradient
        setSessionPlayerOn()
        refresh()
        addHeader()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func refresh() {
        soundBites.removeAll()
        textBites.removeAll()
        getData()
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addHeader() {
        let myCustomView = UISegmentedControl(items: ["SoundBites", "TextBites"])
        myCustomView.selectedSegmentIndex = 0
        myCustomView.addTarget(self, action: "changeBites:", forControlEvents: .ValueChanged)
        segment = myCustomView
        //      _me = UIScreen.mainScreen().bounds
        //        myCustomView.frame = CGRectMake(frame.minX + 10, frame.minY + 50,
        //            frame.width - 20, frame.height*0.1)
        tableView.tableHeaderView = myCustomView
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return soundBites.count
//    }
    
    func changeBites(sender: UISegmentedControl) {
        if typeOfBite == "Sound" {
            typeOfBite = "Text"
        } else {
            typeOfBite = "Sound"
        }
       refresh()
    }
    
    func getData() {
        getSoundBites()
        getTextBites()
    }
    
    func getSoundBites() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("SoundBite", inManagedObjectContext: managedObjectContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedObjectContext.executeFetchRequest(fetchRequest)
            for res in result {
                soundBites.append(res as! SoundBite)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func getTextBites(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("TextBite", inManagedObjectContext: managedObjectContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedObjectContext.executeFetchRequest(fetchRequest)
            for res in result {
                textBites.append(res as! TextBite)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var returnValue = 0
        if segment?.selectedSegmentIndex == 0 {
            returnValue = soundBites.count
        } else {
            returnValue = textBites.count
        }
        return returnValue
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bite", forIndexPath: indexPath) as! BiteTableViewCell
        
        switch typeOfBite{
        case "Sound":
            cell.soundBite = self.soundBites[indexPath.row]
            cell.textBite = nil
            cell.nameLabel.text = self.soundBites[indexPath.row].name
        case "Text":
            cell.textBite = self.textBites[indexPath.row]
            cell.soundBite = nil
            cell.nameLabel.text = self.textBites[indexPath.row].name
        default:
            break
        }
        
        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { (action, indexPath) in
            if self.typeOfBite == "Sound" {
                let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context:NSManagedObjectContext = appDel.managedObjectContext
                
                let item = self.soundBites[indexPath.row]
                
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let url = NSURL.fileURLWithPath(documentsDirectory).URLByAppendingPathComponent(item.filename!)
                let fileManager:NSFileManager = NSFileManager.defaultManager()
                do {
                    try fileManager.removeItemAtPath(String(url))
                } catch {}
                
                context.deleteObject(item as NSManagedObject)
                do {
                    try context.save()
                } catch {}
                self.refresh()
            } else {
                let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context:NSManagedObjectContext = appDel.managedObjectContext
                
                let item = self.textBites[indexPath.row]
                context.deleteObject(item as NSManagedObject)
                do {
                    try context.save()
                } catch {}
                self.refresh()
            }

        }
        return [delete]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if typeOfBite == "Text" {
            let text = (textBites[indexPath.row].text)
            let synth = AVSpeechSynthesizer()
            let myUtterance = AVSpeechUtterance(string: text!)
            myUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            myUtterance.rate = 0.5
            synth.speakUtterance(myUtterance)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        } else {
            
            var error : NSError?
            do {
                //get documnets directory
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let url = NSURL.fileURLWithPath(documentsDirectory).URLByAppendingPathComponent(soundBites[indexPath.row].filename!)
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
        
        SoundPlayer.play()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    // Override to support editing the table view.
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
//    }


    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    @IBAction func newBite(sender: AnyObject) {
        if typeOfBite == "Sound" {
            self.performSegueWithIdentifier("newSoundBite", sender: self)
        } else {
           self.performSegueWithIdentifier("newTextBite", sender: self) 
        }
    }
    
    @IBAction func unwindBacktoTableViewSegue(segue: UIStoryboardSegue){
        self.refreshControl!.beginRefreshing()
        refresh()
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
