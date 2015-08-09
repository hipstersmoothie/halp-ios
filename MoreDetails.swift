//
//  SchoolPicker.swift
//  Halp
//
//  Created by Andrew Lisowski on 5/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class MoreDetails: UIViewController, XLPagerTabStripChildItem, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, ZFTokenFieldDataSource, ZFTokenFieldDelegate, AutoTokeDelegate {
    var pickedImage:UIImage!
    var tokens:NSMutableArray!
    var offset:CGFloat = 0
    @IBOutlet var addPhotoView: UIButton!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var timeField: UITextField!
    @IBOutlet var sessionDescription: UITextField!
    @IBOutlet var sessDesc: UITextView!
    @IBOutlet var skillsField: AutoToke!
    @IBAction func addPhoto(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    @IBAction func submit(sender: AnyObject) {
        if(sessDesc.text == "") {
            createAlert(self, "Need more Info", "Please provide a description of the problem.")
        } else if (timeField.text == "") {
            createAlert(self, "Need more Info", "Please provide a time for the pin to live.")
        } else {
            let parent = self.parentViewController as? TabSessionCreate
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.backBarButtonItem = nil
            var skillsArr = skillsField.getTokens()
            var base64String:String = ""
            if pickedImage != nil {
                let imageData = UIImagePNGRepresentation(pickedImage)
                base64String = imageData.base64EncodedStringWithOptions(nil)
            }
            parent?.params["description"] = sessDesc.text
            parent?.params["duration"] = datePicker.date.timeIntervalSinceNow
            parent?.params["skills"] = skillsArr
            parent?.params["images"] = base64String != "" ? [base64String] : []
            parent?.submitNewPin()
        }
    }
    
    @IBAction func donePicker(sender: AnyObject) {
        self.view.endEditing(true);
    }
    
    @IBOutlet var cameraIcon: UIImageView!
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        addPhotoView.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        addPhotoView.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        addPhotoView.setImage(image, forState: .Normal)
        addPhotoView.setTitle("", forState: .Normal)
        cameraIcon.hidden = true
        pickedImage = RBSquareImageTo(image, CGSize(width: 100, height: 100))
    }
    
    func hideKeyboard() {
        timeField.resignFirstResponder()
        sessDesc.resignFirstResponder()
        skillsField.textField.resignFirstResponder()
    }
    
    @IBOutlet var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.bounces = false
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        tapGesture.cancelsTouchesInView = false
        self.scrollView.addGestureRecognizer(tapGesture)
        
        tokens = NSMutableArray()
        skillsField.delegate = self
        skillsField.dataSource = self
        skillsField.textField.font = skillsField.textField.font.fontWithSize(15)
        skillsField.textField.attributedPlaceholder =  NSAttributedString(string: "skills needed to solve this", attributes: [NSForegroundColorAttributeName : UIColor(red: 136/255, green: 205/255, blue: 202/255, alpha: 0.7)])
        skillsField.mDelegate = self
        skillsField.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        skillsField.layer.borderWidth = 1.0
        skillsField.layer.cornerRadius = 5.0
        skillsField.clipsToBounds = true
        tokens.addObject("_cameraIcon")
        skillsField.reloadData(false)
        
        addPhotoView.addDashedBorder()
        addPhotoView.contentEdgeInsets = UIEdgeInsetsMake(50, 0, 0, 0)
        
        sessDesc.returnKeyType = .Done
        sessDesc.textContainerInset = UIEdgeInsetsMake(12, 40, 12, 12)
        sessDesc.textColor = teal
        sessDesc.layer.borderColor = nil
        
        let image = UIImageView(image: UIImage(named: "describe-icon.png"))
        image.frame = CGRectMake(10, -38, 28 ,25);
        let position = UIView(frame: CGRectMake(0, 0, 33, 28))
        position.addSubview(image)
        sessionDescription.leftView = position
        sessionDescription.leftViewMode = .Always
        sessionDescription.borderStyle = .RoundedRect
        
        let image2 = UIImageView(image: UIImage(named: "calendar-icon.png"))
        image2.frame = CGRectMake(10, 0, 28 ,25);
        let position2 = UIView(frame: CGRectMake(0, 0, 40, 28))
        position2.addSubview(image2)
        timeField.leftView = position2
        timeField.leftViewMode = .Always
        timeField.attributedPlaceholder =  NSAttributedString(string: "when do you need halp by?", attributes: [NSForegroundColorAttributeName : UIColor(red: 136/255, green: 205/255, blue: 202/255, alpha: 0.7)])
        timeField.borderStyle = .RoundedRect
        timeField.inputView = datePicker
        timeField.inputAccessoryView = toolbar
 
        toolbar.removeFromSuperview()
        datePicker.removeFromSuperview()
        configureDatePicker()
        
        submitButton.backgroundColor = teal
        submitButton.layer.cornerRadius = 12
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = teal.CGColor
        submitButton.clipsToBounds = true
        
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: .ValueChanged)
        timeField.addTarget(self, action: Selector("datePickerInit:"), forControlEvents: .EditingDidBegin)
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
    }
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return "what's the problem?";
    }
    
    func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
        return teal
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        animateViewMoving(true, moveValue: 100)
        textView.text = nil
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        animateViewMoving(false, moveValue: 100)
        if (textView.text == "") {
            textView.text = "Description of the problem you need help with."
        }
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
    
    func tokenFieldDidBeginEditing(tokenField:ZFTokenField) {
        animateViewMoving(true, moveValue: 180)
    }
    
    func tokenFieldDidEndEditing(tokenField:ZFTokenField) {
        animateViewMoving(false, moveValue: 180)
    }
    
    func autoTokeDidEndEditing(textField: AutoToke, withSelection data: Dictionary<String, AnyObject>) {
        
    }
    
    func skillAutoComplete(textfield: AutoToke) -> [Dictionary<String, AnyObject>] {
        return skills
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    var myRows:UInt = 0
    func autoFieldShouldSelect(textField: AutoToke) -> Bool {
        return true
    }
    
    //token field Functions
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 50
    }
    
    func numberOfTokenInField(tokenField: ZFTokenField!) -> UInt {
        return UInt(tokens.count)
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: UInt) -> UIView! {
        if index == 0 {
            let image =  UIImageView(image: UIImage(named: "list-skills-icon.png"))
            image.frame = CGRectMake(10, 10, 28 ,25);
            let position = UIView(frame: CGRectMake(0, 0, 35, 25))
            position.addSubview(image)
            return position
        }
        
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
        return 12
    }
    
    func updateTokenFieldHeight(tokenField: ZFTokenField!, increment:Bool) {
        //        var val = CGFloat(50)
        //        if increment == false {
        //            if myRows > tokenField.height {
        //                myRows = tokenField.height
        //
        //                if tokenHeight.constant - val >= 50 {
        //                    tokenHeight.constant -= val
        //                    contentHeight.constant -= val
        //                }
        //            }
        //        } else {
        //            if myRows < tokenField.height {
        //                myRows = tokenField.height
        //                tokenHeight.constant += val
        //                contentHeight.constant += val
        //            }
        //        }
    }
    
    func tokenFieldShouldEndEditing(textField: ZFTokenField!) -> Bool {
        return true
    }
    
    func tokenDeleteButtonPressed(tokenButton: UIButton) {
        //tokenField.indexOfTokenView(tokenButton.superview) needed?
        var index:Int = Int(skillsField.indexOfTokenView(tokenButton.superview?.superview))
        if index != NSNotFound {
            tokens.removeObjectAtIndex(index)
            skillsField.reloadData(false)
            //updateTokenFieldHeight(tokenField, increment: false)
        }
    }
    //
    //    func scrollToBottom() {
    //        var bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height)
    //        scrollView.setContentOffset(bottomOffset, animated: true)
    //    }
    
    func tokenSelected(textField: AutoToke) {
        //skillsField.addToken(textField.textField)
    }
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        tokens.addObject(text)
        skillsField.reloadData(true)
        //updateTokenFieldHeight(tokenField, increment: true)
        //scrollToBottom()
    }
}