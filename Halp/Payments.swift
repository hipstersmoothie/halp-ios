//
//  Payments.swift
//  Halp
//
//  Created by Andrew Lisowski on 5/6/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

var brainTreeClientToken:String!
class Payments: UITableViewController {
    var braintree:Braintree!
    var nonce:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Payment Methods"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: Selector("addPaymentMethod"))
        
        halpApi.getClientToken() { success, json in
            if success  {
                brainTreeClientToken = json["clientToken"].stringValue
//                self.braintree = Braintree(clientToken: json["clientToken"].stringValue)
            } else {
                println(json)
            }
        }
    }
    
    func addPaymentMethod() {
        self.performSegueWithIdentifier("toAddPaymentMethod", sender: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    func postNonceToServer(paymentMethodNonce:NSString) {
//        // Send payment method nonce to your server !!!needed!!!
//    }
//    
//    func dropInViewController(viewController: BTDropInViewController!, didSucceedWithPaymentMethod paymentMethod: BTPaymentMethod!) {
//        self.nonce = paymentMethod.nonce
//        postNonceToServer(self.nonce)
//        println("here")
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func dropInViewControllerDidCancel(viewController: BTDropInViewController!) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//        println("dismissed")
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(PaymentTypeCell), forIndexPath: indexPath) as! PaymentTypeCell
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
}
