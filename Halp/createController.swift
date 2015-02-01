//
//  createController.swift
//  Halp
//
//  Created by Andrew Lisowski on 1/27/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class createController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var addPhoto: UIButton!
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        addPhoto.frame = CGRectMake(100, 100, 100, 100)
        addPhoto.setBackgroundImage(image, forState: .Normal)
        addPhoto.setTitle("", forState: .Normal)
    }
    
    @IBAction func addPhotoButton(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func createAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest?.evaluateWithObject(testStr)
        return result!
    }
    
    @IBOutlet var email: UITextField!
    @IBOutlet var firstname: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPass: UITextField!
    @IBAction func createButton(sender: AnyObject) {
        if email.text == "" {
            createAlert("Error Creating Account", message: "Please provide an email address.")
        } else if !isValidEmail(email.text) {
            createAlert("Error Creating Account", message: "Please provide a valid email address.")
        } else if firstname.text == "" {
            createAlert("Error Creating Account", message: "Please provide a first name.")
        } else if lastName.text == "" {
            createAlert("Error Creating Account", message: "Please provide a last name.")
        } else if password.text == "" {
            createAlert("Error Creating Account", message: "Please provide a password.")
        } else if confirmPass.text == "" {
            createAlert("Error Creating Account", message: "Please provide confirm your password.")
        } else if confirmPass.text != password.text {
            createAlert("Error Creating Account", message: "Passwords didn't match.")
        } else {
            //Send new account to backend
            let request = NSMutableURLRequest(URL: NSURL(string: "http://api.halp.me/register")!)
            request.HTTPMethod = "POST"
            var params = [
                "firstname": firstname.text,
                "lastname": lastName.text,
                "email": email.text,
                "passwordHash":"\(password.text.md5)"
            ] as Dictionary<String, String>
            
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
                        self.performSegueWithIdentifier("toLogin", sender: self)
                    }
                } else if json["code"] == "email_taken" {
                    self.createAlert("Problem Creating Accoutn", message: "Someone is already using that email!")
                }
            }
            task.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addPhoto.backgroundColor = UIColor.clearColor()
        addPhoto.layer.cornerRadius = 0.5 * addPhoto.bounds.size.width
        addPhoto.layer.borderWidth = 1
        addPhoto.layer.borderColor = colorWithHexString("e0e0e0").CGColor
        addPhoto.clipsToBounds = true
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
}
