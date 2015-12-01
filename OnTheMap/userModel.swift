//
//  userModel.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/30/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import Foundation

class userModel {
// Class fixed after looking up https://github.com/RP-3/OnTheMap-Submission
    
    // MARK: Variables
    
    var userData:[UserInformation]? = nil
    
    // MARK: Functions
    
    // Sort user data
    func setUserData(newData:[UserInformation]){
        userData = newData.sort({$0.updatedAt!.timeIntervalSinceNow > $1.updatedAt!.timeIntervalSinceNow})
    }
    
    func getUserData()->[UserInformation]?{
        return userData
    }
    
    func getUserInfo(userId: String)->UserInformation? {
        
        // Return nil if no user exists
        if(userData == nil){
            return nil
            
        }
        
        // Return user with userId from user data array
        for user in userData! {
            if (user.uniqueKey == userId){
                return user
            }
        }
        
        return nil
    }
    
    // Singleton to ensure that userModel runs only once
    class func sharedInstance() -> userModel {
        
        struct Singleton {
            static var sharedInstance = userModel()
        }
        
        return Singleton.sharedInstance
    }
    
}
