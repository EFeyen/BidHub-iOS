//
//  ProfileView.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/28/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit
import Kinvey

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/*
    This view can be used in one of 3 different ways.  This is an enum to 
    enumerate these three options.
*/
enum ProfileMode {
    case signup
}

//MARK: - Delegate Protocol

/*
    The delegate protocol covers all three use cases of this view.  That being
    said, all of the options are optional (because some are used in some use
    cases and not others.  

    To allow for optional protocol methods, the protocol has to extend
    NSObjectProtocol and be declared as an '@objc' protocol.
*/
@objc protocol ProfileViewDelegate : NSObjectProtocol {
    
    @objc optional func logoutCurrentUser() -> Void
    @objc optional func profileDidChangeCompletionStatus(_ isComplete:Bool) -> Void
    @objc optional func userProfileStateDidChange(_ isDirty:Bool) -> Void
    
}

//MARK: - Class Definition

@objc(ProfileView)

/*
    This class represents a reusable UIView that is used in three different
    places within the application: the signup form, the user profile screen, and
    the directory user detail view.  

    This view has a xib (ProfileView.xib) which it will be loaded from.
*/
class ProfileView : UIView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //MARK: - Properties
    
    /*
        This is the delegate for the view.  All interaction with the view controller
        happen through this delegate.  It is a weak reference (as all delegates
        generally should be).
    */
    weak var delegate:ProfileViewDelegate?
    
    /*
        This defines the mode for this view.  Since it can be displayed in one of
        three modes, any change to the mode will call the setupViewForMode() method.
    */
    var profileMode:ProfileMode = .signup {
        didSet {
        }
    }

    /*
        This property is leveraged for the signup view and will trigger a call to the
        delegate if the value changes for form completion.
    */
    var isProfileComplete:Bool = false {
        didSet {
            if(oldValue != isProfileComplete) {
                delegate?.profileDidChangeCompletionStatus?(isProfileComplete)
            }
        }
    }
    
    /*
        This property is leveraged to track changes to the profile from the original
        user object.  If the value changes, a delegate call will be triggered.
    */
    var hasUserProfileChanged:Bool = false {
        didSet {
            if(oldValue != hasUserProfileChanged) {
                delegate?.userProfileStateDidChange?(hasUserProfileChanged)
            }
        }
    }
    
    /*
        This is the KCSUser that the view is being based on.  For the signup mode,
        this value will be nil.
    */
    var user:CustomUser? = nil {
        didSet {
            updateViewForUser()
        }
    }

    //MARK: - User Interaction and View Configuration
    
    /*
        This method updates the view state based on the KCSUser instance which was set
        with the user property.
    */
    fileprivate func updateViewForUser() {
        firstNameField.text = user?.first_name
        lastNameField.text = user?.last_name
        emailTextField.text = user?.email
        titleTextField.text = user?.bidderNumber
    }
    
    //MARK: - UITextFieldDelegate Implementation
    
    /*
        This is the method which the text fields call to know if they are editable.
        We use the isEditable method to determine the state based on the current
        mode.
    */
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEditable()
    }
/*
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String)
        -> Bool
    {
        // We ignore any change that doesn't add characters to the text field.
        // These changes are things like character deletions and cuts, as well
        // as moving the insertion point.
        //
        // We still return true to allow the change to take place.
        if string.characters.count == 0 {
            return true
        }
        
        // Check to see if the text field's contents still fit the constraints
        // with the new content added to it.
        // If the contents still fit the constraints, allow the change
        // by returning true; otherwise disallow the change by returning false.
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        switch textField {
            
            // In this field, allow only values that evalulate to proper numeric values and
            // do not contain the "-" and "e" characters, nor the decimal separator character
            // for the current locale. Limit its contents to a maximum of 5 characters.
        case titleTextField:
            let decimalSeparator = NSLocale.currentLocale().objectForKey(NSLocaleDecimalSeparator) as! String
            return prospectiveText.isNumeric() &&
                prospectiveText.doesNotContainCharactersIn("-e" + decimalSeparator) &&
                prospectiveText.characters.count <= 5
            
            // Do not put constraints on any other text field in this view
            // that uses this class as its delegate.
        default:
            return true
        }
        
    }
*/
    /*
        This delegate method for UITextField dictates what happens with the user
        presses the return key.
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == firstNameField) {
            lastNameField.becomeFirstResponder()
        } else if(textField == lastNameField) {
            emailTextField.becomeFirstResponder()
        } else if(textField == emailTextField) {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: - IBActions
    
    @IBAction func logout(_ sender:AnyObject) {
        delegate?.logoutCurrentUser?()
    }
    
    @IBAction func textFieldDidChange(_ sender:AnyObject) {
        if(user != nil) {
            evaluateUserProfileChanges()
        }
        evaluateCompletionStatus()
    }
    
    //MARK: - Private Methods
    
    /*
        This method is called in several different scenarios (for example when a
        text field changes) to determine if the profile has changed from its
        original state.
    */
    fileprivate func evaluateUserProfileChanges() {
/*
        if(user?.bidderNumber != titleTextField.text) {
            hasUserProfileChanged = true
            return
        }
*/
        if(user?.first_name != firstNameField.text) {
            hasUserProfileChanged = true
            return
        }
        
        if(user?.last_name != lastNameField.text) {
            hasUserProfileChanged = true
            return
        }
        
        if(user?.email != emailTextField.text) {
            hasUserProfileChanged = true
            return
        }
        
        hasUserProfileChanged = false
    }
    
    /*
        This method determined if the form is editable based on the mode.
    */
    fileprivate func isEditable() -> Bool {
        return (profileMode == .signup)
    }
    
    /*
        This method evaluates the profile completion state based on the values
        in the text fields.
    */
    fileprivate func evaluateCompletionStatus() {
        if(isTextFieldValid(firstNameField) &&
            isTextFieldValid(lastNameField) &&
            isTextFieldValid(emailTextField) &&
//            isTextFieldValid(titleTextField) &&
            isTextFieldValid(passwordField)) {
                isProfileComplete = true
        } else {
            isProfileComplete = false;
        }
    }
    
    /*
        This is the method that we use to determine if the value entered in a text
        field is a valid value.  In this case, it needs to not be empty.
    */
    fileprivate func isTextFieldValid(_ field:UITextField) -> Bool {
        return !(field.text?.isEmpty)!;
    }
    
}
