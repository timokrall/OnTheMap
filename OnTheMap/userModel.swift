//
//  studentModel.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/30/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import Foundation

class studentModel {
// Class fixed after looking up https://github.com/RP-3/OnTheMap-Submission
    
    // MARK: Variables
    
    var studentData:[StudentInformation]? = nil
    
    // MARK: Functions
    
    // Sort user data
    func setStudentData(newData:[StudentInformation]){
        studentData = newData.sort({$0.updatedAt!.timeIntervalSinceNow > $1.updatedAt!.timeIntervalSinceNow})
    }
    
    func getStudentData()->[StudentInformation]?{
        return studentData
    }
    
    func getStudentInfo(StudentId: String)->StudentInformation? {
        
        // Return nil if no student exists
        if(studentData == nil){
            return nil
            
        }
        
        // Return user with StudentId from user data array
        for student in studentData! {
            if (student.uniqueKey == StudentId){
                return student
            }
        }
        
        return nil
    }
    
    // Singleton to ensure that studentModel runs only once
    class func sharedInstance() -> studentModel {
        
        struct Singleton {
            static var sharedInstance = studentModel()
        }
        
        return Singleton.sharedInstance
    }
    
}
