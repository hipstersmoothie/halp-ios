//
//  AddUniversityAndCourses.swift
//  Halp
//
//  Created by Andrew Lisowski on 8/18/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class AddUniversityAndCourses: UIViewController, MPGTextFieldDelegate, ZFTokenFieldDataSource, ZFTokenFieldDelegate, AutoTokeDelegate, UITextFieldDelegate  {
    var tokens:NSMutableArray!
    @IBOutlet var universityField: MPGTextField_Swift!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var coursesListField: AutoToke!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButton(addButton)
        
        styleField(universityField, "school")
        universityField.mDelegate = self
        
        tokens = NSMutableArray()
        coursesListField.mDelegate = self
        coursesListField.delegate = self
        coursesListField.dataSource = self
        coursesListField.textField.font = coursesListField.textField.font.fontWithSize(15)
        coursesListField.textField.attributedPlaceholder =  NSAttributedString(string: "courses", attributes: [NSForegroundColorAttributeName : UIColor(red: 136/255, green: 205/255, blue: 202/255, alpha: 0.7)])
        coursesListField.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        coursesListField.layer.borderWidth = 1.0
        coursesListField.layer.cornerRadius = 5.0
        coursesListField.clipsToBounds = true
        coursesListField.reloadData(false)
        coursesListField.enabled = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: uni and course picker
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        return universities
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>){
        if textField == universityField {
            let uni = data["DisplayText"] as! String
            var params = [
                "university": uni
            ]
            
            halpApi.getCourses(params) { success, json in
                courses = []
                let courseList = json["courses"].arrayValue
                for course in courseList {
                    let courseText = course["subject"].stringValue + " " + course["number"].stringValue
                    courses.append([
                        "DisplayText": courseText,
                        "CustomObject": Course(course: course)
                        ])
                }
            }
            coursesListField.enabled = true
        }
    }
    
    func autoTokeDidEndEditing(textField: AutoToke, withSelection data: Dictionary<String, AnyObject>) {
        
    }
    
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
        return 12
    }
    
    func tokenFieldShouldEndEditing(textField: ZFTokenField!) -> Bool {
        return true
    }
    
    func tokenDeleteButtonPressed(tokenButton: UIButton) {
        var index:Int = Int(coursesListField.indexOfTokenView(tokenButton.superview?.superview))
        if index != NSNotFound {
            tokens.removeObjectAtIndex(index)
            coursesListField.reloadData(false)
        }
    }

    func tokenSelected(textField: AutoToke) {
        
    }
    
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        tokens.addObject(text)
        coursesListField.reloadData(true)
    }
    
    func autoFieldShouldSelect(textField: AutoToke) -> Bool {
        return true
    }
    
    func skillAutoComplete(textfield: AutoToke) -> [Dictionary<String, AnyObject>] {
        return courses
    }
}
