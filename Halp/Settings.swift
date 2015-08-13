//
//  Settings.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/9/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class Settings: UITableViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var courseRow = 1
    var firstname:String!
    var universities:[String] = []
    var courses:[[Course]] = []
    var newPic:UIImage!
    var image = UIImagePickerController()
    
    func pickPhoto(sender: AnyObject) {
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        newPic = RBSquareImageTo(image, CGSize(width: 100, height: 100))
        tableView.reloadData()
    }
    
    @IBAction func addUniRow(sender: AnyObject) {
        courseRow++
        tableView.reloadData()
    }
    
    @IBAction func saveSettings(sender: AnyObject) {
        var params = Dictionary<String, AnyObject>()
        
//        if infoCell.firstName.text != loggedInUser.firstname {
//            params.updateValue(infoCell.firstName.text, forKey: "firstname")
//        }
//        
//        if infoCell.lastName.text != loggedInUser.lastname {
//            params.updateValue(infoCell.lastName.text, forKey: "lastname")
//        }
//        
//        if newPic != nil {
//            let imageData = UIImagePNGRepresentation(newPic)
//            let base64String = imageData.base64EncodedStringWithOptions(nil)
//            
//            params.updateValue(base64String, forKey: "image")
//        }
//        
//        //Tutor Settings
//        var tutor = Dictionary<String, AnyObject>()
//        if bio.bio.text != loggedInUser.bio {
//            tutor.updateValue(bio.bio.text, forKey: "bio")
//        }
//        
//        var skillsArr = split(skills.skills.text) {$0 == ","}
//        if skillsArr.count != loggedInUser.skills.count {
//            tutor.updateValue(skillsArr, forKey: "skills")
//        }
//
//        if rate.rate.text != "" && (rate.rate.text as NSString).doubleValue != loggedInUser.rate {
//            tutor.updateValue( (rate.rate.text as NSString).doubleValue, forKey: "rate")
//        }
//        
//        if tutor.count > 0 {
//            params.updateValue(tutor, forKey: "tutor")
//        }
//        
//        halpApi.updateProfile(params, completionHandler: self.updatedProfile)
    }
    
    func updatedProfile(success:Bool, json:JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            if success {
                createAlert(self, "Success!", "Account details changed.")
            } else {
                createAlert(self, "Error.", "Something went wrong changing your account details.")
            }
        }
    }
    
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var bioTextview: UITextView!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var skillsField: UITextField!
    @IBOutlet var rateField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var bankingInfoCell: UITableViewCell!
    @IBOutlet var classesCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        image.delegate = self
        image.sourceType = .PhotoLibrary
        image.allowsEditing = false
        
        courseRow = universities.count
        
        styleField(firstName, "first name")
        firstName.text = loggedInUser.firstname
        
        styleField(lastName, "last name")
        lastName.text = loggedInUser.lastname
        
        loadProfilePic(profilePic, loggedInUser)
        
        styleField(skillsField, "algebra, excel, etc.")
        if loggedInUser.skills.count > 0 {
            skillsField.text = ", ".join(loggedInUser.skills)
        }
        
        styleField(rateField, "20")
        if loggedInUser.rate > 0 {
            rateField.text = "\(loggedInUser.rate)"
        }
        
        styleButton(saveButton)
        
        bankingInfoCell.accessoryType = .DisclosureIndicator
        classesCell.accessoryType = .DisclosureIndicator
        
        if loggedInUser.bio != "" {
            bioTextview.text = loggedInUser.bio
        }
        
        if loggedInUser.rate == 0 {
            self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .None)
        }
    }
    
    @IBOutlet var addAnotherSection: UITableViewCell!
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Account Settings"
        for (university, courseList) in loggedInUser.courses {
            universities.append(university)
            courses.append(courseList)
        }
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if textField.tag != 0 && textField.tag != 1 {
            var pointInTable:CGPoint = textField.superview!.convertPoint(textField.frame.origin, toView:self.tableView)
            var contentOffset:CGPoint = self.tableView.contentOffset
            contentOffset.y  = pointInTable.y
            if let accessoryView = textField.inputAccessoryView {
                contentOffset.y -= accessoryView.frame.size.height
            }
            
            contentOffset.y -= 150
            self.tableView.contentOffset = contentOffset
        }
        
        return true;
    }
//    
//    func textViewDidBeginEditing(textView: UITextView) {
//        animateViewMoving(true, moveValue: 100)
//        textView.text = nil
//    }
    
//    func textViewDidEndEditing(textView: UITextView) {
//        animateViewMoving(false, moveValue: 100)
//        if textView.text == "" {
//            textView.text = "Write a bio about yourself. This helps student get to know you before you meet."
//        }
//    }
//    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if loggedInUser.rate > 0 {
            return 3
        } else {
            return 2
        }
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

}
