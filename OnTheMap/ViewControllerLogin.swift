//
//  ViewController.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/28/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import AVFoundation

// Added Facebook SDK successfully after reading http://stackoverflow.com/questions/30313853/swift-facebook-login-my-uiviewcontroller-does-not-conform-to-fbsdkloginbutto
// Enabled Facebook login by adding additional settings at developers.facebook.com after reading http://stackoverflow.com/questions/31977310/fbsdkloginmanager-with-fbsdkloginbehaviorweb-failing-with-not-logged-in-error

import FBSDKCoreKit
import FBSDKLoginKit

class ViewControllerLogin: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
// Connection to class in view controller fixed after looking up https://discussions.udacity.com/t/meme-2-0-hierarchy-view-error-when-attempting-to-save/29587
    
    // MARK: Outlets

    @IBOutlet weak var buttonSignInUdacity: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    // MARK: Variables
    
    let udacity = Udacity.sharedInstance()
    var dict : NSDictionary!
    var login : FBSDKLoginManager = FBSDKLoginManager()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
    
        self.textFieldEmail.delegate = self
        self.textFieldPassword.delegate = self
        
        // Check Current Access Token for Facebook and perform seque to Tab Bar Controller if available
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            transitionToViewControllerTab()
        }
        else
        {
            // Display Facebook Login Button
            // Code found at https://github.com/mechdon/OnTheMap
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.frame = CGRectMake(0, 520, 288, 40)
            loginView.center.x = self.view.center.x
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Functions
    
    // Function for logging in via Facebook
    // Code adapted from https://github.com/mechdon/OnTheMap
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if ((error) != nil)
        {
            // Process error
            self.showAlertMsg("FBLogin Error", errorMsg: "Unable to log in to Facebook")
        }
        else if result.isCancelled {
            // Handle cancellations
            self.showAlertMsg("Cancel", errorMsg: "Cancel Facebook Login")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            returnUserData()
            transitionToViewControllerTab()
        }
        
    }
    
    // Method for obtaining user data via Facebook login
    // Code found at https://github.com/mechdon/OnTheMap
    // Parameters fixed after looking up http://stackoverflow.com/questions/33186998/facebook-sdk-returns-nil-for-user-first-name-last-name-email-and-username-in-s
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, first_name, last_name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                self.showAlertMsg("FBLogin Error", errorMsg: "Unable to retrieve user data")
            } else {
                print(result)
                let firstName: String = result.valueForKey("first_name") as! String
                let lastName: String = result.valueForKey("last_name") as! String
                let uniqueKey: String = result.valueForKey("id") as! String
                NSUserDefaults.standardUserDefaults().setObject(firstName, forKey: "firstName")
                NSUserDefaults.standardUserDefaults().setObject(lastName, forKey: "lastName")
                NSUserDefaults.standardUserDefaults().setObject(uniqueKey, forKey: "uniqueKey")
                
                
            }
        })
    }


    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

        print("User logged out.")
    
    }
    
    func transitionToViewControllerTab() {

        // Transition to tab controller
        let controller = storyboard!.instantiateViewControllerWithIdentifier("Tab") as! UITabBarController
        
        // Fixed transition to tab bar view controller after reading https://discussions.udacity.com/t/help-understanding-uikeyboardtaskqueue-waituntilalltasksarefinished-error/15556/3
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
            self.presentViewController(controller, animated: true, completion: nil)
    
        }
        
    }
    
    // Method for simplifying creation of error messages
    // Code found at https://github.com/mechdon/OnTheMap
    func showAlertMsg(errorTitle: String, errorMsg: String) {
        let title = errorTitle
        let errormsg = errorMsg
        
        NSOperationQueue.mainQueue().addOperationWithBlock{ let alert = UIAlertController(title: title, message: errormsg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
        
    // Textfield resigns first responder when return key is pressed
    // Function added after seeing it used in https://github.com/mechdon/OnTheMap
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: Actions
    
    // Redirect to Udacity signup website
    @IBAction func buttonSignUpUdacity(sender: AnyObject) {
        
        // Direct the user to the Udacity Sign Up website
        // Fixed after reading https://discussions.udacity.com/t/trouble-authenticating-for-on-the-map/16228
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
        
    }
    
    @IBAction func loginActionUdacity(sender: AnyObject) {
        
        udacity.loginCredentials(textFieldEmail.text!, password: textFieldPassword.text!) { (data, error) -> Void in
            
            // Show error message if error occurs
            if error != nil {
                
                self.showAlertMsg("Login Error", errorMsg: error!)
                
            }else{
                
                // Transition to tab controller if no error occurs
                self.transitionToViewControllerTab()
                
            }
        }
    }
}