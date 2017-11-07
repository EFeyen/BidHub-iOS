//
//  LandingPageViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/20/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit
import Kinvey

@objc(LandingPageViewController)

class LandingPageViewController : UIViewController, UITextFieldDelegate {
    
    //MARK: -
    //MARK: Private State Variables
    
    fileprivate var isShowingLoginState:Bool = false
    fileprivate var isShowingQuickBidLoginState:Bool = false
    
    //MARK: -
    //MARK: IBOutlets
    
    @IBOutlet weak var logoImage:UIImageView?
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: BottomButton!
    @IBOutlet weak var quickBidButton: BottomButton!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var quickBidView: UIView!
    @IBOutlet weak var quickBidNumber: UITextField!
    @IBOutlet weak var quickBidSurname: UITextField!
    @IBOutlet weak var loginViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerTopConstraint: NSLayoutConstraint!
    
    //MARK: -
    //MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!;
    }
    
    //MARK: -
    //MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        self.view.backgroundColor = InterfaceConfiguration.keyColor;
        signupButton.isHidden = true
        loginButton.isHidden = true
        quickBidButton.isHidden = true
        logoTopConstraint.constant = (view.frame.size.height / 2) - (144/2) - 20.0
        view.layoutIfNeeded()

        quickBidNumber.delegate = self
        quickBidNumber.keyboardType = UIKeyboardType.numbersAndPunctuation
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        if(Kinvey.sharedClient.activeUser != nil) {
            performSegue(withIdentifier: AuctionAppConstants.Segue.Login, sender: self)
            return
        }
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        self.logoTopConstraint.constant = 90.0
        self.view.setNeedsUpdateConstraints()
        self.signupButton.isHidden = false
        self.loginButton.isHidden = false
//        self.quickBidButton.hidden = false
        self.signupButton.alpha = 0.0
        self.loginButton.alpha = 0.0
//        self.quickBidButton.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (complete) -> Void in
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.signupButton.alpha = 1.0
                self.loginButton.alpha = 1.0
