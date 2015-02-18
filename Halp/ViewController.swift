//
//  ViewController.swift
//  Halp
//
//  Created by Andrew Lisowski on 1/27/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

var sessionId:JSON!
var loggedInUser:User!

class ViewController: UIViewController, UITextFieldDelegate, FBLoginViewDelegate {
    let fbHelper = FBHelper()
    let halpApi = HalpAPI()
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var diffAccountLabel: UILabel!
    @IBAction func login(sender: AnyObject) {
        if username.text == "" {
            createAlert(self, "Error Logging In", "Please provide an email address.")
        } else if password.text == "" {
            createAlert(self, "Error Logging In", "Please provide a password.")
        } else {
            var params = [
                "email": username.text,
                "passwordHash":"\(password.text.md5)",
                "type":"halp"
            ] as Dictionary<String, String>
            
            pause(self.view)
            halpApi.login(params, completionHandler: self.afterLogin)
        }
    }
    
    // MARK: Login Functions
    func afterLogin(success: Bool, json: JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            start(self.view)
            if success {
                println(json)
                loggedInUser = User(user: json["profile"], courses: json["profile"]["tutor"]["courses"])
                sessionId = json["sessionId"]
                self.performSegueWithIdentifier("toApp", sender: self)
            } else {
                createAlert(self, "Error Logging In", "Please provide valid credentials.")
            }
        }
    }

    @IBAction func facebookLogin(sender: AnyObject) {
        fbHelper.login();
    }
    
    @IBAction func googlePlusLogin(sender: AnyObject) {
        
    }
    
    func executeHandle(notification:NSNotification){
        let params = [
            "accessToken" : notification.object as String,
            "type" : "facebook"
            ] as Dictionary <String, String>
        
        pause(self.view)
        halpApi.login(params, completionHandler: self.afterLogin)
    }
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("executeHandle:"), name: "PostData", object: nil);

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        diffAccountLabel.textColor = UIColor.whiteColor()
        var border = CALayer()
        var width = CGFloat(1.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: diffAccountLabel.frame.size.height - width, width:  diffAccountLabel.frame.size.width, height: diffAccountLabel.frame.size.height)
        
        border.borderWidth = width
        diffAccountLabel.layer.addSublayer(border)
        diffAccountLabel.layer.masksToBounds = true
        
        let buttonColor = UIColor(red: 20/255, green: 140/255, blue: 139/255, alpha: 1)
        
        loginButton.backgroundColor = buttonColor
        loginButton.layer.cornerRadius = 12
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = buttonColor.CGColor
        loginButton.clipsToBounds = true
        
        
        registerButton.backgroundColor = buttonColor
        registerButton.layer.cornerRadius = 12
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = buttonColor.CGColor
        registerButton.clipsToBounds = true

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "PostData", object: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Text Field Usability
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Only Portrait Mode
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}