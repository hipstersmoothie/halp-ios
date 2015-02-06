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
    let halpApi = HalpAPI()
    
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
            
            halpApi.register(params, completionHandler: self.afterCreate)
        }
    }
    
    func afterCreate(success: Bool, json: JSON) {
        if success {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("toLogin", sender: self)
            }
        } else {
            self.createAlert("Problem Creating Accoutn", message: "Someone is already using that email!")
        }
    }
    
    @IBOutlet var createButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addPhoto.backgroundColor = UIColor.clearColor()
        addPhoto.layer.cornerRadius = 0.5 * addPhoto.bounds.size.width
        addPhoto.layer.borderWidth = 1
        addPhoto.layer.borderColor = colorWithHexString("e0e0e0").CGColor
        addPhoto.clipsToBounds = true
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: .TouchUpInside)
        myBackButton.setTitle("Back", forState: .Normal)
        myBackButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        myBackButton.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        let buttonColor = UIColor(red: 20/255, green: 140/255, blue: 139/255, alpha: 1)
        
        createButton.backgroundColor = buttonColor
        createButton.layer.cornerRadius = 12
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = buttonColor.CGColor
        createButton.clipsToBounds = true
    }
    
    func popToRoot(sender:UIBarButtonItem){
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
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
