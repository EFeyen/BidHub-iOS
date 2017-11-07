//
//  SignupViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/20/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController : UserDetailBaseViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func profileMode() -> ProfileMode {
        return .signup
    }
    
    @IBAction func cancelSignup(_ sender:AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
    }
    
    //MARK: --
    //MARK: ProfileViewDelegate Implementation
    
    func profileDidChangeCompletionStatus(_ isComplete: Bool) {
        saveButton.isEnabled = isComplete
    }

}
