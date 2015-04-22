//
//  BioAndSkillsController.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

var setUpTutorParams = Dictionary<String, AnyObject>()

class BioAndSkillsController: UIViewController, ZFTokenFieldDataSource,  ZFTokenFieldDelegate, AutoTokeDelegate, UITextViewDelegate, UITextFieldDelegate {
    var tokens:NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let next = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "nextScreen")
        self.navigationItem.rightBarButtonItem = next
        
        tokens = NSMutableArray()
        skillsField.delegate = self
        skillsField.dataSource = self
        skillsField.textField.placeholder = "Excel, Coding, Massage"
        skillsField.reloadData(false)
        skillsField.mDelegate = self
    }
    
    func tokenSelected(textField: AutoToke) {
        
    }
    
    @IBOutlet var bio: UITextView!
    @IBOutlet var skillsField: AutoToke!
    func nextScreen() {
        if bio.text == "" || bio.text == "Write a bio about yourself. This helps student get to know you before you meet." {
            createAlert(self, "Error!", "Provide a bio.")
        } else if skillsField.numberOfToken() == 0 {
            createAlert(self, "Error!", "Provide some skills.")
        } else {
            setUpTutorParams.updateValue(bio.text, forKey: "bio")
            var skillsArr = skillsField.getTokens()
            setUpTutorParams.updateValue(skillsArr, forKey: "skills")
            
            self.performSegueWithIdentifier("toAddClasses", sender: self)
        }
    }
    
    func tokenField(tokenField: ZFTokenField!, didRemoveTokenAtIndex index: UInt) {
        tokens.removeObjectAtIndex(Int(index))
    }
    
    func tokenFieldShouldEndEditing(textField: ZFTokenField!) -> Bool {
        return true
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
        
        label.text = tokens[Int(index)] as! NSString as String;
        var size:CGSize = label.sizeThatFits(CGSizeMake(1000, 40))
        view.frame = CGRectMake(0, 0, size.width + 50, 40);
        return view;
    }
    
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 40
    }
    
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        tokens.addObject(text)
        tokenField.reloadData(true)
    }
    
    func tokenDeleteButtonPressed(tokenButton: UIButton) {
        skillsField.indexOfTokenView(tokenButton.superview)
        var index:Int = Int(skillsField.indexOfTokenView(tokenButton.superview))
        
        if index != NSNotFound {
            tokens.removeObjectAtIndex(index)
            skillsField.reloadData(false)
        }
    }
    
    func tokenMarginInTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 10
    }
    
    func skillAutoComplete(textfield: AutoToke) -> [Dictionary<String, AnyObject>] {
        return skills
    }
    
    func autoFieldShouldSelect(textField: AutoToke) -> Bool {
        return true
    }
    
    func autoTokeDidEndEditing(textField: AutoToke, withSelection data: Dictionary<String, AnyObject>) {
        
    }
    
    func textFieldShouldSelect(textField: AutoToke) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        animateViewMoving(true, moveValue: 100)
        textView.text = nil
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        animateViewMoving(false, moveValue: 100)
        if textView.text == "" {
            textView.text = "Write a bio about yourself. This helps student get to know you before you meet."
        }
    }
        
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }

    func tokenFieldDidBeginEditing(tokenField:ZFTokenField) {
        animateViewMoving(true, moveValue: 180)
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
}
