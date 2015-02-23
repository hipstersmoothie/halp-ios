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
    
    @IBOutlet var email: UITextField!
    @IBOutlet var firstname: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPass: UITextField!
    @IBAction func createButton(sender: AnyObject) {
        if email.text == "" {
            createAlert(self, "Error Creating Account", "Please provide an email address.")
        } else if !isValidEmail(email.text) {
            createAlert(self, "Error Creating Account", "Please provide a valid email address.")
        } else if firstname.text == "" {
            createAlert(self, "Error Creating Account", "Please provide a first name.")
        } else if lastName.text == "" {
            createAlert(self, "Error Creating Account", "Please provide a last name.")
        } else if password.text == "" {
            createAlert(self, "Error Creating Account", "Please provide a password.")
        } else if confirmPass.text == "" {
            createAlert(self, "Error Creating Account", "Please provide confirm your password.")
        } else if confirmPass.text != password.text {
            createAlert(self, "Error Creating Account", "Passwords didn't match.")
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
            
            pause(self.view)
            halpApi.register(params, completionHandler: self.afterCreate)
        }
    }
    
    func afterCreate(success: Bool, json: JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            start(self.view)
            if success {
                self.performSegueWithIdentifier("toLogin", sender: self)
            } else {
                createAlert(self, "Problem Creating Account", "Someone is already using that email!")
            }
        }
    }
    
    @IBOutlet var createButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addPhoto.backgroundColor = UIColor.clearColor()
        addPhoto.layer.cornerRadius = 0.5 * addPhoto.bounds.size.width
        addPhoto.layer.borderWidth = 1
        addPhoto.layer.borderColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1).CGColor
        addPhoto.clipsToBounds = true
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: .TouchUpInside)
        myBackButton.setTitle("Back", forState: .Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        myBackButton.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        navigationController?.navigationBar.barTintColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let buttonColor = UIColor(red: 20/255, green: 140/255, blue: 139/255, alpha: 1)
        
        createButton.backgroundColor = buttonColor
        createButton.layer.cornerRadius = 12
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = buttonColor.CGColor
        createButton.clipsToBounds = true
        
        email.borderStyle = .RoundedRect
        email.layer.shadowOpacity = 0.2
        email.layer.shadowRadius = 3.5
        email.layer.shadowColor = UIColor.blackColor().CGColor;
        email.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        email.clipsToBounds = false
        
        firstname.borderStyle = .RoundedRect
        firstname.layer.shadowOpacity = 0.2
        firstname.layer.shadowRadius = 3.5
        firstname.layer.shadowColor = UIColor.blackColor().CGColor;
        firstname.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        firstname.clipsToBounds = false
        
        lastName.borderStyle = .RoundedRect
        lastName.layer.shadowOpacity = 0.2
        lastName.layer.shadowRadius = 3.5
        lastName.layer.shadowColor = UIColor.blackColor().CGColor;
        lastName.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        lastName.clipsToBounds = false
        
        password.borderStyle = .RoundedRect
        password.layer.shadowOpacity = 0.2
        password.layer.shadowRadius = 3.5
        password.layer.shadowColor = UIColor.blackColor().CGColor;
        password.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        password.clipsToBounds = false
        
        confirmPass.borderStyle = .RoundedRect
        confirmPass.layer.shadowOpacity = 0.2
        confirmPass.layer.shadowRadius = 3.5
        confirmPass.layer.shadowColor = UIColor.blackColor().CGColor;
        confirmPass.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        confirmPass.clipsToBounds = false
    }
    
    func popToRoot(sender:UIBarButtonItem){
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isValidEmail(testStr:String) -> Bool {
        println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest?.evaluateWithObject(testStr)
        return result!
    }
    
    // MARK: Text Field Usability
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Image Picker functions
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
}
