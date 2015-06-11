//
//  BankingDetails.swift
//  Halp
//
//  Created by Andrew Lisowski on 6/9/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class BankingDetails: UIViewController {
    @IBOutlet var acctNumber: UITextField!
    @IBOutlet var routingNumber: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var phone: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let next = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "nextScreen")
        self.navigationItem.rightBarButtonItem = next
        
        styleField(acctNumber)
        styleField(routingNumber)
        styleField(email)
        styleField(phone)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func nextScreen() {
        if acctNumber.text == "" && routingNumber.text == "" && email.text == "" && phone == "" {
            createAlert(self, "Problem getting banking iformation", "Need at least one destination")
        }
        
        if email.text != "" {
            setUpTutorParams.updateValue([
                "destination": "email",
                "email": email.text,
            ], forKey: "funding")
            self.performSegueWithIdentifier("toSetRate", sender: nil)
        }
        
        if phone.text != "" {
            setUpTutorParams.updateValue([
                "destination": "mobile phone",
                "mobilePhone": phone.text,
                ], forKey: "funding")
            self.performSegueWithIdentifier("toSetRate", sender: nil)
        }
        
        if acctNumber.text != "" && routingNumber.text != "" {
            setUpTutorParams.updateValue([
                "destination": "bank",
                "accountNumber": acctNumber.text,
                "routingNumber": routingNumber.text,
            ], forKey: "funding")
            println(setUpTutorParams)
            self.performSegueWithIdentifier("toSetRate", sender: nil)
        }
    }
}
