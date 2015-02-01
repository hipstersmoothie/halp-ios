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

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var map: MKMapView!
    var manager:CLLocationManager!
    var center = false

    @IBOutlet var nav: UINavigationItem!
    @IBAction func TutorListButton(sender: AnyObject) {
        println("h")
        let backItem = UIBarButtonItem(title: "Map", style: .Bordered, target: nil, action: nil)
        nav.backBarButtonItem = backItem
        self.performSegueWithIdentifier("toTutors", sender: self)
    }
    
    @IBAction func findTutorButton(sender: AnyObject) {
        let backItem = UIBarButtonItem(title: "Map", style: .Bordered, target: nil, action: nil)
        nav.backBarButtonItem = backItem
    }
    
    @IBOutlet var findTutorButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Core Location
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
