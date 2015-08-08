//
//  NotificationList.swift
//  Halp
//
//  Created by Andrew Lisowski on 8/5/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit
var notifications:[String] = []

func buildNotificationList(object:Dictionary<String, AnyObject>) {
    let events = object["events"] as! [String]
    notifications = events.map() { event in
        if(event == "student_pin_removed") {
            return "Your student pin was removed!"
        } else if(event == "tutor_pin_removed") {
            return "Your tutor pin was removed!"
        } else if(event == "sub_merchant_approved") {
            return "Your tutor details were approved. You can now start tutoring!"
        }
        
        return event
    }
    
    let studentMatches = object["studentNewMatches"] as! Int
    let tutorMatches = object["tutorNewMatches"] as! Int
    let studentUnreadMessages = object["studentUnreadMessages"] as! Int
    let tutorUnreadMessages = object["tutorUnreadMessages"] as! Int
    if studentMatches > 0 {
        notifications.append("You have \(studentMatches) new matched tutors.")
    }
    
    if tutorMatches > 0 {
        notifications.append("You have \(tutorMatches) new matched students. These people need help with classes or skill you are knowledgable in.")
    }
    
    if studentUnreadMessages > 0 {
        notifications.append("You have \(studentUnreadMessages) new messages from tutors.")
    }
    
    if tutorUnreadMessages > 0 {
        notifications.append("You have \(tutorUnreadMessages) new messages from students.")
    }
}

class NotificationList: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(animated: Bool) {
       NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateLabels"), name: "notificationsRecieved", object: nil)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "notificationsRecieved", object: nil)
    }
    
    func updateLabels() {
        buildNotificationList(notificationCounts)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("notificationCell") as! notificationRow

        cell.message.text = notifications[indexPath.row]
        cell.message.numberOfLines = 0;
        cell.icon.image = UIImage(named: "unreadDot.png")
        
        return cell
    }
}
