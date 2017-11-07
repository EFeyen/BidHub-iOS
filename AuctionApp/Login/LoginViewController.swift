//
//  LoginViewController.swift
//  AuctionApp
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    var viewShaker:AFViewShaker?
    override func viewDidLoad() {
        super.viewDidLoad()

        viewShaker = AFViewShaker(viewsArray: [nameTextField, emailTextField])
        // Do any additional setup after loading the view.
    }

    @IBAction func loginPressed(sender: AnyObject) {
        
        if nameTextField.text != "" && emailTextField.text != ""
        {
            let fullNameArr = nameTextField.text!.lowercaseString.characters.split{$0 == " "}.map(String.init)
            let givenName = fullNameArr[0]
            let surname = fullNameArr[1]
            let username = emailTextField.text!.lowercaseString
            let email = emailTextField.text!.lowercaseString

            KCSUser.userWithUsername(
                username,
                password: "test",
                fieldsAndValues: [
                    KCSUserAttributeEmail : email,
                    KCSUserAttributeGivenname : givenName,
                    KCSUserAttributeSurname : surname
                ],
                withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                    if errorOrNil == nil {
                        //was successful!
                        self.registerForPush()
                        self.performSegueWithIdentifier("loginToItemSegue", sender: nil)
                    } else {
                        let errorString = errorOrNil.localizedDescription
                        print("Error Signing up: \(errorString)")
                    }
                }
            )
            if KCSUser.activeUser() == nil
            {
                KCSUser.loginWithUsername(
                    username,
                    password: "test",
                    withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                        if errorOrNil == nil {
                            self.registerForPush()
                            self.performSegueWithIdentifier("loginToItemSegue", sender: nil)
                        } else {
                            print("Error logging in ")
                            self.viewShaker?.shake()
                        }
                    }
                )
            }
        }else{
            //Can't login with nothing set
            viewShaker?.shake()
        }
    }

    func registerForPush() {

        let application = UIApplication.sharedApplication()

        if application.respondsToSelector("registerUserNotificationSettings:") {
            if #available(iOS 8.0, *) {
                let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            } else {
                let types: UIRemoteNotificationType = [.Badge, .Alert, .Sound]
                application.registerForRemoteNotificationTypes(types)
            }
        }else{
            let types: UIRemoteNotificationType = [.Badge, .Alert, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
        
    }
}
