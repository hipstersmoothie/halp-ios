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
    @IBOutlet var nav: UINavigationItem!
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
    }
    
    var universities:[String]!
    var courses:[String]!
    
    func getUniversities() -> [String] {
        return ["Cal Poly"]
    }
    
    func getCourses() -> [String] {
        return ["CPE 101", "PSY 252", "ENGL 149", "CSC 103"]
    }
    
    @IBAction func search(sender: AnyObject) {
        if universityField.text == "" {
            createAlert("Error Creating Sesson", message: "Please provide a university.")
        } else if courseField.text == "" {
            createAlert("Error Creating Sesson", message: "Please provide a course.")
        } else if sessDesc.text == "" {
            createAlert("Error Creating Sesson", message: "Please provide a description.")
        } else if timeField.text == "" {
            createAlert("Error Creating Sesson", message: "Please provide a desired time.")
        } else {
            //send request
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.backBarButtonItem = nil
            var course = split(courseField.text) {$0 == " "}
            
            var params = [
                "latitude": "\(userLocation.latitude)",
                "longitude": "\(userLocation.longitude)",
                "university": universityField.text!,
                "course" : [
                    "subject": course[0],
                    "number": course[1]
                ],
                "description": sessDesc.text!,
                "images": [],
                "skills": []
            ]
            
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
        println(json)
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
        println("here")
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
    
    func createAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
