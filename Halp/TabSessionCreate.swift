//
//  TabSessionCreate.swift
//  
//
//  Created by Andrew Lisowski on 5/14/15.
//
//

import UIKit

class TabSessionCreate: XLBarPagerTabStripViewController, XLPagerTabStripViewControllerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.barView.selectedBar.backgroundColor = UIColor(red: 136/255, green: 205/255, blue: 202/255, alpha: 1)
        self.barView.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
         self.navigationItem.title = "Halp"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("switchTab:"), name: "TabSwitch", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "TabSwitch", object: nil)
    }
    
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
        // create child view controllers that will be managed by XLPagerTabStripViewController
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        let child_1 = storyboard.instantiateViewControllerWithIdentifier("SchoolPicker") as! SchoolPicker
        let child_2 = storyboard.instantiateViewControllerWithIdentifier("MoreDetails") as! MoreDetails
        return [child_1, child_2]
    }
    
    func switchTab(notification: NSNotification) {
        println("here")
        let type = notification.object as! String
        if (type == "SchoolPicker") {
            self.moveToViewControllerAtIndex(0)
        } else {
            self.moveToViewControllerAtIndex(1)
        }
    }
}
