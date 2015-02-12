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
    var firstname:String!
    var user:User!
    let halpApi = HalpAPI()
    
    @IBAction func addUniRow(sender: AnyObject) {
        courseRow++
        tableView.reloadData()
    }
    
    @IBAction func saveSettings(sender: AnyObject) {
        var params = Dictionary<String, AnyObject>()
        
        if infoCell.firstName.text != user.firstname {
            params.updateValue(infoCell.firstName.text, forKey: "firstname")
        }
        
        if infoCell.lastName.text != user.lastname {
            params.updateValue(infoCell.lastName.text, forKey: "lastname")
        }
        
        //Tutor Settings
        var tutor = Dictionary<String, AnyObject>()
        if bio.bio.text != user.bio {
            tutor.updateValue(bio.bio.text, forKey: "bio")
        }
        
        var skillsArr = split(skills.skills.text) {$0 == ","}
        if skillsArr.count != user.skills.count {
            tutor.updateValue(skillsArr, forKey: "skills")
        }
        
        if rate.rate.text.toInt() != Int(user.rate) {
            tutor.updateValue(rate.rate.text.toInt()!, forKey: "rate")
        }
        
        if tutor.count > 0 {
            params.updateValue(tutor, forKey: "tutor")
        }
        
        
        halpApi.updateProfile(params, completionHandler: self.updatedProfile)
    }
    
    func updatedProfile(success:Bool, json:JSON) {
        println(json)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        halpApi.getProfile(self.gotProfile)
    }

    func gotProfile(success: Bool, json:JSON) {
        if success {
            user = User(user: json)
            tableView.reloadData()
        }
        println(json)
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
    
    var infoCell:basicInfo!
    var bio:bioCell!
    var skills:skillsCell!
    var rate:rateCell!
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            infoCell = self.tableView.dequeueReusableCellWithIdentifier("basicInfo") as basicInfo
            
            if user != nil {
                infoCell.firstName.text = user.firstname
                infoCell.lastName.text = user.lastname
            }
    
            infoCell.selectionStyle = .None
            return infoCell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                bio = self.tableView.dequeueReusableCellWithIdentifier("bio") as bioCell
                
                if user != nil {
                    if user.bio != "" {
                         bio.bio.text = user.bio
                    } else {
                         bio.bio.text = "Write a bio about yourself. This helps student get to know you before you meet."
                    }
                }
                
                bio.selectionStyle = .None
                return bio
            } else if indexPath.row == 1 {
                skills = self.tableView.dequeueReusableCellWithIdentifier("skills") as skillsCell
                
                if user != nil {
                    skills.skills.text = ",".join(user.skills)
                }
                
                skills.selectionStyle = .None
                return skills
            } else {
                rate = self.tableView.dequeueReusableCellWithIdentifier("rate") as rateCell
                
                if user != nil {
                    if user.rate > 0 {
                        rate.rate.text = "\(user.rate)"
                    } else {
                        rate.rate.text = "0"
                    }
                }
                
                rate.selectionStyle = .None
                return rate
            }
        } else {
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
                return 93
            }
        }
    }
}
