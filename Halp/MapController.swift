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

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var map: MKMapView!
    var manager:CLLocationManager!
    var center = false
    let halpApi = HalpAPI()
    var dateField: UITextField?

    @IBOutlet var nav: UINavigationItem!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var tutorIcon: UIImageView!
    @IBAction func TutorListButton(sender: AnyObject) {
        let backItem = UIBarButtonItem(title: "Map", style: .Bordered, target: nil, action: nil)
        nav.backBarButtonItem = backItem
        self.performSegueWithIdentifier("toTutors", sender: self)
    }
    
    @IBAction func findTutorButton(sender: AnyObject) {
        if pinMode == "student" {
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
    
    func tutorPinPosted(success:Bool, json:JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            if success {
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
        
        if pinMode == "tutor" {
            for (university, courseList) in pin.courses {
                for course in courseList {
                    annotation.title = "\(course.subject) \(course.number)"
                }
            }
        } else {
            annotation.title = pin.user.firstname
        }
        
        var skills = ""
        for var i = 0; i < pin.skills.count; i++ {
            skills += pin.skills[i]
            if i != pin.skills.count - 1 {
                skills += ", "
            }
        }
        annotation.subtitle = skills
        annotation.pin = pin
        annotation.myPin = myPin

        map.addAnnotation(annotation)
    }
    
    func gotPins(success: Bool, json: JSON) {
        if success {
            var pins = json["pins"]
            pinsInArea = []
            for (index: String, subJson: JSON) in pins {
                var skills:[String] = subJson["skills"].arrayObject as [String]

                let user = UserPin(user: subJson)
                pinsInArea.append(user)
                addPin(user, myPin: false)
            }
        } else {
            //error getting pins
        }
    }
    
    func gotMyPins(success:Bool, json:JSON) {
        dispatch_async(dispatch_get_main_queue()) {
            if pinMode == "student" {
                myPin = UserPin(user: json["student"])
            } else {
                myPin = UserPin(user: json["tutor"])
            }
            
            if myPin.latitude > 0 {
                self.tutorIcon.hidden = true
            }
            self.addPin(myPin, myPin: true)
        }
        
        println("MY PINS")
        println(json)
    }
    
    @IBOutlet var findTutorButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Core Location
        halpApi.getTutorsInArea(self.gotPins)
        halpApi.getMyPins(self.gotMyPins)
        navigationController?.setNavigationBarHidden(false, animated: true)
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        findTutorButton.layer.cornerRadius = 0.5
        findTutorButton.layer.borderWidth = 1
        findTutorButton.layer.borderColor = UIColor.whiteColor().CGColor
        findTutorButton.clipsToBounds = true
        if pinMode == "tutor" {
            findTutorButton.setTitle("Place Tutor Pin", forState: .Normal)
        }
        
        self.navigationItem.hidesBackButton = true
        navigationController?.navigationBar.barTintColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.addLeftBarButtonWithImage(UIImage(named: "timeline-list-grid-list-icon.png")!)
        if pinMode == "tutor" {
            self.navigationItem.rightBarButtonItem?.title = "Students"
        }
        
        map.showsUserLocation = true
        datePicker.removeFromSuperview()
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: .ValueChanged)
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        if !center {
            var userLocation:CLLocation = locations[0] as CLLocation
            var latitude:CLLocationDegrees = userLocation.coordinate.latitude
            var longitude:CLLocationDegrees = userLocation.coordinate.longitude
            var latDelta:CLLocationDegrees = 0.01
            var lonDelta:CLLocationDegrees = 0.01
            
            var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            map.setRegion(region, animated: true)
            center = true
        }
    }
    
    func locationManager(manager:CLLocationManager, didFailWithError error:NSError)
    {
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
        
        let reuseId = "userPin"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if anView == nil {
            var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.canShowCallout = true
            if let myPin = annotation as? UserPinAnnotation {
                if myPin.myPin == true {
                    pinView.image = UIImage(named: "student.png")
                    pinView.frame = CGRectMake(0, 0, 20, 27)
                } else {
                    pinView.pinColor = .Red
                }
            }
            
            pinView.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as UIButton
            return pinView
        }
        else {
            anView.annotation = annotation
        }
        

        
        return anView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            if let pin = view.annotation as? UserPinAnnotation {
                selectedTutor = pin.pin
                if pinMode == "student" {
                    self.performSegueWithIdentifier("toProfile", sender: self)
                } else {
                    self.performSegueWithIdentifier("toStudentProfile", sender: self)
                }
                
            }
        }
    }
}

class UserPinAnnotation: MKPointAnnotation {
    var pin: UserPin!
    var myPin:Bool!
}
