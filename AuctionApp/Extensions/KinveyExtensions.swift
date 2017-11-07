//
//  KinveyExtensions.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/9/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import Kinvey
import ObjectMapper

/*
    The following methods and properties are extensions of the core KCSUser object
    (which is provided in the Kinvey iOS SDK.
*/
class CustomUser: User {

    /// password property of the user
    var password: String?
    /// first_name property of the user
    var first_name: String?
    /// last_name property of the user
    var last_name: String?
    /// bidderNumber custom property of the user
    var bidderNumber: String?

    override func mapping(map: Map) {
        super.mapping(map: map)

        password <- ("password", map["password"])
        first_name <- ("first_name", map["first_name"])
        last_name <- ("last_name", map["last_name"])
        bidderNumber <- ("bidderNumber", map["bidderNumber"])
    }
}

extension String
{
    // Returns true if the string has no characters in common with matchCharacters.
    func doesNotContainCharactersIn(_ matchCharacters: String) -> Bool {
        let characterSet = CharacterSet(charactersIn: matchCharacters)
        return self.rangeOfCharacter(from: characterSet) == nil
    }

    // Returns true if the string represents a proper numeric value.
    // This method uses the device's current locale setting to determine
    // which decimal separator it will accept.
    func isNumeric() -> Bool
    {
        let scanner = Scanner(string: self)
        
        // A newly-created scanner has no locale by default.
        // We'll set our scanner's locale to the user's locale
        // so that it recognizes the decimal separator that
        // the user expects (for example, in North America,
        // "." is the decimal separator, while in many parts
        // of Europe, "," is used).
        scanner.locale = Locale.current
        
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
}
