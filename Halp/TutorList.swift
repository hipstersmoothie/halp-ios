//
//  TutorList.swift
//  Halp
//
//  Created by Andrew Lisowski on 1/28/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

var selectedTutor:UserPin!

class TutorList: UITableViewController, UITableViewDelegate {
    @IBOutlet var nav: UINavigationItem!
    
    func toggleMode() {
        if pinMode == "tutor" {
            self.navigationItem.title = "Students in Area"
        } else {
            self.navigationItem.title = "Students in Area"
        }
        
        let mode:NSString = pinMode == "student" ? "tutor" : "student"
        var params = [
            "pinMode": mode,
            "lat1": northWest.latitude,
            "lng1": northWest.longitude,
            "lat2": southEast.latitude,
            "lng2": southEast.longitude
        ]
        
        pinsInArea = []
        halpApi.getTutorsInArea(params, completionHandler: self.gotPins)
    }
    
    func gotPins(success: Bool, json: JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            if success {
                for (index: String, subJson: JSON) in json["pins"] {
                    pinsInArea.append(UserPin(user: subJson))
                }
                self.tableView.reloadData()
            } else {
                //error getting pins
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("toggleMode"), name: "SwitchMode", object: nil)
        // Do any additional setup after loading the view, typically from a nib.
        
        if pinMode == "tutor" {
            self.navigationItem.title = "Students in Area"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
