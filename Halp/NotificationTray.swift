//
//  NotificationTray.swift
//  Halp
//
//  Created by Andrew Lisowski on 3/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class NotificationTray: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pinsInArea.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedTutor = pinsInArea[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if pinMode == "student" {
            var cell = tableView.dequeueReusableCellWithIdentifier("tutorCell") as! tutorRow
            
            let user = pinsInArea[indexPath.row].user
            cell.myLabel.text = user.firstname
            cell.rating.rating = user.rating
            
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! studentCell
            
            let user = pinsInArea[indexPath.row].user
            cell.name.text = user.firstname
            for (university, courseList) in pinsInArea[indexPath.row].courses {
                for course in courseList {
                    cell.course.text = "\(course.subject) \(course.number)"
                }
            }
            
            cell.skills.text = ", ".join(pinsInArea[indexPath.row].skills)
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if pinsInArea[indexPath.row].skills.count > 0 && pinsInArea[indexPath.row].pinDescription != "" {
            return 61
        }
        
        return 44
    }

}
