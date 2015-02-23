//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit

enum LeftMenu: Int {
    case Search = 0
    case TutorMode
    case RemovePin
    case Settings
    case Logout
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

protocol LeftViewControllerDelegate{
    func refreshMyPin(controller:LeftViewController)
}

class LeftViewController : UITableViewController, LeftMenuProtocol {
    var mainViewController: UIViewController!
    var settingsViewController: UIViewController!
    var tutorSetupController: UIViewController!
    var halpApi = HalpAPI()
    var delegate:LeftViewControllerDelegate? = nil
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        self.tableView.registerCellClass(BaseTableViewCell.self)
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settings = storyboard.instantiateViewControllerWithIdentifier("Settings") as Settings
        self.settingsViewController = UINavigationController(rootViewController: settings)
        let setup = storyboard.instantiateViewControllerWithIdentifier("PageContentController") as BioAndSkillsController
        self.tutorSetupController = UINavigationController(rootViewController: setup)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.changeViewController(menu)
        }
    }
    
    func afterDeletePin(success:Bool, json:JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            self.slideMenuController()?.closeLeft()
            if success {
                createAlert(self, "Success", "Removed Pin")
                self.slideMenuController()?.closeLeft()
            } else if json["code"] == "no_pin" {
                createAlert(self, "Couldn't remove pin.", "Because you dont have a pin down!")
            } else {
                createAlert(self, "Error", "Couldn't remove pin.")
            }
        }
    }
    
    @IBOutlet var modeLabel: UILabel!
    func changeViewController(menu: LeftMenu) {
        switch menu {
        case .Search:
            break
        case .TutorMode:
            if loggedInUser.rate > 0 {
                if modeLabel.text == "Tutor Mode" {
                    pinMode = "tutor"
                    modeLabel.text = "Student Mode"
                } else {
                    pinMode = "student"
                    modeLabel.text = "Tutor Mode"
                }

                NSNotificationCenter.defaultCenter().postNotificationName("SwitchMode", object: nil, userInfo: nil)
                self.slideMenuController()?.closeLeft()
            } else {
                nvc.pushViewController(self.tutorSetupController, animated: true)
                self.slideMenuController()?.closeLeft()
            }
            break
        case .Settings:
            nvc.pushViewController(self.settingsViewController, animated: true)
            self.slideMenuController()?.closeLeft()
            break
        case .RemovePin:
            halpApi.deletePin(self.afterDeletePin)
            NSNotificationCenter.defaultCenter().postNotificationName("DeleteMyPin", object: nil, userInfo: nil)
            break
        case .Logout:
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            let login = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as ViewController
            nvc.pushViewController(login, animated: true)
            self.slideMenuController()?.closeLeft()
            fbHelper.logout()
            break
        default:
            break
        }
    }
}