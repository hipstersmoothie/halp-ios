//
//  SessionDetialController.swift
//  Halp
//
//  Created by Andrew Lisowski on 1/31/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class SessionDetialController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, MPGTextFieldDelegate, ZFTokenFieldDataSource, ZFTokenFieldDelegate, AutoTokeDelegate {
    @IBOutlet var timeField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var tokenField: AutoToke!
    @IBOutlet var nav: UINavigationItem!
    @IBOutlet var contentHeight: NSLayoutConstraint!
    @IBOutlet var tokenHeight: NSLayoutConstraint!
    @IBOutlet var container: UIView!
    
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        tokens.addObject(text)
        tokenField.reloadData(true)
        updateTokenFieldHeight(tokenField, increment: true)
        scrollToBottom()
    }
    
    var skillsArr: [String] = []
    var pickedImage:UIImage!
    var tokens:NSMutableArray!
   
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
        if timeField.text == "" {
            createAlert(self, "Error Creating Sesson", "Please provide a desired time.")
        } else {
            //send request
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.backBarButtonItem = nil

            skillsArr = tokenField.getTokens()
            var base64String:String = ""
            if pickedImage != nil {
                let imageData = UIImagePNGRepresentation(pickedImage)
                base64String = imageData.base64EncodedStringWithOptions(nil)
            }
//            var params = [
//                "pinMode": pinMode,
//                "latitude": "\(userLocation.latitude)",
//                "longitude": "\(userLocation.longitude)",
//                "duration": datePicker.date.timeIntervalSinceNow,
//                "description": sessDesc.text!,
//                "skills": skillsArr,
//                "images": base64String != "" ? [base64String] : [],
//                "courses" : [
//                    universityField.text!: [
//                        [
//                            "subject": course[0],
//                            "number": course[1]
//                        ]
//                    ]
//                ]
//            ]
//            
//            pause(self.view)
//            halpApi.postPin(params, completionHandler: self.afterPostPin)
        }
    }
    
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    func afterPostPin(success: Bool, json: JSON) {
        start(self.view)
        if success {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("toMapNewSession", sender: nil)
            }
        } else {
            println(json)
        }
        println(json)
    }
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var searchButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        toolbar.removeFromSuperview()
        
        tokens = NSMutableArray()
        tokenField.delegate = self
        tokenField.dataSource = self
        tokenField.textField.placeholder = "Enter Some Skills"
        tokenField.reloadData(false)
        tokenField.mDelegate = self
        
        
        datePicker.removeFromSuperview()
        configureDatePicker()
        timeField.inputView = datePicker
        timeField.inputAccessoryView = toolbar
        
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: .ValueChanged)
        timeField.addTarget(self, action: Selector("datePickerInit:"), forControlEvents: .EditingDidBegin)
        
        styleButton(searchButton)
        
        self.navigationItem.title = "Halp"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = content.frame.size;
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
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    @IBOutlet var scrollView: UIScrollView!
    func tokenFieldDidBeginEditing(tokenField:ZFTokenField) {
        animateViewMoving(true, moveValue: 180)
        scrollToBottom()
    }
    
    func tokenFieldDidEndEditing(tokenField:ZFTokenField) {
        animateViewMoving(false, moveValue: 180)
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

    
    //MARK: uni and course picker
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        return []
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    func autoTokeDidEndEditing(textField: AutoToke, withSelection data: Dictionary<String, AnyObject>) {
        
    }
    
    //token field
    
    func skillAutoComplete(textfield: AutoToke) -> [Dictionary<String, AnyObject>] {
        return skills
    }
    
    @IBOutlet var content: UIView!
    var myRows:UInt = 0
    func autoFieldShouldSelect(textField: AutoToke) -> Bool {
        return true
    }
    
    func tokenSelected(textField: AutoToke) {
        updateTokenFieldHeight(textField, increment: true)
    }
    
    //token field Functions
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 50
    }
    
    func numberOfTokenInField(tokenField: ZFTokenField!) -> UInt {
        return UInt(tokens.count)
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: UInt) -> UIView! {
        var nibContents = NSBundle.mainBundle().loadNibNamed("TokenView", owner: nil, options: nil)
        var view: UIView = nibContents[0] as! UIView
        var label:UILabel = view.viewWithTag(2) as! UILabel
        var button:UIButton = view.viewWithTag(3) as! UIButton
        
        button.addTarget(self, action: Selector("tokenDeleteButtonPressed:"), forControlEvents: .TouchUpInside)
        
        label.text = tokens[Int(index)] as! NSString as String
        var size:CGSize = label.sizeThatFits(CGSizeMake(1000, 40))
        view.frame = CGRectMake(0, 5, size.width + 50, 40);
        let position = UIView(frame: CGRectMake(0, 0, size.width + 50, 40))
        position.addSubview(view)
        
        return position;
    }
    
    func tokenMarginInTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 10
    }
    
    func updateTokenFieldHeight(tokenField: ZFTokenField!, increment:Bool) {
        var val = CGFloat(50)
        if increment == false {
            if myRows > tokenField.height {
                myRows = tokenField.height
                
                if tokenHeight.constant - val >= 50 {
                    tokenHeight.constant -= val
                    contentHeight.constant -= val
                }
            }
        } else {
            if myRows < tokenField.height {
                myRows = tokenField.height
                tokenHeight.constant += val
                contentHeight.constant += val
            }
        }
    }
    
    func tokenFieldShouldEndEditing(textField: ZFTokenField!) -> Bool {
        return true
    }
    
    func tokenDeleteButtonPressed(tokenButton: UIButton) {
        //tokenField.indexOfTokenView(tokenButton.superview) needed?
        var index:Int = Int(tokenField.indexOfTokenView(tokenButton.superview))
        
        if index != NSNotFound {
            tokens.removeObjectAtIndex(index)
            tokenField.reloadData(false)
            
            updateTokenFieldHeight(tokenField, increment: false)
        }
    }
    
    func scrollToBottom() {
        var bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
}
