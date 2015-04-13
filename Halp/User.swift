//
//  User.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/9/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import Foundation

class User: NSObject {
    var userId:Int
    var firstname:String
    var lastname:String
    var image:String
    
    var rating:Float
    var ratings:Int
    var bio: String
    var rate: Double
    var skills: [String]
    var courses: Dictionary<String, [Course]>
    
    init(ID: Int, username: String, firstName: String, lastName: String) {
        userId = ID
        self.firstname = firstName
        self.lastname = lastName
        self.ratings = 0
        self.rating = 0
        self.rate = 0
        self.image = ""
        self.bio = ""
        self.skills = []
        self.courses = Dictionary<String, [Course]>()
    }
    
    init(user:JSON, courses:JSON) {
        self.userId = user["userId"].intValue
        self.firstname = user["firstname"].stringValue
        self.lastname = user["lastname"].stringValue
        self.image = user["image"].stringValue
        self.skills = []

        // Tutor Stuff
        if user["rate"].doubleValue > 0 {
            self.bio = user["bio"].stringValue
            self.rate = user["rate"].doubleValue
            self.rating = user["rating"].floatValue
            self.ratings = user["ratings"].intValue
            
            var unis =  courses.dictionaryValue
            self.courses = Dictionary<String, [Course]>()
                        
            for (key, val) in unis {
                self.courses.updateValue(getCourses(val), forKey: key)
            }
            
        } else {
            self.bio = user["tutor"]["bio"].stringValue
            self.rate = user["tutor"]["rate"].doubleValue
            self.rating = 0
            self.ratings = 0
            if user["tutor"]["skills"].arrayObject?.count > 0 {
                self.skills = user["tutor"]["skills"].arrayObject as! [String]
            }
        
            var unis = user["tutor"]["courses"].dictionaryValue
            self.courses = Dictionary<String, [Course]>()
            
            for (key, val) in unis {
                self.courses.updateValue(getCourses(val), forKey: key)
            }
        }
        
    }
}