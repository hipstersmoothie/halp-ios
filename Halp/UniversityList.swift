//
//  UniversityList.swift
//  Halp
//
//  Created by Andrew Lisowski on 8/17/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class UniversityList: UITableViewController {
    var coursesInfo = Dictionary<String, AnyObject>()
    var uniNames:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addUniClass")
    }
    
    func addUniClass() {
        self.performSegueWithIdentifier("addUniCourse", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coursesInfo.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell =  self.tableView.dequeueReusableCellWithIdentifier("uniInfo") as! UniCourseCell
        var uniName = uniNames[indexPath.row]
        var courses = coursesInfo[uniName] as! [Course]
        var courseComplete = courses.map() { course in
            return "\(course.subject) \(course.number)"
        }
        cell.uniTitle.text = uniName
        cell.courseList.text = ", ".join(courseComplete)
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
}
