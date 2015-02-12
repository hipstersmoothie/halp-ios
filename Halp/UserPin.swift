//
//  UserPin.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/5/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import Foundation

class UserPin: NSObject {
    var user:User
    var courses:Dictionary<String, [Course]>
    var longitude:Double
    var latitude:Double
    var skills:[String]
    var pinDescription:String
    var images:[String]
    
    init(user:JSON) {
        self.user = User(user: user["user"])
        self.latitude = user["latitude"].doubleValue
        self.longitude = user["longitude"].doubleValue
        self.pinDescription = user["description"].stringValue
        self.skills = user["skills"].arrayObject as [String]
        self.images = user["images"].arrayObject as [String]
        
        var unis =  user["courses"].dictionaryValue
        self.courses = Dictionary<String, [Course]>()
        
        super.init()
        
        for (key, val) in unis {
            self.courses.updateValue(getCourses(val), forKey: key)
        }
        
        println("some stuff \(self.courses)")
    }
}

func getCourses(courses:JSON) -> [Course] {
    var courseArray = courses.arrayValue
    var procCourses:[Course] = []
    
    for var i = 0; i < courseArray.count; i++ {
        procCourses.append(Course(course: courseArray[i]))
    }
    
    return procCourses
}

class Course: NSObject {
    var subject:String
    var number:Int
    
    init(course:JSON) {
        self.subject = course["subject"].stringValue
        self.number = course["number"].intValue
    }
}