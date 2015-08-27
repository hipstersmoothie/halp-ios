//
//  MerchantDetails.swift
//  Halp
//
//  Created by Andrew Lisowski on 6/9/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class MerchantDetails: UIViewController {
    var setUpTutorParams:Dictionary<String, AnyObject>!
 
    @IBOutlet var email: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var dateOfBirth: UITextField!
    @IBOutlet var ssn: UITextField!
    @IBOutlet var address: UITextField!
    @IBOutlet var state: UITextField!
    @IBOutlet var city: UITextField!
    @IBOutlet var zip: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let next = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "nextScreen")
        self.navigationItem.rightBarButtonItem = next
        
        styleField(email, "email")
        styleField(phone, "phone")
        styleField(dateOfBirth, "date of birth")
        styleField(ssn, "social security number")
        styleField(address, "address")
        styleField(city, "city")
        styleField(zip, "zip")
        styleField(state, "state")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! BankingDetails
        vc.setUpTutorParams = setUpTutorParams
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func nextScreen() {
        if email.text == "" {
            createAlert(self, "Please provide all fields", "Email missing.")
        } else if phone.text == "" {
            createAlert(self, "Please provide all fields", "Phone missing.")
        } else if dateOfBirth.text == "" {
            createAlert(self, "Please provide all fields", "Birthday missing.")
        } else if ssn.text == "" {
            createAlert(self, "Please provide all fields", "SSN missing.")
        } else if address.text == "" {
            createAlert(self, "Please provide all fields", "Address missing.")
        } else if city.text == "" {
            createAlert(self, "Please provide all fields", "City missing.")
        } else if state.text == "" {
            createAlert(self, "Please provide all fields", "State missing.")
        } else if zip.text == "" {
            createAlert(self, "Please provide all fields", "ZIP missing.")
        } else {
            let merchant = [
                "email" : email.text,
                "phone" : phone.text,
                "dateOfBirth" : dateOfBirth.text,
                "ssn" : ssn.text,
                "address" : [
                    "streetAddress": address.text,
                    "locality": city.text,
                    "region": state.text,
                    "postalCode": zip.text
                ]
            ]
            setUpTutorParams?.updateValue(merchant, forKey: "merchant")
            self.performSegueWithIdentifier("toBankDetails", sender: self)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField != email && textField != phone {
            animateViewMoving(true, moveValue: 100)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField != email && textField != phone {
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
}
