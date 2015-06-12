//
//  AddPaymentMethod.swift
//  Halp
//
//  Created by Andrew Lisowski on 6/2/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class AddPaymentMethod: UIViewController, BTUICardFormViewDelegate, BTPaymentMethodCreationDelegate, CardIOPaymentViewControllerDelegate  {
    var brainTree:Braintree!
    @IBOutlet var paymentButton: BTPaymentButton!
    @IBOutlet var cardFormView: BTUICardFormView!
    @IBOutlet var emailLabel: UILabel!
    var nonce:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save", style: .Plain, target: self, action: Selector("savePaymentMethod"))
        
        brainTree = Braintree(clientToken: brainTreeClientToken)
        cardFormView.optionalFields = nil
        let payPalVenmo = brainTree.paymentButtonWithDelegate(self)
        payPalVenmo.frame = CGRectMake(0, 0, paymentButton.frame.width, paymentButton.frame.height)
        payPalVenmo.center = paymentButton.center
        self.view.addSubview(payPalVenmo)
    }
    
    func savePaymentMethod() {
        if(emailLabel.text == "" && (cardFormView.number == "" || cardFormView.expirationYear == nil)) {
            return createAlert(self, "Provide a Payment Method", "Please fill in a credit card or a paypal account")
        }
        
        pause(self.view)
        if(emailLabel.text != "") {
            return halpApi.createPaymentMethod(nonce, completionHandler: paymentMethodCreated)
        }
       
        var request = BTClientCardRequest()
        request.number = cardFormView.number
        request.expirationYear = cardFormView.expirationYear
        request.expirationMonth = cardFormView.expirationMonth
        
        brainTree.tokenizeCard(request) { nonce, error in
            if nonce != nil {
                halpApi.createPaymentMethod(nonce, completionHandler: self.paymentMethodCreated)
            }
        }
    }
    
    func paymentMethodCreated(success:Bool, json:JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            start(self.view)
            if success {
                self.performSegueWithIdentifier("toPayments", sender: nil)
            } else {
                println(json)
                createAlert(self, "Trouble adding payment method", "Check that all the information provided is correct")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Add Payment Method"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // BTUICardFormViewDelegate
    func cardFormViewDidChange(cardFormView: BTUICardFormView!) {
        if cardFormView.valid {
            
        } else {
            //createAlert(self, "Card Invalid", "Something is wrong with your card.")
        }
    }
    
    //BTPaymentMethodCreationDelegate
    func paymentMethodCreator(sender: AnyObject!, requestsPresentationOfViewController viewController: UIViewController!) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func paymentMethodCreator(sender: AnyObject!, requestsDismissalOfViewController viewController: UIViewController!) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func paymentMethodCreator(sender: AnyObject!, didFailWithError error: NSError!) {
        println(error)
    }
    func paymentMethodCreator(sender: AnyObject!, didCreatePaymentMethod paymentMethod: BTPaymentMethod!) {
        nonce = paymentMethod.nonce
        emailLabel.text = "\(paymentMethod)"
    }
    
    func paymentMethodCreatorWillPerformAppSwitch(sender: AnyObject!) {
        
    }
    
    func paymentMethodCreatorWillProcess(sender: AnyObject!) {
        
    }

    func paymentMethodCreatorDidCancel(sender: AnyObject!) {
        
    }
    
    //CardIOPaymentViewControllerDelegate
    @IBOutlet var scanCardButton: UIButton!
    @IBAction func scanCardAction(sender: AnyObject) {
        if !CardIOUtilities.canReadCardWithCamera() {
            createAlert(self, "Camera Unavailable", "Enter card manually")
            scanCardButton.hidden = true
        } else {
            var cardController = CardIOPaymentViewController(paymentDelegate: self)
            self.presentViewController(cardController, animated: true, completion: nil)
        }
    }
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
        addCardFormWithInfo(cardInfo)
    }
    
    func addCardFormWithInfo(info: CardIOCreditCardInfo) {
        if(info.cardNumber != nil) {
            cardFormView.number = info.cardNumber
            
            var dateComponents = NSDateComponents()
            dateComponents.month = Int(info.expiryMonth);
            dateComponents.year = Int(info.expiryYear);
            dateComponents.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
            
            cardFormView.setExpirationDate(dateComponents.date)
//            cardFormView.cvv = info.cvv
//            cardFormView.postalCode = info.postalCode
        }
    }
}
