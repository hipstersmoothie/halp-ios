//
//  MatchList.swift
//  Halp
//
//  Created by Andrew Lisowski on 3/17/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class MatchList: UITableViewController {
    var matches:[UserPin]!
    
    func updateMatches() {
        matches = []
        pause(self.view)
        halpApi.getMatches() { success, json in
            if success {
                let matchArr = json["matches"].arrayValue
                for match in matchArr {
                    self.matches.append(UserPin(user: match))
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    start(self.view)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateMatches()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var match = matches[indexPath.row]
        
//        NSNotificationCenter.defaultCenter().postNotificationName("MatchClicked", object: nil, userInfo: [
//                "decrementValue": 1
//            ])
        
        //go to pin profile
        
        selectedTutor = matches[indexPath.row]
        if pinMode == "student" {
            self.performSegueWithIdentifier("toProfile", sender: self)
        } else {
            self.performSegueWithIdentifier("toStudentProfile", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("matchCell") as! matchCell
        
        let matchData = matches[indexPath.row]
        cell.pic.image = UIImage(named: "tutor.jpeg")
        cell.name.text = matchData.user.firstname
        
        if pinMode == "student" {
            // for first school display class names
            for (key, courses) in matchData.user.courses {
                var classNames:[String] = []
                for course in courses {
                    classNames.append("\(course.subject) \(course.number)")
                }
                cell.classList.text = ", ".join(classNames)
                break
            }
            cell.skillList.text =  ", ".join(matchData.user.skills)
            cell.extraInfo.text = "$\(matchData.user.rate)"
        } else {
            for (key, courses) in matchData.courses {
                var classNames:[String] = []
                for course in courses {
                    classNames.append("\(key) \(course.subject) \(course.number)")
                }
                cell.classList.text = ", ".join(classNames)
                break
            }
            cell.skillList.text =  ", ".join(matchData.skills)
            let pinTTL = NSDate(timeIntervalSince1970: NSTimeInterval(matchData.endTime))
            cell.extraInfo.text = "by \(pinTTL)"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 121
    }
}
