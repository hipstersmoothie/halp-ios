//
//  reviewList.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/1/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class reviewList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var expanded = -1
    
    @IBOutlet var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if expanded == indexPath.row {
            expanded = -1
        } else {
            expanded = indexPath.row
        }
        
        table.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:reviewRow = tableView.dequeueReusableCellWithIdentifier("reviewCell") as! reviewRow
        
        cell.title.text = "No Reviews :("
        cell.rating?.rating = 0
//        cell.reviewBody?.text = selectedTutor.reviews[indexPath.row].reviewBody
//        cell.title?.text = selectedTutor.reviews[indexPath.row].title
//        cell.rating?.rating = selectedTutor.reviews[indexPath.row].rating
        
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == expanded) {
            return 180
        }
        return 40
    }

}
