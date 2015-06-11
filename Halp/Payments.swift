//
//  Payments.swift
//  Halp
//
//  Created by Andrew Lisowski on 5/6/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class paymentMethod {
    var type:String
    var details:Dictionary<String, AnyObject>
    
    init(type:String, details:Dictionary<String, AnyObject>) {
        self.type = type
        self.details = details
    }
}

var brainTreeClientToken:String!
class Payments: UITableViewController {
    var braintree:Braintree!
    var nonce:String!
    var paymentMethods:[paymentMethod] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Payment Methods"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: Selector("addPaymentMethod"))
        self.tableView.allowsSelection = false
        halpApi.getClientToken() { success, json in
            if success  {
                brainTreeClientToken = json["clientToken"].stringValue
            } else {
                println(json)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        halpApi.getPaymentMethods() { success, json in
            if success && self.paymentMethods.count != json["customer"]["paymentMethods"].count  {
                self.paymentMethods = []
                for method in json["customer"]["paymentMethods"] {
                    println(method)
                    self.paymentMethods.append(paymentMethod(type: method.1["type"].stringValue, details: method.1.dictionaryObject!))
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func addPaymentMethod() {
        self.performSegueWithIdentifier("toAddPaymentMethod", sender: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods.count
    }
    
    func deleteMethod(success:Bool, json:JSON) {
        
    }
    
    func deleteIt(token:AnyObject, indexPath:NSIndexPath) {
        println(token, token.stringValue)
        halpApi.deletePaymentMethod(token as! String) {success, json in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.paymentMethods.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let alertController = UIAlertController(title: "Are you sure you want to delete this payment method?", message: "You will no longer be able to use this to pay.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Delete", style: .Default) { action in
                let token: AnyObject? = self.paymentMethods[indexPath.row].details["token"]
                self.deleteIt(token!, indexPath: indexPath)
               // self.deleteIt(self.paymentMethods[indexPath.row].details["token"])
               // halpApi.deletePaymentMethod(self.paymentMethods[indexPath.row].details["token"], self.deleteMethod)
//                halpApi.deletePin(self.afterDeletePin)
//                self.removeMyPin()
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) { }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentMethod = paymentMethods[indexPath.row]
        
        if currentMethod.type == "PayPal" {
            let cell = tableView.dequeueReusableCellWithIdentifier("PaypalCell") as! PaymentTypeCell
            
            let email: AnyObject? = currentMethod.details["email"]
            cell.payPalEmail.text = "\(email!)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CreditCardCell") as! CreditCardCell

            let type: AnyObject? = currentMethod.details["cardType"]
            cell.cardType.text = "\(type!)"
            let last: AnyObject? = currentMethod.details["last4"]
            cell.last4.text = "**** **** **** \(last!)"
            let month: AnyObject? = currentMethod.details["expirationMonth"]
            let year: AnyObject? = currentMethod.details["expirationYear"]
            cell.expiration.text = "\(month!)/\(year!)"
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
}
