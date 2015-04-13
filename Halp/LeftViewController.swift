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
    case Matches
    case Settings
    case Logout
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

var notificationCounts:Dictionary<NSObject, AnyObject>!

class LeftViewController : UITableViewController, LeftMenuProtocol {
    var mainViewController: UIViewController!
    var settingsViewController: UIViewController!
    var tutorSetupController: UIViewController!
    var messagesController: UIViewController!
    var matchController: UIViewController!
    var sessionController: UIViewController!
    var halpApi = HalpAPI()
    
//    override init() {
//        super.init()
//    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        println("refresh")
        self.tableView.registerCellClass(BaseTableViewCell.self)
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let settings = storyboard.instantiateViewControllerWithIdentifier("Settings") as! Settings
        self.settingsViewController = UINavigationController(rootViewController: settings)
        
        let setup = storyboard.instantiateViewControllerWithIdentifier("PageContentController") as! BioAndSkillsController
        self.tutorSetupController = UINavigationController(rootViewController: setup)
        
        let messages = storyboard.instantiateViewControllerWithIdentifier("Messages") as! Messages
        self.messagesController = UINavigationController(rootViewController: messages)
        
        let matches = storyboard.instantiateViewControllerWithIdentifier("Matches") as! MatchList
        self.matchController = UINavigationController(rootViewController: matches)
        
        let session = storyboard.instantiateViewControllerWithIdentifier("SessionCounter") as! SessionCounterController
        self.sessionController = UINavigationController(rootViewController: session)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gotNotifications:"), name: "notificationsRecieved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("messageClicked:"), name: "MessageClicked", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("launchSession:"), name: "inSession", object: nil)

    }
    
    func launchSession(notification: NSNotification) {
        let data = notification.userInfo! as Dictionary<NSObject, AnyObject>
        if let session = data["session"] as? Dictionary<String, AnyObject> {
            if sessionStartTime == 0 {
                sessionStartTime = session["startTimestamp"] as! NSInteger
                sessionRate = session["rate"] as! Double
                otherUserId = session["otherUserId"] as! NSInteger
                nvc.pushViewController(self.sessionController, animated: true)
            }
        }
    }
    
//    func matchesClicked() {
//        let current = messageCount.text?.toInt()
//        if current != nil {
//            let newCount  = current! - 1
//            if newCount <= 0 {
//                messageCount.text = ""
//                messageImage.image = UIImage(named: "message.png")!
//            } else {
//                messageCount.text = "\(newCount)"
//            }
//        }
//        
//        var key:String
//        if pinMode == "student" {
//            key = "studentNewMatches"
//        } else {
//            key = "tutorNewMatches"
//        }
//        
//        if notificationCounts != nil {
//            let messageCountNum = notificationCounts[key] as NSInteger
//            notificationCounts.updateValue(messageCountNum - 1, forKey: key)
//            let currCount = notificationCounts["count"] as NSInteger
//            notificationCounts.updateValue(currCount - 1, forKey: "count")
//        }
//        
//        var numberOfBadges = UIApplication.sharedApplication().applicationIconBadgeNumber
//        if numberOfBadges > 0 {
//            numberOfBadges -= 1
//            UIApplication.sharedApplication().applicationIconBadgeNumber = numberOfBadges
//        }
//    }
    
    func messageClicked(notification: NSNotification) {
        println("message click")
        let data = notification.userInfo! as Dictionary<NSObject, AnyObject>
        let val = data["decrementValue"] as! NSInteger
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
            let messageCountNum = notificationCounts[key] as! NSInteger
            notificationCounts.updateValue(messageCountNum - val, forKey: key)
            let currCount = notificationCounts["count"] as! NSInteger
            notificationCounts.updateValue(currCount - val, forKey: "count")
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
    
    @IBOutlet var matchCountLabel: UILabel!
    @IBOutlet var matchImage: UIImageView!
    func updateNotificationCounts() {
        if notificationCounts != nil {
            var key:String
            var matchKey:String
            var otherKey:String
            var otherMatchKey:String
            if pinMode == "student" {
                key = "studentUnreadMessages"
                matchKey = "studentNewMatches"
                otherKey = "tutorUnreadMessages"
                otherMatchKey = "tutorNewMatches"
            } else {
                key = "tutorUnreadMessages"
                matchKey = "tutorNewMatches"
                otherKey = "studentUnreadMessages"
                otherMatchKey = "studentNewMatches"
            }
            
            let count = notificationCounts[key]! as! NSInteger
            let otherCountNum = notificationCounts[otherKey]! as! NSInteger
            let matchCount = notificationCounts[matchKey]! as! NSInteger
            let otherMatchCountNum = notificationCounts[otherMatchKey]! as! NSInteger
            if count > 0 {
                messageCount.text = "\(count)"
                messageImage.image = UIImage(named: "message-red.png")!
            } else {
                messageCount.text = ""
                messageImage.image = UIImage(named: "message.png")!
            }
            
            if matchCount > 0 {
                matchCountLabel.text = "\(matchCount)"
                matchImage.image = UIImage(named: "message-red.png")!
            } else {
                matchCountLabel.text = ""
                matchImage.image = UIImage(named: "message.png")!
            }
            
            if otherCountNum > 0 && otherMatchCountNum > 0 {
                otherCount.text = "\(otherCountNum)/\(otherMatchCountNum)"
                switchModeImage.image = UIImage(named: "logout-red.png")!
            } else if otherCountNum > 0 {
                otherCount.text = "\(otherCountNum)"
                switchModeImage.image = UIImage(named: "logout-red.png")!
            } else if otherMatchCountNum > 0 {
                otherCount.text = "\(otherMatchCountNum)"
                switchModeImage.image = UIImage(named: "logout-red.png")!
            } else {
                otherCount.text = ""
                switchModeImage.image = UIImage(named: "logout.png")!
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

    @IBOutlet var modeLabel: UILabel!
    func changeViewController(menu: LeftMenu) {
        switch menu {
        case .Search:
            break
        case .TutorMode:
            if loggedInUser.rate > 0 {
                self.slideMenuController()?.closeLeft()
                if modeLabel.text == "Tutor Mode" {
                    pinMode = "tutor"
                    modeLabel.text = "Student Mode"
                } else {
                    pinMode = "student"
                    modeLabel.text = "Tutor Mode"
                }
                NSNotificationCenter.defaultCenter().postNotificationName("SwitchMode", object: nil, userInfo: nil)
                otherCount.text = ""
                switchModeImage.image = UIImage(named: "logout.png")!
                updateNotificationCounts()
                
            } else {
                nvc.pushViewController(self.tutorSetupController, animated: true)
                self.slideMenuController()?.closeLeft()
            }
            break
        case .Settings:
            nvc.pushViewController(self.settingsViewController, animated: true)
            self.slideMenuController()?.closeLeft()
            break
        case .Logout:
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            let login = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! ViewController
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
        case .Matches:
//            nvc.pushViewController(self.matchController, animated: true)
//      
            if notificationCounts != nil {
                let messageCountNum = notificationCounts["tutorNewMatches"] as! NSInteger
                let currCount = notificationCounts["count"] as! NSInteger
                notificationCounts.updateValue(currCount - messageCountNum, forKey: "count")
            }
            NSNotificationCenter.defaultCenter().postNotificationName("GetMatches", object: nil, userInfo: nil)
        
            self.slideMenuController()?.closeLeft()
            break
        default:
            break
        }
    }
}