//                self.quickBidButton.alpha = 1.0
            })
        }) 
    }

    //MARK: -
    //MARK: UITextFieldDelegate Implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == loginEmailField) {
            loginPasswordField.becomeFirstResponder()
        } else if(textField == quickBidNumber) {
            quickBidSurname.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: UITextFieldDelegate events and related methods
    
    func textField(_ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String)
        -> Bool
    {
        // We ignore any change that doesn't add characters to the text field.
        // These changes are things like character deletions and cuts, as well
        // as moving the insertion point.
        //
        // We still return true to allow the change to take place.
        if string.isEmpty {
            return true
        }
        
        // Check to see if the text field's contents still fit the constraints
        // with the new content added to it.
        // If the contents still fit the constraints, allow the change
        // by returning true; otherwise disallow the change by returning false.
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
            
            // In this field, allow only values that evalulate to proper numeric values and
            // do not contain the "-" and "e" characters, nor the decimal separator character
            // for the current locale. Limit its contents to a maximum of 5 characters.
        case quickBidNumber:
            let decimalSeparator = (Locale.current as NSLocale).object(forKey: NSLocale.Key.decimalSeparator) as! String
            return prospectiveText.isNumeric() &&
                prospectiveText.doesNotContainCharactersIn("-e" + decimalSeparator) &&
                prospectiveText.count <= 5
            
            // Do not put constraints on any other text field in this view
            // that uses this class as its delegate.
        default:
            return true
        }
        
    }
    
    //MARK: -
    //MARK: IBActions
    
    @IBAction func primaryButtonPress() {
        if(isShowingLoginState) {
            attemptLogin()
        } else if(isShowingQuickBidLoginState) {
            attemptQuickBidLogin()
        } else {
            performSegue(withIdentifier: AuctionAppConstants.Segue.Signup, sender: self)
        }
    }

    @IBAction func secondaryButtonPress() {
        if(isShowingLoginState || isShowingQuickBidLoginState) {
            cancelLoginState()
        } else {
            showLoginState()
        }
    }
    
    @IBAction func tertiaryButtonPress(_: AnyObject) {
        showQuickBidLoginState()
    }

    //MARK: -
    //MARK: Private Methods
    
    fileprivate func showLoginState() {
        clearLoginFields()
        buttonContainerTopConstraint.constant = 130.0
        view.setNeedsUpdateConstraints()
        quickBidButton.isHidden = true
        quickBidButton.alpha = 0.0
        loginView.isHidden = false
        loginView.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.signupButton.setTitle("Login", for: UIControlState())
            self.loginButton.setTitle("Cancel", for: UIControlState())
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.loginView.alpha = 1.0
                    }, completion: { (completed) -> Void in
                        self.isShowingLoginState = true
                        self.loginEmailField.becomeFirstResponder()
                }) 
        }) 
    }
    
    fileprivate func cancelLoginState() {
        buttonContainerTopConstraint.constant = 24.0
        view.setNeedsUpdateConstraints()
        loginEmailField.resignFirstResponder()
        loginPasswordField.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.signupButton.setTitle("Sign Up", for: UIControlState())
            self.loginButton.setTitle("Login", for: UIControlState())
//            self.quickBidButton.alpha = 1.0
            self.loginView.alpha = 0.0
            self.quickBidView.alpha = 0.0
            }, completion: { (finished) -> Void in
//                self.quickBidButton.hidden = false
                self.loginView.isHidden = true
                self.quickBidView.isHidden = false
                self.isShowingLoginState = false
                self.isShowingQuickBidLoginState = false
        }) 
    }

    fileprivate func showQuickBidLoginState() {
        clearLoginFields()
        buttonContainerTopConstraint.constant = 130.0
        view.setNeedsUpdateConstraints()
        quickBidView.isHidden = false
        quickBidView.alpha = 0.0
        quickBidButton.isHidden = true
        quickBidButton.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.signupButton.setTitle("Login", for: UIControlState())
            self.loginButton.setTitle("Cancel", for: UIControlState())
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.quickBidView.alpha = 1.0
                    }, completion: { (completed) -> Void in
                        self.isShowingQuickBidLoginState = true
                        self.quickBidNumber.becomeFirstResponder()
                }) 
        }) 
    }

    fileprivate func clearLoginFields() {
        loginPasswordField.text = ""
        loginEmailField.text = ""
        quickBidNumber.text = ""
        quickBidSurname.text = ""
    }
    
    //MARK: - Login Handling

    func attemptLogin() {
        // Ensure username and password both entered
        if loginEmailField.text == nil || loginEmailField.text!.isEmpty {
            self.shakeInput(input: loginEmailField)
            return;
        } else if loginPasswordField.text == nil || loginPasswordField.text!.isEmpty {
            self.shakeInput(input: loginPasswordField)
            return;
        }

        ViewControllerUtils.shared.showActivityIndicator(uiView: self.view)

        var username = loginEmailField.text
        let password = loginPasswordField.text

        // Check if user with username exists
        // - if it does, try to log in
        // - if it doesn't, search for a user with username in email field
        //   - if found, get that user's username and try to login with provided password
        //     - this allows users to log in with email or bidder number
        //       - new users have email as username
        //       - once bidder number is assigned, that becomes their system username
        User.exists(username: username!) { (usernameAlreadyTaken, error) -> Void in
            if let error = error as NSError? {
                self.incorrectLoginWithError(error)
            }
            if usernameAlreadyTaken {
                // provided username found so just try to log in
                User.login(username: username!, password: password!, options: nil) { (result: Result<User, Swift.Error>) in
                    switch result {
                    case .success(let user):
                        print("Login: \(user)")
                        self.successfulLogin()
                    case .failure(let error):
                        print("Login failure: \(error.localizedDescription)")
                        self.incorrectLoginWithError(NSError(domain: "loginfailure", code: 999, userInfo: nil))
                    }
                }
            } else {
                // provided username not found; create temp user to search for user with username in email field
                User.signup(username: nil, password: nil, options: nil) { (result: Result<User, Swift.Error>) in
                    switch result {
                    case .success(let user):
                        let userQuery = UserQuery {
                            $0.email = username
                        }
                        user.lookup(userQuery) { users, error in
                            if let users = users {
                                // delete temp user
                                Kinvey.sharedClient.activeUser?.destroy
                                if(users.count == 0) {
                                    // provided username not found in username or email field
                                    self.incorrectLoginWithError(NSError(domain: "loginfailure", code: 999, userInfo: nil))
                                } else {
                                    // found user with provided username in email field
                                    if let sfUser:User = users[0] as User?
                                    {
                                        // try logging in with the provided password and the matched user's username
                                        username = sfUser.username
                                        User.login(username: username!, password: password!, options: nil) { (result: Result<User, Swift.Error>) in
                                            switch result {
                                            case .success(let user):
                                                print("Login: \(user)")
                                                self.successfulLogin()
                                            case .failure(let error):
                                                print("Login failure: \(error.localizedDescription)")
                                                self.incorrectLoginWithError(NSError(domain: "loginfailure", code: 999, userInfo: nil))
                                            }
                                        }
                                    }
                                }
                            } else if let error = error as NSError? {
                                if let _ = Kinvey.sharedClient.activeUser {
                                    // delete temp user
                                    Kinvey.sharedClient.activeUser?.destroy
                                }
                                NSLog("Got An error: %@", error)
                                self.incorrectLoginWithError(error)
                            }
                        }
                    case .failure(let error):
                        print("Login failure: \(error.localizedDescription)")
                        self.incorrectLoginWithError(NSError(domain: "tempSignupfailure", code: 999, userInfo: nil))
                    }
                }
            }
        }
    }

    func attemptQuickBidLogin() {
        let bidderNumber = quickBidNumber.text

        User.login(username: bidderNumber!, password: bidderNumber!) { user, error in
            if let _ = user {
                self.successfulLogin()
            } else if let error = error as NSError? {
                if error.code == 406
                {
                    self.performSegue(withIdentifier: AuctionAppConstants.Segue.Login, sender: self)
                }
                else
                {
                    User.signup { user, error in
                        if let user = user as? CustomUser {
                            user.username = bidderNumber!
//                            user.password = bidderNumber!
                            user.bidderNumber = bidderNumber!
                            user.email = bidderNumber! + "@example.com"
                            user.first_name = "Bidder"
                            user.last_name = bidderNumber!
                            user.save() { user, error in
                                if let _ = user {
                                    self.successfulLogin()
                                } else {
                                    //failure
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func incorrectLoginWithError(_ error:NSError) {
        ViewControllerUtils.shared.hideActivityIndicator(uiView: self.view)
//        SVProgressHUD.dismiss()

        if error.code == 406
        {
            performSegue(withIdentifier: AuctionAppConstants.Segue.Login, sender: self)
        }
        else
        {
            loginPasswordField.text = ""
            self.shakeInput(input: loginPasswordField)
        }
    }

    func shakeInput(input: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: input.center.x - 10, y: input.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: input.center.x + 10, y: input.center.y))
        input.layer.add(animation, forKey: "position")
        input.becomeFirstResponder()
    }

    func successfulLogin() {
//        KCSPush.shared().registerForRemoteNotifications()
        ViewControllerUtils.shared.hideActivityIndicator(uiView: self.view)
//        SVProgressHUD.dismiss()
        performSegue(withIdentifier: AuctionAppConstants.Segue.Login, sender: self)
    }
    
}
