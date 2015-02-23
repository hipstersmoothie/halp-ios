//
//  SessionDetialController.swift
//  Halp
//
//  Created by Andrew Lisowski on 1/31/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class SessionDetialController: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    @IBOutlet var universityField: UITextField!
    @IBOutlet var courseField: UITextField!
    @IBOutlet var timeField: UITextField!
    @IBOutlet var uniPicker: UIPickerView!
    @IBOutlet var coursePicker: UIPickerView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var addPhoto: UIButton!
    @IBOutlet var sessDesc: UITextView!
    @IBOutlet var skillsField: UITextField!
    @IBOutlet var nav: UINavigationItem!
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
    
    var universities:[String]!
    var courses:[String]!
    
    func getUniversities() -> [String] {
        return ["Cal Poly"]
    }
    
    func getCourses() -> [String] {
        return ["CPE 101", "PSY 252", "ENGL 149", "CSC 103"]
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
            var skillsArr = split(skillsField.text) {$0 == ","}
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
        println("posted Pin")
        println(json)
        start(self.view)
    }
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var searchButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uniPicker.removeFromSuperview()
        toolbar.removeFromSuperview()
        universities = getUniversities()
        universityField.inputView = uniPicker
        universityField.inputAccessoryView = toolbar
        uniPicker.tag = 0
        universityField.addTarget(self, action: Selector("enterUni:"), forControlEvents: .EditingDidBegin)
        
        coursePicker.removeFromSuperview()
        courses = getCourses()
        courseField.inputView = coursePicker
        courseField.inputAccessoryView = toolbar
        coursePicker.tag = 1
        courseField.addTarget(self, action: Selector("enterCourse:"), forControlEvents: .EditingDidBegin)
        
        datePicker.removeFromSuperview()
        configureDatePicker()
        timeField.inputView = datePicker
        timeField.inputAccessoryView = toolbar
        
        addPhoto.backgroundColor = UIColor.clearColor()
        addPhoto.layer.cornerRadius = 0.5 * addPhoto.bounds.size.width
        addPhoto.layer.borderWidth = 1
        addPhoto.layer.borderColor = colorWithHexString("e0e0e0").CGColor
        addPhoto.clipsToBounds = true
        
        sessDesc.returnKeyType = .Done
        
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: .ValueChanged)
        timeField.addTarget(self, action: Selector("datePickerInit:"), forControlEvents: .EditingDidBegin)
        
        let buttonColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        
        searchButton.backgroundColor = buttonColor
        searchButton.layer.cornerRadius = 12
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = buttonColor.CGColor
        searchButton.clipsToBounds = true
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
            universityField.text = universities[0]
        }
    }
    
    func enterCourse(field:UITextField) {
        if courseField.text == "" {
            courseField.text = courses[0]
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return universities.count
        } else if pickerView.tag == 1 {
            return courses.count
        } else if pickerView.tag == 2 {
            return  0
        } else if  pickerView.tag == 3 {
            return 0
        }
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            return universities[row]
        } else if pickerView.tag == 1 {
            return courses[row]
        } else if pickerView.tag == 2 {
            return ""
        } else if pickerView.tag == 3 {
            return ""
        }
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0 {
            universityField.text = universities[row]
        } else if pickerView.tag == 1 {
            courseField.text = courses[row]
        } else if pickerView.tag == 2 {
            universityField.text = ""
        } else if pickerView.tag == 3 {
            universityField.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    func uploadImageOne(){
        var imageData = UIImagePNGRepresentation(pickedImage)
        
        if imageData != nil{
            var request = NSMutableURLRequest(URL: NSURL(string:"Enter Your URL")!)
            var session = NSURLSession.sharedSession()
            
            request.HTTPMethod = "POST"
            
            var boundary = NSString(format: "---------------------------14737809831466499882746641449")
            var contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
            //  println("Content Type \(contentType)")
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            var body = NSMutableData.alloc()
            
            // Title
            body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Disposition: form-data; name=\"title\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            
            // Image
            body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Disposition: form-data; name=\"profile_img\"; filename=\"img.jpg\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(imageData)
            body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            
            request.HTTPBody = body
            
            var returnData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
            var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
            println("returnString \(returnString)")
        }
    }

}
