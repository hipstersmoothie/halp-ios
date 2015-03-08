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
    var selectedRow = -1
    var cellInfos:[Dictionary<String, AnyObject>]!
    
    @IBAction func addAnother(sender: AnyObject) {
        courseRow++;
        cellInfos.append([
            "height": 139,
            "tokens": NSMutableArray(),
            "tokenHeight": 0,
            "school": "",
            "courses": []
        ])
        selectedRow = -1
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let next = UIBarButtonItem(title: "Next", style: .Bordered, target: self, action: "nextScreen")
        self.navigationItem.rightBarButtonItem = next
        
        cellInfos = []
        cellInfos.append([
            "height": 139,
            "tokens": NSMutableArray(),
            "tokenHeight": 0,
            "school": "",
            "courses": []
        ])
    }
    
    @IBOutlet var table: UITableView!
    func nextScreen() {
        var courses = Dictionary<String,[Dictionary<String, String>]>()
        for info in cellInfos {
            let school = info["school"] as String
            let courseArr = info["tokens"] as NSMutableArray
    
            if school == "" {
                return createAlert(self, "Error!", "Please provide at least one university.")
            } else if courseArr.count == 0 {
                return createAlert(self, "Error!", "Please provide at least one course.")
            } else {
                var interpCourses:[Dictionary<String, String>] = []
                for course in courseArr {
                    let nameNum = split(course as String) {$0 == " "}
                    if nameNum.count < 2 {
                        return createAlert(self, "Error!", "Please format classes correctly (eg CPE 101, not CPE101).")
                    }
                    interpCourses.append([
                        "subject": nameNum[0],
                        "number": nameNum[1]
                    ])
                }
                
                courses.updateValue(interpCourses, forKey: school)
            }
        }

        setUpTutorParams.updateValue(courses, forKey: "courses")
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
            expCell.indexPath = indexPath
            if expCell.university.text == "" {
                expCell.courseList.enabled = false
            }
            
            if selectedRow == indexPath.row {
                expCell.courseList.reloadData(true)
            } else {
                expCell.courseList.reloadData(false)
            }
            
            let school = cellInfos[indexPath.row]["school"] as String
            if school != "" {
                expCell.university.text = school
                expCell.courseList.enabled = true
            } else {
                expCell.university.text = ""
                expCell.courseList.enabled = false
            }
            
            let height = cellInfos[indexPath.row]["tokenHeight"] as CGFloat
            for constraint in expCell.courseList.constraints() {
                let tokenHeight = constraint as NSLayoutConstraint
                if tokenHeight.firstAttribute == .Height {
                    expCell.courseList.removeConstraint(tokenHeight)
                    tokenHeight.constant = height + 50
                    expCell.courseList.addConstraint(tokenHeight)
                }
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
        if indexPath.row == 0 || indexPath.row < courseRow {
            let height = cellInfos[indexPath.row]["height"] as CGFloat
            let tokenHeight = cellInfos[indexPath.row]["tokenHeight"] as CGFloat
            if selectedRow == indexPath.row {
                return height + tokenHeight + 225 
            }
            return height + tokenHeight
        } else {
            return 66
        }
    }

    // Uni AutoComplete
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        var selectedSchools:[Dictionary<String, AnyObject>] = []
        for info in cellInfos {
            let title = info["school"] as String
            if title != "" {
                selectedSchools.append([
                    "DisplayText": title,
                    "CustomObject": []
                ])
            }
        }
        var all = NSMutableArray(array: universities)
        all.removeObjectsInArray(selectedSchools)
        return all as AnyObject as [Dictionary<String, AnyObject>]
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>){
        
        let uni = data["DisplayText"] as String
        let cell = textField.superview?.superview as experienceCell
        var params = [
            "university": uni
        ]
        
        cellInfos[cell.indexPath.row].updateValue(uni, forKey: "school")
        halpApi.getCourses(params) { success, json in
            var courses:[Dictionary<String, AnyObject>] = []
            let courseList = json["courses"].arrayValue
            for course in courseList {
                let courseText = course["subject"].stringValue + " " + course["number"].stringValue
                courses.append([
                    "DisplayText": courseText,
                    "CustomObject": Course(course: course)
                ])
            }
            if let cell = textField.superview?.superview as? experienceCell {
                cell.courseList.enabled = true
                self.cellInfos[cell.indexPath.row].updateValue(courses, forKey: "courses")
            }
        }
    }

    // Course list Autocomplete Tokenizer
    func tokenFieldDidBeginEditing(tokenField: ZFTokenField!) {
        //this will be diff in diff ios ver
        let cell = tokenField.superview?.superview as experienceCell
        if selectedRow != cell.indexPath.row {
            selectedRow = cell.indexPath.row
            table.reloadRowsAtIndexPaths([cell.indexPath], withRowAnimation: .None)
        }
    }
    
    func tokenSelected(textField: AutoToke) {
        updateTokenFieldHeight(textField, increment: true)
    }
    
    func tokenFieldShouldEndEditing(textField: ZFTokenField!) -> Bool {
        return true
    }
    
    func numberOfTokenInField(tokenField: ZFTokenField!) -> UInt {
        if let cell = tokenField.superview?.superview as? experienceCell {
            var tokens = cellInfos[cell.indexPath.row]["tokens"] as NSMutableArray
            return UInt(tokens.count)
        }
        return 0
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: UInt) -> UIView! {
        var nibContents = NSBundle.mainBundle().loadNibNamed("TokenView", owner: nil, options: nil)
        var view: UIView = nibContents[0] as UIView
        var label:UILabel = view.viewWithTag(2) as UILabel
        var button:UIButton = view.viewWithTag(3) as UIButton
        
        button.addTarget(self, action: Selector("tokenDeleteButtonPressed:"), forControlEvents: .TouchUpInside)
        
        if let cell = tokenField.superview?.superview as? experienceCell {
            var tokens = cellInfos[cell.indexPath.row]["tokens"] as NSMutableArray
            label.text = tokens[Int(index)] as NSString;
        }
        
        var size:CGSize = label.sizeThatFits(CGSizeMake(1000, 40))
        view.frame = CGRectMake(0, 0, size.width + 50, 40)
        return view
    }
    
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 40
    }
    
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        if let cell = tokenField.superview?.superview as? experienceCell {
            var tokens = cellInfos[cell.indexPath.row]["tokens"] as NSMutableArray
            tokens.addObject(text)
            cellInfos[cell.indexPath.row].updateValue(tokens, forKey: "tokens")
            tokenField.reloadData(true)
            updateTokenFieldHeight(tokenField, increment: true)
            table.reloadRowsAtIndexPaths([cell.indexPath], withRowAnimation: .None)
            if let focus = table.cellForRowAtIndexPath(cell.indexPath) as? experienceCell {
                focus.courseList.textField.becomeFirstResponder()
            }
        }
    }
    
    func tokenDeleteButtonPressed(tokenButton: UIButton) {
        let cells = table.visibleCells()
        
        for cell in cells {
            if let uniCell = cell as? experienceCell {
                var index:Int = Int(uniCell.courseList.indexOfTokenView(tokenButton.superview))
                
                if index != NSNotFound {
                    var tokens = cellInfos[uniCell.indexPath.row]["tokens"] as NSMutableArray
                    tokens.removeObjectAtIndex(index)
                    cellInfos[uniCell.indexPath.row].updateValue(tokens, forKey: "tokens")
                    uniCell.courseList.reloadData(false)
                    updateTokenFieldHeight(uniCell.courseList, increment: false)
                    table.reloadData()
                    break
                }
            }
        }
    }
    
    func tokenMarginInTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 10
    }
    
    func skillAutoComplete(textfield: AutoToke) -> [Dictionary<String, AnyObject>] {
        if let cell = textfield.superview?.superview as? experienceCell {
            return cellInfos[cell.indexPath.row]["courses"] as [Dictionary<String, AnyObject>]
        }
        return [Dictionary<String, AnyObject>()]
    }
    
    func textFieldShouldSelect(textField: AutoToke) -> Bool {
        return true
    }
    
    func updateTokenFieldHeight(tokenField: ZFTokenField!, increment:Bool) {
        let val = CGFloat(50)
        if let cell = tokenField.superview?.superview as? experienceCell {
            var tokenFieldHeight = cellInfos[cell.indexPath.row]["tokenHeight"] as UInt
            
            if increment == false {
                if tokenFieldHeight > tokenField.height {
                    cellInfos[cell.indexPath.row].updateValue(tokenField.height, forKey: "tokenHeight")
                }
            } else {
                if tokenFieldHeight < tokenField.height {
                    cellInfos[cell.indexPath.row].updateValue(tokenField.height, forKey: "tokenHeight")
                }
            }
        }
    }
}
