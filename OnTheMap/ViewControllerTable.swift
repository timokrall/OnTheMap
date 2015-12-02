//
//  ViewControllerTable.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/29/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewControllerTable: UITableViewController {

    // MARK: Outlets
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    // MARK: Variables
    
    let studentDataModel = studentModel.sharedInstance()
    let parse = Parse.sharedInstance()
    let udacity = Udacity.sharedInstance()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStudentData()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Essential table functions

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup connection to prototype cell
        let cellReuseIdentifier = "prototypeCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)
        
        if(cell == nil){
            
            cell = UITableViewCell()
            
        }
        
        if let studentData = studentDataModel.getStudentData(){
            
            // Enter saver student names into cells
            let currentStudent = studentData[indexPath.row]
            cell!.textLabel!.text = currentStudent.firstName! + " " + currentStudent.lastName!
            
        }
        
        return cell!
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let studentData = studentDataModel.getStudentData(){
            
            // Number of cells is equal to the number of saved students
            return studentData.count
            
        }else{
            
            return 0
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let studentData = studentDataModel.getStudentData(){
            
            let student = studentData[indexPath.row]
            
            if let url = student.mediaURL{
                
                // If a student selects a cell and no error occurs, open the respective student URL
                let app = UIApplication.sharedApplication()
                app.openURL(NSURL(string: url)!)
                
            }else{
                
                // If a student selects a cell and there is no student URL associated with that cell, display an error
                let alertController = UIAlertController(title: "URL Error", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Please input a URL.", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }


    // MARK: Functions
    
    func transitionToViewControllerLogin() {
        
        // Transition to tab controller
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ViewControllerLogin")
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
            self.presentViewController(controller, animated: true, completion: nil)
            
        }
    }
    
    func getStudentData() {
        parse.getLocations() { (error) -> Void in
            if (error != nil){
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // If the student data could not be accessed, display an error message
                    let alertController = UIAlertController(title: "Student Data Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "The data could not be retrieved.", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
        }
    }

    // MARK: Actions
    
    @IBAction func tableLogout(sender: FBSDKLoginButton) {
        
            // Logout from Facebook
            // Retrieved the code for logging out from Facebook from http://stackoverflow.com/questions/29374235/facebook-sdk-4-0-ios-swift-log-a-user-out-programatically
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        
            // Logout from Udacity
            udacity.logout(){() -> Void in
            
            // Switch to login view controller if logout button is pressed
            self.transitionToViewControllerLogin()
            
        }
        
    }
    
    @IBAction func tableInput(sender: AnyObject) {
        
        // Switch to input view controller if input button is pressed
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ViewControllerInput")
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func tableRefresh(sender: AnyObject) {
        
        // Access current student data if refresh button is pressed
        getStudentData()
        
    }
    
    

}
