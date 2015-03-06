//
//  TutorSetupCourses.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class TutorSetupCourses: UITableViewController, MPGTextFieldDelegate, AutoTokeDelegate, ZFTokenFieldDataSource, ZFTokenFieldDelegate {
    var courseRow = 1
    let halpApi = HalpAPI()
    var tokens:NSMutableArray!
    var selectedRow = -1
    
    @IBAction func addAnother(sender: AnyObject) {
        courseRow++;
        selectedRow = -1
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let next = UIBarButtonItem(title: "Next", style: .Bordered, target: self, action: "nextScreen")
        self.navigationItem.rightBarButtonItem = next
        
        tokens = NSMutableArray()
    }
    
    @IBOutlet var table: UITableView!
    func nextScreen() {
        var courses = Dictionary<String,[Dictionary<String, String>]>()
        let cells = table.visibleCells()
        
//        for cell in cells {
//            if let uniCell = cell as? experienceCell {
//                if uniCell.university.text == "" {
//                    return createAlert(self, "Error!", "Please provide at least one university.")
//                } else if uniCell.courseList.text == "" {
//                    return createAlert(self, "Error!", "Please provide at least one course.")
//                } else {
//                    let uni = uniCell.university.text
//                    let coursesText = split(uniCell.courseList.text) {$0 == ","}
//                    var courseArr:[Dictionary<String, String>] = []
//                    
//                    for course in coursesText {
//                        let nameNum = split(course) {$0 == " "}
//                        courseArr.append([
//                            "subject" : nameNum[0],
//                            "number" : nameNum[1]
//                            ])
//                    }
//                    
//                    courses.updateValue(courseArr, forKey: uni)
//                }
//            }
//        }
//        setUpTutorParams.updateValue(courses, forKey: "courses")
//        println(setUpTutorParams)
        self.performSegueWithIdentifier("toSetRate", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Functions
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + courseRow
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 || indexPath.row < courseRow {
            var expCell = self.tableView.dequeueReusableCellWithIdentifier("uniAndCourse") as experienceCell
            
            expCell.selectionStyle = .None
            expCell.university.mDelegate = self
            expCell.courseList.delegate = self
            expCell.courseList.dataSource = self
            expCell.courseList.textField.placeholder = "CPE 101, Physics 141, etc."
            
            expCell.courseList.mDelegate = self
            expCell.row = indexPath.row
            if expCell.university.text == "" {
                expCell.courseList.enabled = false
            }
            
            if selectedRow == indexPath.row {
                expCell.courseList.reloadData(true)
            } else {
                expCell.courseList.reloadData(false)
            }

            return expCell
        } else {
            var addUni = self.tableView.dequeueReusableCellWithIdentifier("addAnother") as UITableViewCell
            
            addUni.selectionStyle = .None

            return addUni
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Classes I want to Tutor"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == selectedRow {
            return 400
        } else if indexPath.row == 0 || indexPath.row < courseRow {
            return 139
        } else {
            return 66
        }
    }

    // Uni AutoComplete
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        return universities
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>){
        let uni = data["DisplayText"] as String
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
            let cell = textField.superview?.superview as experienceCell
            cell.courseList.enabled = true
        }
    }

    // Course list Autocomplete Tokenizer
    func tokenFieldDidBeginEditing(tokenField: ZFTokenField!) {
        
        //this will be diff in diff ios ver
        let cell = tokenField.superview?.superview as experienceCell
        if selectedRow != cell.row {
            selectedRow = cell.row
            table.reloadData()
            tokenField.textField.becomeFirstResponder()
        }
    }
    
    func tokenSelected(textField: AutoToke) {
        
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
        var view: UIView = nibContents[0] as UIView
        var label:UILabel = view.viewWithTag(2) as UILabel
        var button:UIButton = view.viewWithTag(3) as UIButton
        
        button.addTarget(self, action: Selector("tokenDeleteButtonPressed:"), forControlEvents: .TouchUpInside)
        
        label.text = tokens[Int(index)] as NSString;
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
        let cells = table.visibleCells()
        
        for cell in cells {
            if let uniCell = cell as? experienceCell {
                uniCell.courseList.indexOfTokenView(tokenButton.superview)
                var index:Int = Int(uniCell.courseList.indexOfTokenView(tokenButton.superview))
                
                if index != NSNotFound {
                    tokens.removeObjectAtIndex(index)
                    uniCell.courseList.reloadData(false)
                    break
                }
            }
        }
    }
    
    func tokenMarginInTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 10
    }
    
    func skillAutoComplete(textfield: AutoToke) -> [Dictionary<String, AnyObject>] {
        println("yayaya")
        return courses
    }
    
    func textFieldShouldSelect(textField: AutoToke) -> Bool {
        return true
    }
}
