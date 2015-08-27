//
//  SetRateController.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class SetRateController: UIViewController {
    var setUpTutorParams:Dictionary<String, AnyObject>!

    @IBOutlet var rate: UILabel!
    @IBOutlet var rateSLider: UISlider!
    
    @IBAction func adjustRate(sender: AnyObject) {
        var str = NSString(format:"%.2f", rateSLider.value)
        rate.text = "$\(str)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let save = UIBarButtonItem(title: "Save!", style: .Plain, target: self, action: "saveInfo")
        self.navigationItem.rightBarButtonItem = save
    }
    
    func saveInfo() {
        setUpTutorParams.updateValue(rateSLider.value, forKey: "rate")
        var params = [
            "tutor" : setUpTutorParams
        ]
        halpApi.updateProfile(params, completionHandler: self.afterTutorCreate)
    }
    
    @IBOutlet var expTItle: UILabel!
    @IBOutlet var expText: UILabel!
    @IBOutlet var expButton: UIButton!
    
    @IBOutlet var setRateLabel: UILabel!
    @IBOutlet var perHourLabel: UILabel!
    
    func afterTutorCreate(success: Bool, json: JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            if success {
                self.setRateLabel.hidden = true
                self.rate.hidden = true
                self.perHourLabel.hidden = true
                self.rateSLider.hidden = true
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                
                self.expTItle.hidden = false
                self.expText.hidden = false
                self.expButton.hidden = false
            } else {
                createAlert(self, "Oops!", "Something went wrong making your tutor profile!")
            }
        }
    }
    
    @IBAction func startTutoring(sender: AnyObject) {
        pinMode = "tutor"
        self.performSegueWithIdentifier("toMap", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
