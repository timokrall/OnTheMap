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

class ViewControllerLogin: UIViewController, FBSDKLoginButtonDelegate {
// Connection to class in view controller fixed after looking up https://discussions.udacity.com/t/meme-2-0-hierarchy-view-error-when-attempting-to-save/29587
    
    // MARK: Outlets

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var buttonSignInUdacity: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    // MARK: Variables
    
    let udacity = Udacity.sharedInstance()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Added Facebook login viewDidLoad code after reading http://stackoverflow.com/questions/29750047/facebook-login-button-for-swift
        
        // Prepare Facebook login
        self.loginButton.delegate = self
        
        // Check whether user is logged in to Facebook and either skip login process or give permissions for login
        
            if (FBSDKAccessToken.currentAccessToken() == nil) {
                print("Not logged in.")
                loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            }else{
                print("Logged in.")
                // self.transitionToViewControllerTab()
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Functions

    // Function for logging in via Facebook
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        print("User logged in")
        
        if error == nil {
            
            self.transitionToViewControllerTab()
            print("Login complete.")
        
        } else {
        
            print(error.localizedDescription)
        
        }

    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

        print("User logged out.")
    
    }
    
    func transitionToViewControllerTab() {
    
        // Transition to tab controller
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("Tab") as! UITabBarController
        
        // Fixed transition to tab bar view controller after reading https://discussions.udacity.com/t/help-understanding-uikeyboardtaskqueue-waituntilalltasksarefinished-error/15556/3
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
            self.presentViewController(controller, animated: true, completion: nil)
    
        }
    }

    // MARK: Actions
    
    // Action for logging into Facebook
    // Fixed button layout after reading https://discussions.udacity.com/t/facebook-login-logout-button/16670
    @IBAction func loginActionFacebook(sender: FBSDKLoginButton) {
        
        print("User logged in.")
        
    }
    
    @IBAction func buttonSignUpUdacity(sender: AnyObject) {
        
        // Direct the user to the Udacity Sign Up website
        // Fixed after reading https://discussions.udacity.com/t/trouble-authenticating-for-on-the-map/16228
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
        
    }

    @IBAction func loginActionUdacity(sender: AnyObject) {
        
        udacity.login(textFieldEmail.text!, password: textFieldPassword.text!) { (data, error) -> Void in
            
            // Show error message if error occurs
            if error != nil {
                
                    let alertController = UIAlertController(title: "Login Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Please enter correct login details, thank you!", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                
            }else{
                
                // Transition to tab controller if no error occurs
                self.transitionToViewControllerTab()
                
            }
        }
    }
}