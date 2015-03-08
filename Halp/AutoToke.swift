//
//  AutoToke.swift
//  Halp
//
//  Created by Andrew Lisowski on 3/2/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

@objc protocol AutoTokeDelegate{
    func skillAutoComplete(textfield: AutoToke) -> [Dictionary<String, AnyObject>]
    
    optional func autoTokeDidEndEditing(textField: AutoToke, withSelection data: Dictionary<String,AnyObject>)
    optional func textFieldShouldSelect(textField: AutoToke) -> Bool
    optional func tokenSelected(textField: AutoToke)
}

class AutoToke: ZFTokenField, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    var mDelegate : AutoTokeDelegate?
    var tableViewController : UITableViewController?
    var data = [Dictionary<String, AnyObject>]()
    
    //Set this to override the default color of suggestions popover. The default color is [UIColor colorWithWhite:0.8 alpha:0.9]
    @IBInspectable var popoverBackgroundColor : UIColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    
    //Set this to override the default frame of the suggestions popover that will contain the suggestions pertaining to the search query. The default frame will be of the same width as textfield, of height 200px and be just below the textfield.
    @IBInspectable var popoverSize : CGRect?
    
    //Set this to override the default seperator color for tableView in search results. The default color is light gray.
    @IBInspectable var seperatorColor : UIColor = UIColor(white: 0.95, alpha: 1.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        runAutoComplete()
    }
    
    func runAutoComplete() {
        let str : String = self.textField.text
        if (countElements(str) > 0) && (self.isFirstResponder())
        {
            if (mDelegate != nil){
                data = mDelegate!.skillAutoComplete(self)
                self.provideSuggestions()
            }
            else{
                println("<MPGTextField> WARNING: You have not implemented the requred methods of the MPGTextField protocol.")
            }
        }
        else{
            if let table = self.tableViewController{
                if table.tableView.superview != nil{
                    table.tableView.removeFromSuperview()
                    self.tableViewController = nil
                }
            }
        }
    }
    
    override func textFieldDidChange(textField: ZFTokenTextField!) {
        if (mDelegate != nil){
            data = mDelegate!.skillAutoComplete(self)
            self.provideSuggestions()
        }
    }
    
    override func resignFirstResponder() -> Bool{
        if tableViewController != nil {
            UIView.animateWithDuration(0.3,
                animations: ({
                    self.tableViewController!.tableView.alpha = 0.0
                }),
                completion:{
                    (finished : Bool) in
                    self.tableViewController!.tableView.removeFromSuperview()
                    self.tableViewController = nil
            })
            
        }
        self.handleExit()
        return super.resignFirstResponder()
    }
    
    func provideSuggestions(){
        if let tvc = self.tableViewController {
            tableViewController!.tableView.reloadData()
        }
        else if self.applyFilterWithSearchQuery(self.textField.text).count > 0{
            //Add a tap gesture recogniser to dismiss the suggestions view when the user taps outside the suggestions view
            let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.cancelsTouchesInView = false
            tapRecognizer.delegate = self
            self.superview?.addGestureRecognizer(tapRecognizer)
            
            self.tableViewController = UITableViewController.alloc()
            self.tableViewController!.tableView.delegate = self
            self.tableViewController!.tableView.dataSource = self
            self.tableViewController!.tableView.backgroundColor = self.popoverBackgroundColor
            self.tableViewController!.tableView.separatorColor = self.seperatorColor
            if let frameSize = self.popoverSize{
                self.tableViewController!.tableView.frame = frameSize
            }
            else{
                //PopoverSize frame has not been set. Use default parameters instead.
                var frameForPresentation = self.frame
                frameForPresentation.origin.y += self.frame.size.height
                frameForPresentation.size.height = 200
                self.tableViewController!.tableView.frame = frameForPresentation
            }
            
            var frameForPresentation = self.frame
            frameForPresentation.origin.y += self.frame.size.height;
            frameForPresentation.size.height = 200;
            tableViewController!.tableView.frame = frameForPresentation
            
            self.superview?.addSubview(tableViewController!.tableView)
            self.tableViewController!.tableView.alpha = 0.0
            UIView.animateWithDuration(0.3,
                animations: ({
                    self.tableViewController!.tableView.alpha = 1.0
                }),
                completion:{
                    (finished : Bool) in
                    
            })
        }
        
    }
    
    func tapped (sender : UIGestureRecognizer!){
        if let table = self.tableViewController{
            if !CGRectContainsPoint(table.tableView.frame, sender.locationInView(self.superview)) && self.isFirstResponder(){
                self.resignFirstResponder()
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = self.applyFilterWithSearchQuery(self.textField.text).count
        if count == 0{
            UIView.animateWithDuration(0.3,
                animations: ({
                    self.tableViewController!.tableView.alpha = 0.0
                }),
                completion:{
                    (finished : Bool) in
                    if let table = self.tableViewController{
                        table.tableView.removeFromSuperview()
                        self.tableViewController = nil
                    }
            })
        }
        
        var frameForPresentation = self.frame
        frameForPresentation.origin.y += self.frame.size.height;
        if (count == 1) {
            frameForPresentation.size.height = 45;
        } else if (count == 2) {
            frameForPresentation.size.height = 90;
        } else if (count == 3) {
            frameForPresentation.size.height = 135;
        } else {
            frameForPresentation.size.height = 180;
        }
        tableViewController?.tableView.frame = frameForPresentation
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MPGResultsCell") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MPGResultsCell")
        }
        
        cell!.backgroundColor = UIColor.clearColor()
        let dataForRowAtIndexPath = self.applyFilterWithSearchQuery(self.textField.text)[indexPath.row]
        let displayText : AnyObject? = dataForRowAtIndexPath["DisplayText"]
        let displaySubText : AnyObject? = dataForRowAtIndexPath["DisplaySubText"]
        cell!.textLabel?.text = displayText as? String
        cell!.detailTextLabel?.text = displaySubText as? String
        
        return cell!
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        self.textField.text = self.applyFilterWithSearchQuery(self.textField.text)[indexPath.row]["DisplayText"] as String
        
        self.textFieldShouldReturn(self.textField)
        mDelegate?.tokenSelected!(self)
        self.resignFirstResponder()
    }
    
    //   #pragma mark Filter Method
    
    func applyFilterWithSearchQuery(filter : String) -> [Dictionary<String, AnyObject>]
    {
        //let predicate = NSPredicate(format: "DisplayText BEGINSWITH[cd] \(filter)")
        var lower = (filter as NSString).lowercaseString
        var filteredData = data.filter({
            if let match : AnyObject  = $0["DisplayText"]{
                return (match as NSString).lowercaseString.hasPrefix(lower)
            }
            else {
                return false
            }
        })
        return filteredData
    }
    
    func handleExit(){
        if let table = self.tableViewController{
            table.tableView.removeFromSuperview()
        }
        if (mDelegate?.textFieldShouldSelect?(self) != nil){
            if self.applyFilterWithSearchQuery(self.textField.text).count > 0 {
                let selectedData = self.applyFilterWithSearchQuery(self.textField.text)[0]
                let displayText : AnyObject? = selectedData["DisplayText"]
                self.textField.text = displayText as String
                mDelegate?.autoTokeDidEndEditing?(self, withSelection: selectedData)
                mDelegate?.tokenSelected!(self)
            }
            else{
                mDelegate?.autoTokeDidEndEditing?(self, withSelection: ["DisplayText":self.textField.text, "CustomObject":"NEW"])
            }
        }
        
    }
    
    func getTokens() -> [String] {
        var tokens:[String] = []
        for token in tokenViews {
            if let label:UILabel = token.viewWithTag(2) as? UILabel {
                tokens.append(label.text!)
            }
        }
        
        return tokens
    }
}
