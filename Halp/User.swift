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
    var rating:Double
    var ratings:Int
    var image:String
    var bio: String
    var rate: Double
    
    init(user:JSON) {
        self.userId = user["userId"].intValue
        self.firstname = user["firstname"].stringValue
        self.lastname = user["lastname"].stringValue
        self.rating = user["rating"].doubleValue
        self.ratings = user["ratings"].intValue
        self.image = user["image"].stringValue
        self.bio = user["bio"].stringValue
        self.rate = user["rate"].doubleValue
    }
}