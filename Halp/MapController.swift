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

    @IBOutlet var nav: UINavigationItem!
    @IBAction func TutorListButton(sender: AnyObject) {
        let backItem = UIBarButtonItem(title: "Map", style: .Bordered, target: nil, action: nil)
        nav.backBarButtonItem = backItem
        self.performSegueWithIdentifier("toTutors", sender: self)
    }
    
    @IBAction func findTutorButton(sender: AnyObject) {
        let backItem = UIBarButtonItem(title: "Map", style: .Bordered, target: nil, action: nil)
    
        nav.backBarButtonItem = backItem
        userLocation = map.region.center
    }
    
    func addPin(pin:UserPin) {
        var latitude:CLLocationDegrees = CLLocationDegrees(pin.latitude)
        var longitude:CLLocationDegrees = CLLocationDegrees(pin.longitude)

        var latDelta:CLLocationDegrees = 0.01
        var lonDelta:CLLocationDegrees = 0.01
        
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        var a = pin.courses["Cal Poly"]?[0]
        if let subject = a?.subject {
            if let number = a?.number {
                annotation.title = "\(subject) \(number)"
            }
        }        
        
        var skills = ""
        for var i = 0; i < pin.skills.count; i++ {
            skills += pin.skills[i]
            if i != pin.skills.count - 1 {
                skills += ", "
            }
        }
        annotation.subtitle = skills
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
                addPin(user)
            }
        } else {
            //error getting pins
        }
    }
    
    @IBOutlet var findTutorButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Core Location
        halpApi.getTutorsInArea(self.gotPins)
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
        
        self.navigationItem.hidesBackButton = true
        navigationController?.navigationBar.barTintColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.addLeftBarButtonWithImage(UIImage(named: "timeline-list-grid-list-icon.png")!)
        
        map.showsUserLocation = true
    }
    
    func launchMenu() {
        
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
}
