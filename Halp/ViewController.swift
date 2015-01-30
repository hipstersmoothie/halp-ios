//
//  ViewController.swift
//  Halp
//
//  Created by Andrew Lisowski on 1/27/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBAction func login(sender: AnyObject) {
        if username.text == "" {
            createAlert("Error Logging In", message: "Please provide an email address.")
        } else if password.text == "" {
            createAlert("Error Logging In", message: "Please provide a password.")
        } else {
            //Try to Log in
            let request = NSMutableURLRequest(URL: NSURL(string: "http://api.halp.me/login")!)
            request.HTTPMethod = "POST"
            var params = ["email": username.text, "passwordHash":"\(password.text.md5)"] as Dictionary<String, String>
            
            var err: NSError?
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {data, response, error -> Void in
                if error != nil {
                    println("error=\(error)")
                    return
                }
                
                let json = JSON(data: data)
                if json["code"] == "success" {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("toApp", sender: self)
                    }
                } else {
                    self.createAlert("Error Logging In", message: "Please provide valid credentials.")
                }
            }
            task.resume()
        }
    }

    @IBAction func facebookLogin(sender: AnyObject) {
        
    }
    
    @IBAction func googlePlusLogin(sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func createAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}

