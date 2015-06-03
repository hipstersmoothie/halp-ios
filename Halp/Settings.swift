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
        
        if infoCell.firstName.text != loggedInUser.firstname {
            params.updateValue(infoCell.firstName.text, forKey: "firstname")
        }
        
        if infoCell.lastName.text != loggedInUser.lastname {
            params.updateValue(infoCell.lastName.text, forKey: "lastname")
        }
        
        if newPic != nil {
            let imageData = UIImagePNGRepresentation(newPic)
            let base64String = imageData.base64EncodedStringWithOptions(nil)
            
            params.updateValue(base64String, forKey: "image")
        }
        
        //Tutor Settings
        var tutor = Dictionary<String, AnyObject>()
        if bio.bio.text != loggedInUser.bio {
            tutor.updateValue(bio.bio.text, forKey: "bio")
        }
        
        var skillsArr = split(skills.skills.text) {$0 == ","}
        if skillsArr.count != loggedInUser.skills.count {
            tutor.updateValue(skillsArr, forKey: "skills")
        }

        if rate.rate.text != "" && (rate.rate.text as NSString).doubleValue != loggedInUser.rate {
            tutor.updateValue( (rate.rate.text as NSString).doubleValue, forKey: "rate")
        }
        
        if tutor.count > 0 {
            params.updateValue(tutor, forKey: "tutor")
        }
        
        halpApi.updateProfile(params, completionHandler: self.updatedProfile)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.delegate = self
        image.sourceType = .PhotoLibrary
        image.allowsEditing = false
        
        courseRow = universities.count
    }
    
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
    
    // MARK: Table View Functions
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if loggedInUser.rate > 0 {
            return 3
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        } else {
            return 1 + courseRow
        }
    }
    
    var infoCell:basicInfo!
    var bio:bioCell!
    var skills:skillsCell!
    var rate:rateCell!
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            infoCell = self.tableView.dequeueReusableCellWithIdentifier("basicInfo") as! basicInfo
            
            infoCell.firstName.text = loggedInUser.firstname
            infoCell.firstName.delegate = self
            infoCell.lastName.text = loggedInUser.lastname
            infoCell.lastName.delegate = self
            
            infoCell.editPic.tag = indexPath.row
            infoCell.editPic.addTarget(self, action: "pickPhoto:", forControlEvents: .TouchUpInside)
            
            infoCell.profilePic.clipsToBounds = true
            infoCell.profilePic.layer.masksToBounds = true
            infoCell.profilePic.layer.borderWidth = 1
            infoCell.profilePic.layer.borderColor =  teal.CGColor
            infoCell.profilePic.layer.cornerRadius = infoCell.profilePic.frame.height/2

            if newPic != nil {
                infoCell.profilePic.image = newPic
            } else if loggedInUser.image != "" {
                let url = NSURL(string: loggedInUser.image)
                let data = NSData(contentsOfURL: url!)
                infoCell.profilePic.image = RBSquareImageTo(UIImage(data: data!)!, CGSize(width: 100, height: 100))
            }
            infoCell.selectionStyle = .None
            return infoCell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                bio = self.tableView.dequeueReusableCellWithIdentifier("bio") as! bioCell
                
                if loggedInUser.bio != "" {
                     bio.bio.text = loggedInUser.bio
                } else {
                     bio.bio.text = "Write a bio about yourself. This helps student get to know you before you meet."
                }
                
                bio.selectionStyle = .None
                bio.bio.delegate = self
                //bio.bio.becomeFirstResponder()
                
                return bio
            } else if indexPath.row == 1 {
                skills = self.tableView.dequeueReusableCellWithIdentifier("skills") as! skillsCell
                
                skills.skills.text = ", ".join(loggedInUser.skills)
                
                skills.selectionStyle = .None
                return skills
            } else {
                rate = self.tableView.dequeueReusableCellWithIdentifier("rate") as! rateCell
                
                if loggedInUser.rate > 0 {
                    rate.rate.text = "\(loggedInUser.rate)"
                } else {
                    rate.rate.text = "0"
                }
                
                rate.selectionStyle = .None
                return rate
            }
        } else {
            if indexPath.row == 0 || indexPath.row < courseRow {
                var expCell = self.tableView.dequeueReusableCellWithIdentifier("uniAndCourse") as! experienceCell
                
                expCell.university.text = universities[indexPath.row]
                var courseArr:[String] = []
                for course in courses[indexPath.row] {
                    courseArr.append("\(course.subject) \(course.number)")
                }
                
                //expCell.courseList.text = ", ".join(courseArr)
                expCell.selectionStyle = .None
                return expCell
            } else {
                var addUni = self.tableView.dequeueReusableCellWithIdentifier("addAnother") as! UITableViewCell
                
                addUni.selectionStyle = .None
                return addUni
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Basic Info"
        } else if section == 1 {
            return "Tutor Info"
        } else {
            return "Classes I want to Tutor"
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                return 180
            } else if indexPath.row == 1 {
                return 60
            } else {
                return 60
            }
        } else {
            if indexPath.row == 0 || indexPath.row < courseRow {
                return 90
            } else {
                return 93
            }
        }
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
