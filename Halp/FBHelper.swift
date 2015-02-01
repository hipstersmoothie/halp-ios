//
//  FBHelper.swift
//  FBApp
//
//  Created by Md. Arifuzzaman Arif on 7/4/14.
//  Copyright (c) 2014 Md. Arifuzzaman Arif. All rights reserved.
//
import Foundation
class FBHelper{
    var fbSession:FBSession?;
    init(){
        self.fbSession = nil;
    }
    
    func logout(){
        self.fbSession?.closeAndClearTokenInformation();
        self.fbSession?.close();
    }
    
    func login(){
        let activeSession = FBSession.activeSession();
        let fbsessionState = activeSession.state;
        if(fbsessionState.hashValue != FBSessionState.Open.hashValue && fbsessionState.hashValue != FBSessionState.OpenTokenExtended.hashValue){
            let permission = ["public_profile", "user_friends", "email"];
            
            FBSession.openActiveSessionWithPublishPermissions(permission, defaultAudience: .Friends, allowLoginUI: true, completionHandler: self.fbHandler);
            
        }
    }
    
    func fbHandler(session:FBSession!, state:FBSessionState, error:NSError!){
        if let gotError = error{
            //got error
        }
        else{
            self.fbSession = session;
            FBRequest.requestForMe()?.startWithCompletionHandler(self.fbRequestCompletionHandler);
        }
    }
    
    func fbRequestCompletionHandler(connection:FBRequestConnection!, result:AnyObject!, error:NSError!){
        if let gotError = error{
            //got error
        }
        else{
            //let resultDict = result as Dictionary;
            //let email = result["email"];
            //let firstName = result["first_name"];
            
            let email : AnyObject = result.valueForKey("email")!;
            let firstName:AnyObject = result.valueForKey("first_name")!;
            let userFBID:AnyObject = result.valueForKey("id")!;
            
            let userImageURL = "https://graph.facebook.com/\(userFBID)/picture?type=small";
            let url = NSURL(string: userImageURL);
            let imageData = NSData(contentsOfURL: url!);
            let image = UIImage(data: imageData!);
            
            println("userFBID: \(userFBID) Email \(email) \n firstName:\(firstName) \n image: \(image)");
            //var userModel = User(email: email, name: firstName, image: image);
            
            NSNotificationCenter.defaultCenter().postNotificationName("PostData", object: FBSession.activeSession().accessTokenData.accessToken, userInfo: nil);
        }
    }
}

