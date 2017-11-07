//
//  UserDetailBaseViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/28/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit
import Kinvey

class UserDetailBaseViewController : UIViewController, ProfileViewDelegate, UINavigationControllerDelegate {

    lazy var profileView:ProfileView = {
        let profileView = Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)?[0] as? ProfileView
        profileView!.translatesAutoresizingMaskIntoConstraints = false
        profileView!.profileMode = self.profileMode()
        profileView!.delegate = self
        return profileView!
    }()
    
    lazy var dataManager:DataManager = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.dataManager
    }()
    
    override func viewDidLoad() {
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardHandlers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardHandlers()
    }
    
    func setupSubviews() {
        view.addSubview(profileView)
        
        let views = [
            "profile" : profileView
        ]
        
        let constraintsFormats = [
            "V:|-(0)-[profile]-(0)-|",
            "H:|-(0)-[profile]-(0)-|"
        ]
        
        var newConstraints:[NSLayoutConstraint] = []
        
        for format:String in constraintsFormats {
            let formatConstraints:[NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views) as [NSLayoutConstraint]
            newConstraints += formatConstraints
        }
        
        view.addConstraints(newConstraints)
    }
    
    func profileMode() -> ProfileMode {
        assert(false, "Must Implement in Subclass")
        return ProfileMode.signup
    }
    
    //MARK: --
    //MARK: Keyboard Handling
    
    func addKeyboardHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(UserDetailBaseViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserDetailBaseViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardHandlers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
//        let userInfo = notification.userInfo!
//        let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size
//        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 50.0, 0.0)
//        profileView.scrollView.contentInset = contentInsets
//        profileView.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
//        let contentInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0)
//        profileView.scrollView.contentInset = contentInsets
//        profileView.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    //MARK: --
    //MARK: UINavigationControllerDelegate Implementation
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent;
    }
    
    //MARK: --
    //MARK: ProfileViewDelegate Implementation
    
    func logoutCurrentUser() {
        Kinvey.sharedClient.activeUser?.logout()
        performSegue(withIdentifier: AuctionAppConstants.Segue.Logout, sender: self)
    }
}

//MARK: -
//MARK: Kinvey User Creation Process

extension UserDetailBaseViewController {
    
    @IBAction func createUser() {
        ViewControllerUtils.shared.showActivityIndicator(uiView: self.view)

        // Perform User Creation and Profile Picture Uploading
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        queue.async { () -> Void in
            // Perform the User Creation
            self.createKinveyUser({ (error) -> () in
                ViewControllerUtils.shared.hideActivityIndicator(uiView: self.view)
                if(error == nil) {
                    // When user creation completes, dismiss the signup view controller on the main thread
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.dismiss(animated: true, completion: nil);
                    })
                }
            })
        }
    }

    func createKinveyUser(_ completion: @escaping (Bool!) -> ()) {
        DispatchQueue.main.async {
            let user = CustomUser()
            user.username = self.profileView.emailTextField.text!
            user.password = self.profileView.passwordField.text!
            user.bidderNumber = self.profileView.titleTextField.text!
            user.email = self.profileView.emailTextField.text!
            user.first_name = self.profileView.firstNameField.text!
            user.last_name = self.profileView.lastNameField.text!
            User.signup(user:user) { newUser, error in
                if let _ = newUser {
                    completion(nil)
                } else if let error = error as? Kinvey.Error {
                    switch error {
                    case .invalidResponse(let httpResponse, let data):
                        if let httpResponse = httpResponse {
                            print("Error: \(httpResponse.description)")
                        }
                        if let data = data, let responseStringBody = String(data: data, encoding: .utf8) {
                            print("Error: \(responseStringBody)")
                        }
                        completion(true)
                    case .unknownJsonError(let httpResponse, let data, _):
                        var errMsg:String = ""
                        if let httpResponse = httpResponse {
                            errMsg = httpResponse.description
                        }
                        if let data = data, let responseStringBody = String(data: data, encoding: .utf8) {
                            errMsg = responseStringBody
                        }
                        print("Error: \(errMsg)")
                        if errMsg.range(of: "Duplicate Email") != nil {
                            let alert = UIAlertController(title: "Error", message: "User with that email already exists.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            }
        }
    }
}
