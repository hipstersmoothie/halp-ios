//
//  HalpAPI.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/5/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import Foundation

class HalpAPI {
    var fbSession:Int?;
    
    init(){
        self.fbSession = nil;
    }
    
    func addQueryStringParams(oldUrl:String, params: Dictionary<String, AnyObject>) -> NSURL {
        var newUrl = "\(oldUrl)?"
        var tuples:[String] = []
        for (key, val) in params {
            var str = "\(val)"
            var escaped = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            tuples.append("\(key)=\(escaped!)")
        }

        return NSURL(string: newUrl + "&".join(tuples))!
    }
    
    func halpRequest(url: String, method: String, params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?, sessionId: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://api.halp.me" + url)!)
        var err: NSError?
        
        request.HTTPMethod = method
        
        if method == "POST" || method == "PUT" {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        if (method == "GET" || method == "DELETE") && params.count > 0 {
            request.URL = addQueryStringParams(request.URL!.absoluteString!, params: params)
        }

        if sessionId != "" {
            request.addValue(sessionId, forHTTPHeaderField: "sessionId")
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {data, response, error -> Void in
            if error != nil {
                println("error=\(error)")
                return
            }

            let json = JSON(data: data)
            if json["code"] == "success" {
                completionHandler!(true, json)
            } else if json["code"] == "email_taken" {
                completionHandler!(false, json)
            } else {
                completionHandler!(false, json)
            }
        }
        task.resume()
    }
    
    func login(params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?) {
        halpRequest("/login", method: "POST", params: params, completionHandler: completionHandler, sessionId: "")
    }
    
    func register(params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?) {
        halpRequest("/register", method: "POST", params: params, completionHandler: completionHandler, sessionId: "")
    }
    
    func getTutorsInArea(params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?) {
        halpRequest("/pins", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func getMyPins(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = [
            "pinMode": "mine"
        ]
        
        halpRequest("/pins", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func postPin(params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?) {
        halpRequest("/pin", method: "POST", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func deletePin(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = [
            "pinMode":pinMode
        ]
        
        halpRequest("/pin", method: "DELETE", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func getUniversities(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = Dictionary<String,String>()
        halpRequest("/enum/universities", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func getCourses(params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?) {
        halpRequest("/enum/courses", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func getSkills(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = Dictionary<String,String>()
        halpRequest("/enum/skills", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func getConversations(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = [
            "mode":pinMode
        ]
        halpRequest("/conversations", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func getMessages(uID:Int, completionHandler: ((Bool, JSON) -> Void)?) {
        let id = uID as NSNumber
        var params = [
            "mode":pinMode,
            "otherUserId": id
        ]
        
        halpRequest("/messages", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func sendMessage(params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?) {
        halpRequest("/message", method: "POST", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func getMatches(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = [
            "mode":pinMode,
        ]
        
        halpRequest("/matches", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func startSession(otherUserId:Int, completionHandler: ((Bool, JSON) -> Void)?) {
        var params = [
            "mode":pinMode,
            "otherUserId" : String(otherUserId)
        ]
        
        halpRequest("/session/start", method: "POST", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func isSessionStarted(otherUserId:Int, completionHandler: ((Bool, JSON) -> Void)?) {
        var params = [
            "mode":pinMode,
            "otherUserId" : String(otherUserId)
        ]
        
        halpRequest("/session/started", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func endSession(duration:Int, completionHandler: ((Bool, JSON) -> Void)?) {
        var params = [
            "duration":duration
        ]
        
        halpRequest("/session/end", method: "POST", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func hasSessionEnded(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = Dictionary<String, String>()
        
        halpRequest("/session/ended", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    // Get information about the currently logged in user.
    func getProfile(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = Dictionary<String, String>()
        halpRequest("/profile", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func updateProfile(params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?) {
        halpRequest("/profile", method: "PUT", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
}

