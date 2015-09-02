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
    var pickedImage:UIImage!
    
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
            var base64String:String = ""
            if pickedImage != nil {
                let imageData = UIImagePNGRepresentation(pickedImage)
                base64String = imageData.base64EncodedStringWithOptions(nil)
            }
            
            var params = [
                "firstname": firstname.text,
                "lastname": lastName.text,
                "email": email.text,
                "passwordHash":"\(password.text.md5)",
                "image": base64String,
                "pushType": "apn",
                "pushToken": thisDeviceToken.hexString()
            ]
            
            pause(self.view)
            halpApi.register(params, completionHandler: self.afterCreate)
        }
    }
    
    func afterCreate(success: Bool, json: JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            start(self.view)
            if success {
                loggedInUser = User(user: json["profile"], courses: json["profile"]["tutor"]["courses"])
                sessionId = json["sessionId"]
                self.performSegueWithIdentifier("toMap", sender: self)
                getInitData()
                NSNotificationCenter.defaultCenter().postNotificationName("loggedIn", object: nil, userInfo: nil)
            } else {
                createAlert(self, "Problem Creating Account", "Someone is already using that email!")
            }
        }
    }
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var content: UIView!
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addPhoto.layer.cornerRadius = 0.5 * addPhoto.bounds.size.width
        scrollView.contentSize = content.frame.size;
    }
    
    @IBOutlet var createButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addPhoto.backgroundColor = UIColor.clearColor()
        addPhoto.layer.borderWidth = 1
        addPhoto.layer.borderColor = teal.CGColor
        addPhoto.clipsToBounds = true
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: .TouchUpInside)
        myBackButton.setTitle("Back", forState: .Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        myBackButton.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        navigationController?.navigationBar.barTintColor = teal
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        styleButton(createButton)
        styleField(email, "email")
        styleField(firstname, "first name")
        styleField(lastName, "last name")
        styleField(password, "password")
        styleField(confirmPass, "confirm pass")
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
        let result = emailTest.evaluateWithObject(testStr)
        return result
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 100)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 100)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.3
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    // MARK: Image Picker functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        addPhoto.frame = CGRectMake(100, 100, 100, 100)
        addPhoto.setBackgroundImage(image, forState: .Normal)
        addPhoto.setTitle("", forState: .Normal)
        pickedImage = RBSquareImageTo(image, CGSize(width: 100, height: 100))
    }
    
    @IBAction func addPhotoButton(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
}
