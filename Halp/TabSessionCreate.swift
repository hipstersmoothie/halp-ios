//
//  TabSessionCreate.swift
//  
//
//  Created by Andrew Lisowski on 5/14/15.
//
//

import UIKit

class TabSessionCreate: XLBarPagerTabStripViewController, XLPagerTabStripViewControllerDataSource, XLPagerTabStripViewControllerDelegate, SessionDetailDelegate {
    var params = [
        "pinMode": pinMode,
        "latitude": "\(userLocation.latitude)",
        "longitude": "\(userLocation.longitude)",
        "duration": "",
        "description": "",
        "skills": "",
        "images": "",
        "courses" : ""
    ] as Dictionary<String, AnyObject>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.barView.selectedBar.backgroundColor = teal
        self.barView.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
    }

    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
        // create child view controllers that will be managed by XLPagerTabStripViewController
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        let child_1 = storyboard.instantiateViewControllerWithIdentifier("SchoolPicker") as! SchoolPicker
        let child_2 = storyboard.instantiateViewControllerWithIdentifier("MoreDetails") as! MoreDetails
        return [child_1, child_2]
    }
    
    override func pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) {
        self.barView.moveToIndex(UInt(toIndex), animated: true)
        if (toIndex == 1) {
            NSNotificationCenter.defaultCenter().postNotificationName("SessionTabSwitch", object: "MoreDetails", userInfo: nil)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("SessionTabSwitch", object: "SchoolPicker", userInfo: nil)
        }
    }
    
    func switchTab(index: UInt) {
        self.moveToViewControllerAtIndex(index)
    }
    
    func submitNewPin() {
        pause(self.view)
        halpApi.postPin(params, completionHandler: self.afterPostPin)
    }
    
    func afterPostPin(success: Bool, json: JSON) {
        start(self.view)
        if success {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("toMapNewSession", sender: nil)
            }
        } else {
            println(json)
        }
    }
}
