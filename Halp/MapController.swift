//
//  MapController.swift
//  HalpUI
//
//  Created by Andrew Lisowski on 1/28/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var pinsInArea:[UserPin] = []
var myPin:UserPin!
var userLocation:CLLocationCoordinate2D!
var northWest:CLLocationCoordinate2D!
var southEast:CLLocationCoordinate2D!
var selectedTutor:UserPin!

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, FloatRatingViewDelegate {
    @IBOutlet var map: MKMapView!
    var manager:CLLocationManager!
    var center = false, findMe = false
    var dateField: UITextField?
    var myPinAnn:UserPinAnnotation!
    var matches:[UserPin]!
    var timer = NSTimer()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var whitePlus: UIImageView!
    @IBOutlet var goPinButton: UIButton!
    @IBOutlet var deletePinButton: UIButton!
    @IBOutlet var nav: UINavigationItem!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var tutorIcon: UIImageView!
    @IBOutlet var listView: UIView!
    @IBOutlet var list: UITableView!
    @IBAction func toggleMapList(sender: AnyObject) {
        if listView.hidden == true {
            map.hidden = true
            findTutorButton.hidden = true
            goPinButton.hidden = true
            deletePinButton.hidden = true
            whitePlus.hidden = true
            
            list.reloadData()
            listView.hidden = false
        } else {
            toggleMapControls()
            map.hidden = false
            listView.hidden = true
        }
    }
    
    @IBAction func goToMyPinAction(sender: AnyObject) {
            map.setRegion(focusRegion(CLLocation(latitude: myPin.latitude, longitude: myPin.longitude)), animated: true)
    }
    
    @IBAction func deletePinAction(sender: AnyObject) {
        //Prompt for Time
        let alertController = UIAlertController(title: "Are you sure you want to delet your pin?", message: "You will no longer recieve notifications.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Delete", style: .Default) { (action) in
            halpApi.deletePin(self.afterDeletePin)
            self.removeMyPin()
        }
        
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func toggleMapControls() {
        if myPin != nil {
            findTutorButton.hidden = true
            goPinButton.hidden = false
            deletePinButton.hidden = false
            whitePlus.hidden = true
        } else {
            findTutorButton.hidden = false
            whitePlus.hidden = false
            goPinButton.hidden = true
            deletePinButton.hidden = true
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
    
    func getCoordinateFromMapRectanglePoint(x:Double, y:Double) -> CLLocationCoordinate2D {
        var swMapPoint = MKMapPointMake(x, y);
        return MKCoordinateForMapPoint(swMapPoint);
    }
    
    @IBAction func findTutorButton(sender: AnyObject) {
        if pinMode == "student" {
            let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
            
            nav.backBarButtonItem = backItem
            userLocation = map.region.center
            
            self.performSegueWithIdentifier("toDetail", sender: self)
        } else {
            //Prompt for Time
            let alertController = UIAlertController(title: "How long do you want to tutor for?", message: "Your pin will dissapear after this time.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.inputView = self.datePicker
                textField.textAlignment = .Center
                self.dateField = textField
                self.dateField?.addTarget(self, action: Selector("datePickerInit:"), forControlEvents: .EditingDidBegin)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                halpApi.postPin([
                    "pinMode": pinMode,
                    "duration": self.datePicker.date.timeIntervalSinceNow,
                    "latitude": self.map.region.center.latitude,
                    "longitude": self.map.region.center.longitude
                    ], completionHandler: self.tutorPinPosted)
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) { }
        }
    }
    
    func datePickerInit(field:UITextField) {
        if self.dateField?.text == "" {
            var dateFormatter = NSDateFormatter()
            
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            
            var strDate = dateFormatter.stringFromDate(NSDate())
            self.dateField?.text = strDate
        }
    }
    
    func tutorPinPosted(success:Bool, json:JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            if success {
                halpApi.getMyPins(self.gotMyPins)
                createAlert(self, "Success!", "You will now be notified when students post pins that match your profile.")
            } else {
                createAlert(self, "Error!", "Couldn't place pin. You might already have a pin down")
            }
        }
    }
    

    func datePickerChanged(datePicker:UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        dateField?.text = strDate
    }
    
    func addPin(pin:UserPin, myPin:Bool) {
        var latitude:CLLocationDegrees = CLLocationDegrees(pin.latitude)
        var longitude:CLLocationDegrees = CLLocationDegrees(pin.longitude)

        var latDelta:CLLocationDegrees = 0.01
        var lonDelta:CLLocationDegrees = 0.01
        
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        var annotation = UserPinAnnotation()
        annotation.coordinate = location
        
        if (pinMode == "tutor" && myPin == true) || (pinMode == "student" && myPin == false) {
            annotation.title = "\(pin.user.firstname) \(pin.user.lastname[pin.user.lastname.startIndex])"
        } else {
            for (university, courseList) in pin.courses {
                for course in courseList {
                    annotation.title = "\(course.subject) \(course.number)"
                }
            }
        }
        
        annotation.subtitle = ", ".join(pin.skills)
        annotation.pin = pin
        annotation.myPin = myPin
    
        //check if pin is already on map
        for ann in map.annotations {
            if let uPin = ann as? UserPinAnnotation {
                if uPin.pin.user.userId == annotation.pin.user.userId {
                    return
                }
            }
        }
        
        if myPin == false {
            pinsInArea.append(pin)
        } else {
            myPinAnn = annotation
        }
        
        map.addAnnotation(annotation)
    }
    
    func gotPins(success: Bool, json: JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            if success {
                for (index: String, subJson: JSON) in json["pins"] {
                    println(subJson)
                    self.addPin(UserPin(user: subJson), myPin: false)
                }
            } else {
                //error getting pins
            }
        }
    }
    
    func gotMyPins(success:Bool, json:JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            myPin = nil
            if pinMode == "student" && json["student"] != nil {
                myPin = UserPin(user: json["student"])
            } else if pinMode == "tutor" && json["tutor"] != nil {
                myPin = UserPin(user: json["tutor"])
            } else {
//                self.halpApi.getTutorsInArea(self.createMapSquareParams(), completionHandler: self.gotPins)
                self.tutorIcon.hidden = false
                self.goPinButton.hidden = true
                self.deletePinButton.hidden = true
                self.findTutorButton.hidden = false
                self.whitePlus.hidden = false
                return
            }
            
            if myPin.latitude > 0 {
                self.tutorIcon.hidden = true
            }
                        
            self.addPin(myPin, myPin: true)

            self.goPinButton.hidden = false
            self.deletePinButton.hidden = false
            self.findTutorButton.hidden = true
            self.whitePlus.hidden = true
            
            if self.findMe == false {
                self.map.setRegion(self.focusRegion(CLLocation(latitude: myPin.latitude, longitude: myPin.longitude)), animated: false)
                self.findMe = true
                halpApi.getTutorsInArea(self.createMapSquareParams(), completionHandler: self.gotPins)
            }
        }
    }
    
    func removeMyPin() {
        dispatch_async(dispatch_get_main_queue()) {
            myPin = nil
            self.toggleMapControls()
            self.tutorIcon.hidden = false
            
            if self.matches.count > 0 {
                self.matches = []
                pinsInArea = []
                self.map.removeAnnotations(self.map.annotations)
                halpApi.getTutorsInArea(self.createMapSquareParams(), completionHandler: self.gotPins)
            }
            
            for annotation in self.map.annotations {
                if let pin = annotation as? UserPinAnnotation {
                    if pin.myPin == true {
                        self.map.removeAnnotation(pin)
                    }
                }
            }
            if pinMode == "tutor" {
                self.findTutorButton.setTitle("Tutor Pin", forState: .Normal)
            } else {
                self.findTutorButton.setTitle("Student Pin", forState: .Normal)
            }
        }
    }
    
    @IBOutlet var mapSwitch: UISegmentedControl!
    @IBOutlet var marker: UIImageView!
    func toggleMode(notification: NSNotification) {
        if pinMode == "student" {
            self.findTutorButton.setTitle("Student Pin", forState: .Normal)
        } else {
            self.findTutorButton.setTitle("Tutor Pin", forState: .Normal)
        }
        map.removeAnnotations(map.annotations)
        pinsInArea = []
        matches = []
        findMe = false
        getPins()
        if mapSwitch.selectedSegmentIndex == 1 {
            toggleMapList(self)
            mapSwitch.selectedSegmentIndex = 0
        }
    }
    
    func gotNotifications(notification: NSNotification) {
        let data = notification.userInfo! as Dictionary<NSObject, AnyObject>
        let count = data["count"] as! NSInteger
        if count > 0 {
            self.navigationItem.leftBarButtonItem?.badgeValue = "\(count)"
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        if(self.tableView.indexPathForSelectedRow() != nil) {
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow()!, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("toggleMode:"), name: "SwitchMode", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gotMatches:"), name: "GetMatches", object: nil)

        checkForNewPins()
        if notificationCounts != nil {
            let count = notificationCounts["count"] as! NSInteger
            self.navigationItem.leftBarButtonItem?.badgeValue = "\(count)"
        }
    }
    override func viewDidDisappear(animated: Bool) {
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: "DeleteMyPin", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SwitchMode", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "GetMatches", object: nil)
    }
    
    func gotMatches(notification: NSNotification) {
        matches = []
        pause(self.view)
        if notificationCounts != nil {
            let count = notificationCounts["count"] as! NSInteger
            self.navigationItem.leftBarButtonItem?.badgeValue = "\(count)"
        }
        halpApi.getMatches() { success, json in
            if success {
                let matchArr = json["matches"].arrayValue
                for match in matchArr {
                    self.matches.append(UserPin(user: match))
                }
                dispatch_async(dispatch_get_main_queue()) {
                    start(self.view)
                    if matchArr.count == 0 {
                        createAlert(self, "No Matches!", "There are currently no matches on your pin")
                    } else {
                        self.map.removeAnnotations(self.map.annotations)
                        pinsInArea = []
                        self.getPins()
                    }
                }
            }
        }
    }
    
    @IBOutlet var findTutorButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gotNotifications:"), name: "notificationsRecieved", object: nil)
        matches = []
        // Do any additional setup after loading the view, typically from a nib.
        // Core Location
        navigationController?.setNavigationBarHidden(false, animated: true)
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        var authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == CLAuthorizationStatus.AuthorizedAlways ||
            authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse {
                manager.startUpdatingLocation()
                map.showsUserLocation = true
        }
        
        configureDatePicker()
        
        styleButton(findTutorButton)
        styleButton(goPinButton)
        styleButton(deletePinButton)
        if pinMode == "tutor" {
            findTutorButton.setTitle("Tutor Pin", forState: .Normal)
        }
        self.goPinButton.hidden = true
        self.deletePinButton.hidden = true
        findTutorButton.hidden = true
        whitePlus.hidden = true
        
        self.navigationItem.hidesBackButton = true
        self.addLeftBarButtonWithImage(UIImage(named: "timeline-list-grid-list-icon.png")!)
        
        var button: UIButton = UIButton()
        button.setImage(UIImage(named: "tray.png"), forState: .Normal)
        button.frame = CGRectMake(0, 0, 40, 40)
        button.addTarget(self, action: Selector("right"), forControlEvents: .TouchUpInside)
        var rightItem:UIBarButtonItem = UIBarButtonItem()
        rightItem.customView = button
        self.navigationItem.rightBarButtonItem = rightItem
        
        navigationController?.navigationBar.barTintColor = teal
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        map.rotateEnabled = false
        datePicker.removeFromSuperview()
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: .ValueChanged)
        pinsInArea = []
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    
    func right() {
        self.slideMenuController()?.openRight()
    }
    
    func checkForNewPins() {
        halpApi.getTutorsInArea(createMapSquareParams(), completionHandler: self.gotPins)
    }
    
    func configureDatePicker() {
        // Set min/max date for the date picker.
        // As an example we will limit the date between now and 7 days from now.
        let now = NSDate()
        let currentCalendar = NSCalendar.currentCalendar()
        let dateComponents = NSDateComponents()
    
        dateComponents.day = 7
        let sevenDaysFromNow = currentCalendar.dateByAddingComponents(dateComponents, toDate: now, options: nil)
        
        dateComponents.day = 1
        let oneDayFromNow = currentCalendar.dateByAddingComponents(dateComponents, toDate: now, options: nil)
        
        datePicker.minimumDate = oneDayFromNow
        datePicker.maximumDate = sevenDaysFromNow
    }
    
    func createMapSquareParams() -> Dictionary<String, AnyObject> {
        let mRect = map.visibleMapRect
        let mode:NSString = (pinMode == "student") ? "tutor" : "student"
        
        northWest = getCoordinateFromMapRectanglePoint(MKMapRectGetMinX(mRect), y: mRect.origin.y)
        southEast = getCoordinateFromMapRectanglePoint(MKMapRectGetMaxX(mRect), y: MKMapRectGetMaxY(mRect))
        return [
            "pinMode": mode,
            "lat1": northWest.latitude,
            "lng1": northWest.longitude,
            "lat2": southEast.latitude,
            "lng2": southEast.longitude
        ]
    }
    
    func getPins() {
        halpApi.getMyPins(self.gotMyPins)
        halpApi.getTutorsInArea(createMapSquareParams(), completionHandler: self.gotPins)
    }
    
    func focusRegion(userLocation:CLLocation) -> MKCoordinateRegion {
        var latitude:CLLocationDegrees = userLocation.coordinate.latitude
        var longitude:CLLocationDegrees = userLocation.coordinate.longitude
        var latDelta:CLLocationDegrees = 0.1
        var lonDelta:CLLocationDegrees = 0.1
        
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        return MKCoordinateRegionMake(location, span)
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        if !center {
            if userLocation != nil {
                map.setRegion(focusRegion(CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)), animated: true)
            } else {
                map.setRegion(focusRegion(locations[0] as! CLLocation), animated: false)
            }
            getPins()
            center = true
        }
    }
    
    func locationManager(manager:CLLocationManager, didFailWithError error:NSError) {
        println(error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        mapView.userLocation
        if  annotation is MKUserLocation {
            return nil
        }
        
        var anView:MKAnnotationView = MKAnnotationView()
        if let myPin = annotation as? UserPinAnnotation {
            if myPin.myPin == true {
                let reuseId = "myPin"
                var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
                
                if anView == nil {
                    var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                    pinView.canShowCallout = true
                    pinView.image = UIImage(named: "student.png")
                    pinView.frame = CGRectMake(0, 0, 20, 27)
                    pinView.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as! UIButton
                    return pinView
                } else {
                    anView.annotation = annotation
                    return anView
                }
            } else {
                let reuseId = "userPin"
                var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
                
                if anView == nil {
                    var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                    pinView.canShowCallout = true
                    pinView.pinColor = .Red
                    pinView.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as! UIButton
                    pinView.alpha = 1.0
                    if matches.count > 0 {
                        pinView.alpha = 0.5
                        
                        for match in matches {
                            if match.user.userId == myPin.pin.user.userId {
                                pinView.alpha = 1.0
                                break
                            }
                        }
                    }
                    return pinView
                } else {
                    anView.annotation = annotation
                    anView.alpha = 1.0
                    if matches.count > 0 {
                        anView.alpha = 0.5
                        
                        for match in matches {
                            if match.user.userId == myPin.pin.user.userId {
                                anView.alpha = 1.0
                                break
                            }
                        }
                    }
                    
                    return anView
                }
            }
        }
        return anView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            if let pin = view.annotation as? UserPinAnnotation {
                selectedTutor = pin.pin
                if (pinMode == "student" && pin.myPin == true) || (pinMode == "tutor" && pin.myPin == false) {
                    self.performSegueWithIdentifier("toStudentProfile", sender: self)
                } else {
                    self.performSegueWithIdentifier("toProfile", sender: self)
                }
            }
        }
    }
    
    var mapChangedFromUserInteraction:Bool = false
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        
        if mapChangedFromUserInteraction == true {
            getPins()
        }
    }
    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        var view:UIView = map.subviews.first as! UIView
        
        for recognizer in view.gestureRecognizers as! [UIGestureRecognizer] {
            if recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended {
                return true
            }
        }
        
        return false
    }
    
    // tutor list shit
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pinsInArea.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedTutor = pinsInArea[indexPath.row]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if pinMode == "student" {
            var cell = tableView.dequeueReusableCellWithIdentifier("tutorCell") as! tutorRow
            
            let user = pinsInArea[indexPath.row].user
            cell.myLabel.text = "\(user.firstname) \(user.lastname[user.lastname.startIndex])"
            cell.rating.editable = false
            cell.rating.rating = user.rating            

            if matches.count > 0 {
                cell.contentView.alpha = 0.5
                
                for match in matches {
                    if match.user.userId == user.userId {
                        cell.contentView.alpha = 1.0
                        break
                    }
                }
            }
            
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! studentCell
            
            let user = pinsInArea[indexPath.row].user
            cell.name.text = "\(user.firstname) \(user.lastname[user.lastname.startIndex])"
            for (university, courseList) in pinsInArea[indexPath.row].courses {
                for course in courseList {
                    cell.course.text = "\(course.subject) \(course.number)"
                }
            }

            if matches.count > 0 {
                cell.contentView.alpha = 0.5
                
                for match in matches {
                    if match.user.userId == user.userId {
                        cell.contentView.alpha = 1.0
                        break
                    }
                }
            }
            
            cell.skills.text = ", ".join(pinsInArea[indexPath.row].skills)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if pinsInArea[indexPath.row].pinDescription != "" && pinsInArea[indexPath.row].skills.count > 0 {
            return 61
        }
        
        return 44
    }
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {

    }
}


