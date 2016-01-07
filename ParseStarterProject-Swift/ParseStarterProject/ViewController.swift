/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {
    
    var signUpActive = true

    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var registeredText: UILabel!
    @IBOutlet var loginButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        if username.text == "" || password.text == "" {
            displayAlert("Error in form", message: "Please enter in a username and password")
        
        } else {
            
            //spinner
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            //Pause
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later"

            if signUpActive == true {
                //create user
                let user = PFUser()
                user.username = username.text
                user.password = password.text
                
                
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if let error = error {
                        let errorString = error.userInfo["error"] as? String
                        // Show the errorString somewhere and let the user try again.
                        
                        errorMessage = errorString!
                        self.displayAlert("Failed Signup", message: errorMessage)
                        
                    } else {
                        // Hooray! Let them use the app now.
                         print("signed up!")

                        // segue way to new controller
                        self.performSegueWithIdentifier("login", sender: self)
                        
                        print("done")
                        
                    }
                })

            } else {
                PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()

                    if user != nil {
                        // Do stuff after successful login.
                        print("logged in!")

                        // segue way to new controller
                        self.performSegueWithIdentifier("login", sender: self)
                        
                        print("done")
                        
                    } else {
                        // The login failed. Check error to see why.
                        let errorString = error!.userInfo["error"] as? String
                        // Show the errorString somewhere and let the user try again.
                        
                        errorMessage = errorString!
                        self.displayAlert("Failed Login", message: errorMessage)

                    }
                }
            }
            
            
            
        }
        
        
        
    }
    
    @IBAction func login(sender: AnyObject) {
        
        if signUpActive == true {
            
            signupButton.setTitle("Log In", forState: UIControlState.Normal)
            registeredText.text = "Not registered"
            loginButton.setTitle("Sign Up", forState: UIControlState.Normal)
            signUpActive = false
        }
        else {
            signupButton.setTitle("Sign Up", forState: UIControlState.Normal)
            registeredText.text = "Already Registered"
            loginButton.setTitle("Login", forState: UIControlState.Normal)
            signUpActive = true

        }
        
    }
    // Segue is loaded
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("login", sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
