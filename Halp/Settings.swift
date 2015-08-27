//
//  Settings.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/9/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class Settings: UITableViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var newPic:UIImage!
    var image = UIImagePickerController()
    var coursesInfo:Dictionary<String, AnyObject>!
    
    func pickPhoto(sender: AnyObject) {
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        newPic = RBSquareImageTo(image, CGSize(width: 100, height: 100))
        profilePic.image = newPic        
    }
    
    @IBAction func saveSettings(sender: AnyObject) {
        var params = Dictionary<String, AnyObject>()
        
        if firstName.text != loggedInUser.firstname {
            params.updateValue(firstName.text, forKey: "firstname")
        }

        if lastName.text != loggedInUser.lastname {
            params.updateValue(lastName.text, forKey: "lastname")
        }

        if newPic != nil {
            let imageData = UIImagePNGRepresentation(newPic)
            let base64String = imageData.base64EncodedStringWithOptions(nil)
            
            params.updateValue(base64String, forKey: "image")
        }
        
        //Tutor Settings
        var tutor = Dictionary<String, AnyObject>()
        if bioTextview.text != loggedInUser.bio {
            tutor.updateValue(bioTextview.text, forKey: "bio")
        }
        
        var skillsArr = split(skillsField.text) {$0 == "," }
        skillsArr = skillsArr.map() { skill in
            return skill.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        if skillsArr.count != loggedInUser.skills.count {
            tutor.updateValue(skillsArr, forKey: "skills")
        }

        if rateField.text != "" && (rateField.text as NSString).doubleValue != loggedInUser.rate {
            tutor.updateValue( (rateField.text as NSString).doubleValue, forKey: "rate")
        }
        
        tutor.updateValue(compileCourses(), forKey: "courses")
        
        if tutor.count > 0 {
            params.updateValue(tutor, forKey: "tutor")
        }
        pause(self.view)
        halpApi.updateProfile(params, completionHandler: self.updatedProfile)
    }
    
    func compileCourses() -> Dictionary<String,[Dictionary<String, String>]> {
        var courses = Dictionary<String,[Dictionary<String, String>]>()
        for (school, courseEntries) in coursesInfo {
            let coursesArr = courseEntries as! [Course]
            var interpCourses:[Dictionary<String, String>] = []
            for course in coursesArr {
                interpCourses.append([
                    "subject": course.subject,
                    "number": String(course.number)
                ])
            }
            
            courses.updateValue(interpCourses, forKey: school)
        }
        return courses
    }
    
    func updatedProfile(success:Bool, json:JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            start(self.view)
            if success {
                createAlert(self, "Success!", "Account details changed.")
                loggedInUser = User(user: json["profile"], courses: json["profile"]["tutor"]["courses"])
            } else {
                createAlert(self, "Error.", "Something went wrong changing your account details.")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Create a new variable to store the instance of PlayerTableViewController
        let destinationVC = segue.destinationViewController as! UniversityList
        destinationVC.coursesInfo = coursesInfo
        destinationVC.uniNames = Array(coursesInfo.keys)
        destinationVC.update = true
        destinationVC.controller = self
    }
    
    @IBAction func editPicture(sender: AnyObject) {
        pickPhoto(self)
    }
    
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var bioTextview: UITextView!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var skillsField: UITextField!
    @IBOutlet var rateField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var classesCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coursesInfo = loggedInUser.courses
        image.delegate = self
        image.sourceType = .PhotoLibrary
        image.allowsEditing = false
        
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
        
        classesCell.accessoryType = .DisclosureIndicator
        
        if loggedInUser.bio != "" {
            bioTextview.text = loggedInUser.bio
        }
        
        if loggedInUser.rate == 0 {
            self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .None)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 {
            self.performSegueWithIdentifier("showGetUnis", sender: nil)
        }
    }
    
    @IBOutlet var addAnotherSection: UITableViewCell!
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Account Settings"
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if textField.tag != 0 && textField.tag != 1 {
            animateViewMoving(textField)
        }
        
        return true;
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        animateViewMoving(textView)
        textView.text = nil
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        animateViewMoving(textView)
        if textView.text == "" {
            textView.text = "Write a bio about yourself. This helps student get to know you before you meet."
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if loggedInUser.rate > 0 {
            return 3
        } else {
            return 2
        }
    }
    
    func animateViewMoving (view: UIView){
        var pointInTable:CGPoint = view.superview!.convertPoint(view.frame.origin, toView:self.tableView)
        var contentOffset:CGPoint = self.tableView.contentOffset
        contentOffset.y  = pointInTable.y
        if let accessoryView = view.inputAccessoryView {
            contentOffset.y -= accessoryView.frame.size.height
        }
        
        contentOffset.y -= 150
        self.tableView.contentOffset = contentOffset

    }

}
