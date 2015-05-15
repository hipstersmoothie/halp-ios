//
//  TabSessionCreate.swift
//  
//
//  Created by Andrew Lisowski on 5/14/15.
//
//

import UIKit

class TabSessionCreate: XLBarPagerTabStripViewController, XLPagerTabStripViewControllerDataSource, XLPagerTabStripViewControllerDelegate, SessionDetailDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.barView.selectedBar.backgroundColor = UIColor(red: 136/255, green: 205/255, blue: 202/255, alpha: 1)
        self.barView.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
         self.navigationItem.title = "Halp"
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
}
