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
    case Messages
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
    var messagesController: UIViewController!
    var halpApi = HalpAPI()
    var delegate:LeftViewControllerDelegate? = nil
    var notificationCounts:Dictionary<NSObject, AnyObject>!
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        println("refresh")
        self.tableView.registerCellClass(BaseTableViewCell.self)
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let settings = storyboard.instantiateViewControllerWithIdentifier("Settings") as Settings
        self.settingsViewController = UINavigationController(rootViewController: settings)
        
        let setup = storyboard.instantiateViewControllerWithIdentifier("PageContentController") as BioAndSkillsController
        self.tutorSetupController = UINavigationController(rootViewController: setup)
        
        let messages = storyboard.instantiateViewControllerWithIdentifier("Messages") as Messages
        self.messagesController = UINavigationController(rootViewController: messages)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gotNotifications:"), name: "notificationsRecieved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("messageClicked:"), name: "MessageClicked", object: nil)
    }
    
    func messageClicked(notification: NSNotification) {
        let data = notification.userInfo! as Dictionary<NSObject, AnyObject>
        let val = data["decrementValue"] as NSInteger
        let current = messageCount.text?.toInt()
        if current != nil {
            let newCount  = current! - val
            if newCount <= 0 {
                messageCount.text = ""
                messageImage.image = UIImage(named: "message.png")!
            } else {
                messageCount.text = "\(newCount)"
            }
        }
        
        var key:String
        if pinMode == "student" {
            key = "studentUnreadMessages"
        } else {
            key = "tutorUnreadMessages"
        }
        
        if notificationCounts != nil {
            let messageCountNum = notificationCounts[key] as NSInteger
            notificationCounts.updateValue(messageCountNum - val, forKey: key)
        }
        
        var numberOfBadges = UIApplication.sharedApplication().applicationIconBadgeNumber
        if numberOfBadges > 0 {
            numberOfBadges -= val
            UIApplication.sharedApplication().applicationIconBadgeNumber = numberOfBadges
        }
    }
    
    @IBOutlet var otherCount: UILabel!
    @IBOutlet var messageCount: UILabel!
    @IBOutlet var switchModeImage: UIImageView!
    @IBOutlet var messageImage: UIImageView!
    func gotNotifications(notification: NSNotification) {
        notificationCounts = notification.userInfo
        updateNotificationCounts()
    }
    
    func updateNotificationCounts() {
        println("trying to update")
        if notificationCounts != nil {
            var key:String
            var otherKey:String
            if pinMode == "student" {
                key = "studentUnreadMessages"
                otherKey = "tutorUnreadMessages"
            } else {
                key = "tutorUnreadMessages"
                otherKey = "studentUnreadMessages"
            }
            
            let count = notificationCounts[key]! as NSInteger
            let otherCountNum = notificationCounts[otherKey]! as NSInteger
            if count > 0 {
                messageCount.text = "\(count)"
                messageImage.image = UIImage(named: "message-red.png")!
            }
            if otherCountNum > 0 {
                otherCount.text = "\(otherCountNum)"
                switchModeImage.image = UIImage(named: "logout-red.png")!
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: "notificationsRecieved", object: nil)
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
                otherCount.text = ""
                switchModeImage.image = UIImage(named: "logout.png")!
                updateNotificationCounts()
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
            pinMode = "student"
            modeLabel.text = "Tutor Mode"
            
            break
        case .Messages:
            nvc.pushViewController(self.messagesController, animated: true)
            self.slideMenuController()?.closeLeft()
            
            break
        default:
            break
        }
    }
}