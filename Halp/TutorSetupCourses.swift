//
//  TutorSetupCourses.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class TutorSetupCourses: UITableViewController {
    var courseRow = 1
    
    @IBAction func addAnother(sender: AnyObject) {
        courseRow++;
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let next = UIBarButtonItem(title: "Next", style: .Bordered, target: self, action: "nextScreen")
        self.navigationItem.rightBarButtonItem = next
    }
    
    @IBOutlet var table: UITableView!
    func nextScreen() {
        var courses = Dictionary<String,[Dictionary<String, String>]>()
        let cells = table.visibleCells()
        
        for cell in cells {
            if let uniCell = cell as? experienceCell {
                if uniCell.university.text == "" {
                    return createAlert(self, "Error!", "Please provide at least one university.")
                } else if uniCell.courseList.text == "" {
                    return createAlert(self, "Error!", "Please provide at least one course.")
                } else {
                    let uni = uniCell.university.text
                    let coursesText = split(uniCell.courseList.text) {$0 == ","}
                    var courseArr:[Dictionary<String, String>] = []
                    
                    for course in coursesText {
                        let nameNum = split(course) {$0 == " "}
                        courseArr.append([
                            "subject" : nameNum[0],
                            "number" : nameNum[1]
                            ])
                    }
                    
                    courses.updateValue(courseArr, forKey: uni)
                }
            }
        }
        setUpTutorParams.updateValue(courses, forKey: "courses")
        println(setUpTutorParams)
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
            return 117
        } else {
            return 66
        }
    }

}
