//
//  MapController.swift
//  Halp
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

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var map: MKMapView!
    var manager:CLLocationManager!
    var center = false, findMe = false
    let halpApi = HalpAPI()
    var dateField: UITextField?
    var myPinAnn:UserPinAnnotation!

    @IBOutlet var nav: UINavigationItem!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var tutorIcon: UIImageView!
    @IBAction func TutorListButton(sender: AnyObject) {
        let backItem = UIBarButtonItem(title: "Map", style: .Bordered, target: nil, action: nil)
        nav.backBarButtonItem = backItem
        
        let mRect = map.visibleMapRect
        northWest = getCoordinateFromMapRectanglePoint(MKMapRectGetMinX(mRect), y: mRect.origin.y)
        southEast = getCoordinateFromMapRectanglePoint(MKMapRectGetMaxX(mRect), y: MKMapRectGetMaxY(mRect))

        println("here")
        //self.performSegueWithIdentifier("toTutors", sender: self)
    }
    
    func getCoordinateFromMapRectanglePoint(x:Double, y:Double) -> CLLocationCoordinate2D {
        var swMapPoint = MKMapPointMake(x, y);
        return MKCoordinateForMapPoint(swMapPoint);
    }
    
    @IBAction func findTutorButton(sender: AnyObject) {
        if findTutorButton.titleLabel?.text == "Go to my Pin" {
            map.setRegion(focusRegion(CLLocation(latitude: myPin.latitude, longitude: myPin.longitude)), animated: true)
        } else if pinMode == "student" {
            let backItem = UIBarButtonItem(title: "Map", style: .Bordered, target: nil, action: nil)
            
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
                self.halpApi.postPin([
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
                self.halpApi.getMyPins(self.gotMyPins)
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
            annotation.title = pin.user.firstname
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
                return
            }
            
            if myPin.latitude > 0 {
                self.tutorIcon.hidden = true
            }
                        
            self.addPin(myPin, myPin: true)
            self.findTutorButton.setTitle("Go to my Pin", forState: .Normal)
            if self.findMe == false {
                self.map.setRegion(self.focusRegion(CLLocation(latitude: myPin.latitude, longitude: myPin.longitude)), animated: false)
                self.findMe = true
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: "DeleteMyPin", object: nil)
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: "SwitchMode", object: nil) doesnt work after a while
    }
    
    func removeMyPin() {
        dispatch_async(dispatch_get_main_queue()) {
            myPin = nil
            self.tutorIcon.hidden = false
            //self.map.removeAnnotations([self.myPinAnn])
            for annotation in self.map.annotations {
                if let pin = annotation as? UserPinAnnotation {
                    if pin.myPin == true {
                        self.map.removeAnnotation(pin)
                    }
                }
            }
            if pinMode == "tutor" {
                self.findTutorButton.setTitle("Place Tutor Pin", forState: .Normal)
            } else {
                self.findTutorButton.setTitle("Find Tutor!", forState: .Normal)
            }
        }
    }
    
    func toggleMode() {
        if pinMode == "student" {
            self.findTutorButton.setTitle("Find Tutor!", forState: .Normal)
            self.navigationItem.rightBarButtonItem?.title = "Tutors"
        } else {
            self.findTutorButton.setTitle("Place Tutor Pin", forState: .Normal)
            self.navigationItem.rightBarButtonItem?.title = "Students"
        }
        map.removeAnnotations(map.annotations)
        pinsInArea = []
        findMe = false
        getPins()
    }
    
    func gotNotifications(notification: NSNotification) {
        setRightBarButton("tray-red.png")
    }
    
    func notificationTrayTapped() {
        println("tap dat tray")
    }
    
    func setRightBarButton(image: String) {
        var notificationTray = UIButton(frame: CGRectMake(0, 0, 30, 30))
        notificationTray.addTarget(self, action: Selector("notificationTrayTapped"), forControlEvents: .TouchUpInside)
        notificationTray.showsTouchWhenHighlighted = true
        
        let trayImage = UIImage(named: image)
        notificationTray.setImage(trayImage, forState: .Normal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationTray)
    }
    
    @IBOutlet var findTutorButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("removeMyPin"), name: "DeleteMyPin", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("toggleMode"), name: "SwitchMode", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gotNotifications:"), name: "notificationsRecieved", object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        // Core Location
        navigationController?.setNavigationBarHidden(false, animated: true)
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        var authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == CLAuthorizationStatus.Authorized ||
            authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse {
                manager.startUpdatingLocation()
                map.showsUserLocation = true
        }
        
        configureDatePicker()
        
        findTutorButton.layer.cornerRadius = 0.5
        findTutorButton.layer.borderWidth = 1
        findTutorButton.layer.borderColor = UIColor.whiteColor().CGColor
        findTutorButton.clipsToBounds = true
        if pinMode == "tutor" {
            findTutorButton.setTitle("Place Tutor Pin", forState: .Normal)
        }
        
        self.navigationItem.hidesBackButton = true
        self.addLeftBarButtonWithImage(UIImage(named: "timeline-list-grid-list-icon.png")!)
        
        // add the notification tray to the toolbar
        setRightBarButton("tray.png")
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        map.rotateEnabled = false
        datePicker.removeFromSuperview()
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: .ValueChanged)
        pinsInArea = []
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
    
    func getPins() {
        let mRect = map.visibleMapRect
        let mode:NSString = (pinMode == "student") ? "tutor" : "student"
        northWest = getCoordinateFromMapRectanglePoint(MKMapRectGetMinX(mRect), y: mRect.origin.y)
        southEast = getCoordinateFromMapRectanglePoint(MKMapRectGetMaxX(mRect), y: MKMapRectGetMaxY(mRect))
        var params = [
            "pinMode": mode,
            "lat1": northWest.latitude,
            "lng1": northWest.longitude,
            "lat2": southEast.latitude,
            "lng2": southEast.longitude
        ]

        halpApi.getMyPins(self.gotMyPins)
        halpApi.getTutorsInArea(params, self.gotPins)
    }
    
    func refreshMyPin(controller: LeftViewController) {
        removeMyPin()
        halpApi.getMyPins(self.gotMyPins)
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
                map.setRegion(focusRegion(locations[0] as CLLocation), animated: false)
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
                    pinView.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as UIButton
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
                    pinView.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as UIButton
                    return pinView
                } else {
                    anView.annotation = annotation
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
    
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        
        if mapChangedFromUserInteraction == true {
           getPins()
        }
    }
    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        var view:UIView = map.subviews.first as UIView
        
        for recognizer in view.gestureRecognizers as [UIGestureRecognizer] {
            if recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended {
                return true
            }
        }
        
        return false
    }
}


