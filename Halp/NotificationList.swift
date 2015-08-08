//
//  NotificationList.swift
//  Halp
//
//  Created by Andrew Lisowski on 8/5/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit
var notifications:[String] = []

class NotificationList: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(animated: Bool) {
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
