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
    
    func halpRequest(url: String, method: String, params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?, sessionId: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://api.halp.me" + url)!)
        var err: NSError?
        
        request.HTTPMethod = method
        if method == "POST" {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
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
                println("asdf")
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
    
    func getTutorsInArea(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = Dictionary<String, String>()
        halpRequest("/pins", method: "GET", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func postPin(params: Dictionary<String, AnyObject>, completionHandler: ((Bool, JSON) -> Void)?) {
        halpRequest("/pin", method: "POST", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
    
    func deletePin(completionHandler: ((Bool, JSON) -> Void)?) {
        var params = Dictionary<String, AnyObject>()
        halpRequest("/pin", method: "DELETE", params: params, completionHandler: completionHandler, sessionId: sessionId.stringValue)
    }
}

