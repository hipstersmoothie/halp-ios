//
//  SessionDetialController.swift
//  Halp
//
//  Created by Andrew Lisowski on 1/31/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class SessionDetialController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, KSTokenViewDelegate, MPGTextFieldDelegate {
    @IBOutlet var universityField: MPGTextField_Swift!
    @IBOutlet var courseField: MPGTextField_Swift!
    @IBOutlet var timeField: UITextField!
    @IBOutlet var coursePicker: UIPickerView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var addPhoto: UIButton!
    @IBOutlet var sessDesc: UITextView!
    @IBOutlet var skillsView: KSTokenView!
    @IBOutlet var nav: UINavigationItem!
    var skillsArr: [String] = []
    var pickedImage:UIImage!
    let halpApi = HalpAPI()
    
    @IBAction func addPhotoButton(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        addPhoto.frame = CGRectMake(100, 100, 100, 100)
        addPhoto.setBackgroundImage(image, forState: .Normal)
        addPhoto.setTitle("", forState: .Normal)
        pickedImage = image
    }
    
    var universities:[Dictionary<String, AnyObject>]!
    var courses:[Dictionary<String, AnyObject>]!
    
    func getUniversities() -> [Dictionary<String, AnyObject>] {
        let calPoly = ["DisplayText":"Cal Poly","CustomObject":[]]
        let cuesta = ["DisplayText":"Cuesta","CustomObject":[]]
        return [calPoly, cuesta]
    }
    
    func getCourses() -> [Dictionary<String, AnyObject>] {
        let one = ["DisplayText":"CPE 101","CustomObject":[]]
        let two = ["DisplayText":"CPE 102","CustomObject":[]]
        let three = ["DisplayText":"CPE 103","CustomObject":[]]
        let four = ["DisplayText":"PSY 252","CustomObject":[]]
        let five = ["DisplayText":"ENGL 149","CustomObject":[]]
        let six = ["DisplayText":"CSC 141","CustomObject":[]]
        return [one, two, three, four, five, six]
    }
    
    func configureDatePicker() {
        // Set min/max date for the date picker.
        // As an example we will limit the date between now and 7 days from now.
        let now = NSDate()
        let currentCalendar = NSCalendar.currentCalendar()
        let dateComponents = NSDateComponents()
        
        dateComponents.day = 7
        let sevenDaysFromNow = currentCalendar.dateByAddingComponents(dateComponents, toDate: now, options: nil)
        
        dateComponents.day = 1
        let oneDayFromNow = currentCalendar.dateByAddingComponents(dateComponents, toDate: now, options: nil)
        
        datePicker.minimumDate = oneDayFromNow
        datePicker.maximumDate = sevenDaysFromNow
    }
    
    @IBAction func search(sender: AnyObject) {
        if universityField.text == "" {
            createAlert(self, "Error Creating Sesson", "Please provide a university.")
        } else if courseField.text == "" {
            createAlert(self, "Error Creating Sesson", "Please provide a course.")
        } else if sessDesc.text == "" || sessDesc.text == "Description of the problem you need help with." {
            createAlert(self, "Error Creating Sesson", "Please provide a description.")
        } else if timeField.text == "" {
            createAlert(self, "Error Creating Sesson", "Please provide a desired time.")
        } else {
            //send request
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.backBarButtonItem = nil
            var course = split(courseField.text) {$0 == " "}
            skillsArr = skillsArr.map({ skill in
                skill.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            })
            var base64String:String = ""
            if pickedImage != nil {
                let imageData = UIImagePNGRepresentation(pickedImage)
                base64String = imageData.base64EncodedStringWithOptions(nil)
            }
            
            var params = [
                "pinMode": pinMode,
                "latitude": "\(userLocation.latitude)",
                "longitude": "\(userLocation.longitude)",
                "duration": datePicker.date.timeIntervalSinceNow,
                "description": sessDesc.text!,
                "skills": skillsArr,
                "images": base64String != "" ? [base64String] : [],
                "courses" : [
                    universityField.text!: [
                        [
                            "subject": course[0],
                            "number": course[1]
                        ]
                    ]
                ]
            ]
            
            pause(self.view)
            halpApi.postPin(params, completionHandler: self.afterPostPin)
            self.performSegueWithIdentifier("toMapNewSession", sender: nil)
        }
    }
    
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string
                }
            }
        }
        return ""
    }
    
    func afterPostPin(success: Bool, json: JSON) {
        start(self.view)
    }
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var searchButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.removeFromSuperview()
        universities = getUniversities()
        universityField.mDelegate = self
        
        courses = getCourses()
        courseField.mDelegate = self
        
        datePicker.removeFromSuperview()
        configureDatePicker()
        timeField.inputView = datePicker
        timeField.inputAccessoryView = toolbar
        
        addPhoto.backgroundColor = UIColor.clearColor()
        addPhoto.layer.cornerRadius = 0.5 * addPhoto.bounds.size.width
        addPhoto.layer.borderWidth = 1
        addPhoto.layer.borderColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1).CGColor
        addPhoto.clipsToBounds = true
        
        sessDesc.returnKeyType = .Done
        sessDesc.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        sessDesc.layer.borderWidth = 1.0
        sessDesc.layer.cornerRadius = 5
        sessDesc.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12)
        sessDesc.textColor = UIColor.lightGrayColor()
        
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: .ValueChanged)
        timeField.addTarget(self, action: Selector("datePickerInit:"), forControlEvents: .EditingDidBegin)
        
        let buttonColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        
        searchButton.backgroundColor = buttonColor
        searchButton.layer.cornerRadius = 12
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = buttonColor.CGColor
        searchButton.clipsToBounds = true
        
        setUpTokenView(skillsView, title: "Skills", placeHolder: "Search", limit: -1)
    }
    
    func setUpTokenView(view: KSTokenView, title: String, placeHolder: String, limit: Int) {
        view.delegate = self
        view.promptText = title + ":"
        view.placeholder = placeHolder
        view.descriptionText = title
        view.maxTokenLimit = limit
        view.style = .Rounded
        view.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5
    }
    
    @IBAction func donePicker(sender: AnyObject) {
        self.view.endEditing(true);
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        timeField.text = strDate
    }
    
    func enterUni(field:UITextField) {
        if universityField.text == "" {
            universityField.text = "Cal Poly"
        }
    }
    
    func datePickerInit(field:UITextField) {
        if timeField.text == "" {
            var dateFormatter = NSDateFormatter()
            
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            
            var strDate = dateFormatter.stringFromDate(NSDate())
            timeField.text = strDate
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Text Field Usability
    
    func textViewDidBeginEditing(textView: UITextView) {
        animateViewMoving(true, moveValue: 100)
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        animateViewMoving(false, moveValue: 100)
        if textView.text.isEmpty {
            textView.text = "Description of the problem you need help with."
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == timeField {
            animateViewMoving(true, moveValue: 180)
        } else if textField != universityField && textField != courseField {
            animateViewMoving(true, moveValue: 100)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == timeField {
            animateViewMoving(false, moveValue: 180)
        } else if textField != universityField && textField != courseField {
            animateViewMoving(false, moveValue: 100)
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    var names = ["a", "b", "aa"]
    // MARK: Skills 
    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        var data: Array<String> = []
        for value: String in names {
            if value.lowercaseString.rangeOfString(string.lowercaseString) != nil {
                data.append(value)
            }
        }
        completion!(results: data)
    }
    
    func tokenView(token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as String
    }
    
    var shifted = false
    func tokenViewDidEndEditing(tokenView: KSTokenView) {
        for token:KSToken in tokenView.tokens() {
            skillsArr.append(token.title)
        }
        animateViewMoving(false, moveValue: 180)
        shifted = false
    }
    
    func tokenViewDidBeginEditing(tokenView: KSTokenView) {
        if shifted == false {
            animateViewMoving(true, moveValue: 180)
            shifted = true
        }
    }
    
    //MARK: uni picker
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        if textfield == universityField {
            return universities
        } else {
            return courses
        }
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>){
        println("Dictionary received = \(data)")
    }
}
