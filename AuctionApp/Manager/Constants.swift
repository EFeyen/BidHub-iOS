//
//  Constants.swift
//  AuctionApp
//

import Foundation
import UIKit

let Device = UIDevice.current

private let iosVersion = NSString(string: Device.systemVersion).doubleValue

struct AuctionAppConstants {

    struct Kinvey {
        static let UserBidderNumberField = "bidderNumber"
    }
    
    struct Config {
        static let AppKey = "AppKey"
        static let AppSecret = "AppSecret"
    }
    
    struct Segue {
        
        static let Signup = "SignupSegue"
        static let Login = "LoggedInSegue"
        static let Logout = "LogoutSegue"
    }
    
    struct PushNotifications {
        static let SenderId = "senderId"
        static let BidText = "bidText"
        static let CreationDate = "creationDate"
        static let ThreadId = "threadId"
        static let EntityId = "entityId"
    }
    
    struct Notifications {
        static let BidsUpdated = "kAuctionAppBidsUpdated"
        static let ItemsUpdated = "kAuctionAppItemsUpdated"
        static let NewBidReceived = "kAuctionAppNewBid"
        static let NewBidReceivedUserInfoBidKey = "kAuctionAppNewBidUserInfoBidKey"
    }
}
