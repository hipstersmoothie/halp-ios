//
//  Settings.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/9/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class Settings: UITableViewController {
    var courseRow = 1
    
    @IBAction func addUniRow(sender: AnyObject) {
        courseRow++
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Account Settings"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        } else {
            return 1 + courseRow
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         var cell:UITableViewCell
        if indexPath.section == 0 {
            cell = self.tableView.dequeueReusableCellWithIdentifier("basicInfo") as UITableViewCell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell = self.tableView.dequeueReusableCellWithIdentifier("bio") as UITableViewCell
            } else if indexPath.row == 1 {
                cell = self.tableView.dequeueReusableCellWithIdentifier("skills") as UITableViewCell
            } else {
                cell = self.tableView.dequeueReusableCellWithIdentifier("rate") as UITableViewCell
            }
        } else {
            if indexPath.row == 0 || indexPath.row < courseRow {
                cell = self.tableView.dequeueReusableCellWithIdentifier("uniAndCourse") as UITableViewCell
            } else {
                cell = self.tableView.dequeueReusableCellWithIdentifier("addAnother") as UITableViewCell
            }
        }
        
        cell.selectionStyle = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Basic Info"
        } else if section == 1 {
            return "Tutor Info"
        } else {
            return "Classes I want to Tutor"
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                return 180
            } else if indexPath.row == 1 {
                return 60
            } else {
                return 60
            }
        } else {
            if indexPath.row == 0 || indexPath.row < courseRow {
                return 90
            } else {
                return 60
            }
        }
    }
}
