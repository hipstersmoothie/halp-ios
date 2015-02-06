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

class LeftViewController : UITableViewController, LeftMenuProtocol {
    var mainViewController: UIViewController!
    var loginViewController: UIViewController!
    var halpApi = HalpAPI()
    
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
        let swiftViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as ViewController
        self.loginViewController = UINavigationController(rootViewController: swiftViewController)
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
    
    func createAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func afterDeletePin(success:Bool, json:JSON) {
        println(json)
        dispatch_async(dispatch_get_main_queue()) {
            self.slideMenuController()?.closeLeft()
            if success {
                self.createAlert("Success", message: "Removed Pin")
                self.slideMenuController()?.closeLeft()
            } else {
                self.createAlert("Error", message: "Couldn't remove pin.")
            }
        }
    }
    
    func changeViewController(menu: LeftMenu) {
        switch menu {
        case .Search:
            //self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
            break
        case .TutorMode:
            //self.slideMenuController()?.changeMainViewController(self.swiftViewController, close: true)
            break
        case .Settings:
            //self.slideMenuController()?.changeMainViewController(self.javaViewController, close: true)
            break
        case .RemovePin:
            halpApi.deletePin(self.afterDeletePin)
            break
        case .Logout:
            var storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var login:ViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as ViewController
            nvc.pushViewController(login, animated: true)
            self.slideMenuController()?.closeLeft()
            break
        default:
            break
        }
    }
    
}