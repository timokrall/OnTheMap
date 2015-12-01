//
//  ViewControllerTable.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/29/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit

class ViewControllerTable: UITableViewController {

    // MARK: Variables
    
    let userDataModel = userModel.sharedInstance()
    let parse = Parse.sharedInstance()
    let udacity = Udacity.sharedInstance()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserData()
        
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
        
        if let userData = userDataModel.getUserData(){
            
            // Enter saver user names into cells
            let currentUser = userData[indexPath.row]
            cell!.textLabel!.text = currentUser.firstName! + " " + currentUser.lastName!
            
        }
        
        return cell!
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userData = userDataModel.getUserData(){
            
            // Number of cells is equal to the number of saved users
            return userData.count
            
        }else{
            
            return 0
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let userData = userDataModel.getUserData(){
            
            let user = userData[indexPath.row]
            
            if let url = user.mediaURL{
                
                // If a user selects a cell and no error occurs, open the respective user URL
                let app = UIApplication.sharedApplication()
                app.openURL(NSURL(string: url)!)
                
            }else{
                
                // If a user selects a cell and there is no user URL associated with that cell, display an error
                let alertController = UIAlertController(title: "URL Error", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Please input a URL.", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }


    // MARK: Functions
    
    func getUserData() {
        parse.getLocations() { (error) -> Void in
            if (error != nil){
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // If the user data could not be accessed, display an error message
                    let alertController = UIAlertController(title: "User Data Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
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
    
    @IBAction func tableLogout(sender: AnyObject) {
        
        udacity.logout(){() -> Void in
            
            // Switch to login view controller if logout button is pressed
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ViewControllerLogin")
            self.presentViewController(controller, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func tableInput(sender: AnyObject) {
        
        // Switch to input view controller if input button is pressed
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ViewControllerInput")
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func tableRefresh(sender: AnyObject) {
        
        // Access current user data if refresh button is pressed
        getUserData()
        
    }
    
    

}
