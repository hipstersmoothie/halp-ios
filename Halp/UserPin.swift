//
//  UserPin.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/5/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import Foundation

class UserPin: NSObject {
    var userId:Int
    var course:Course
    var longitude:Double
    var latitude:Double
    var skills:[String]
    var firstname:String
    var lastname:String
    
    init(userId:Int, course:JSON, longitude:Double, latitude:Double, skills:[String], firstname:String, lastname:String) {
        self.userId = userId
        self.course = Course(subject: course["subject"].stringValue, number: course["number"].stringValue.toInt()!)
        self.latitude = latitude
        self.longitude = longitude
        self.skills = skills
        self.firstname = firstname
        self.lastname = lastname
    }
}

class Course: NSObject {
    var subject:String
    var number:Int
    
    init(subject:String, number:Int) {
        self.subject = subject
        self.number = number
    }
}