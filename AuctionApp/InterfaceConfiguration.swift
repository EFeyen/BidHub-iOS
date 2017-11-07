//
//  InterfaceConfiguration.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/19/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

enum DateFormat {
    case short
    case long
}

class InterfaceConfiguration {
    
    class var shortDateFormatter:DateFormatter {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = DateFormatter.Style.short
        return formatter
    }
    
    class var longDateFormatter:DateFormatter {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = DateFormatter.Style.short
        return formatter
    }

    class var keyColor:UIColor {
        return UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
    }
    
    class var contentFont:UIFont {
//        return UIFont(name: "HelveticaNeue-Light", size: 15.0)!
        return UIFont(name: "System-Light", size: 15.0)!
    }
    
    class var mainEmphasisFont:UIFont {
//        return UIFont(name: "HelveticaNeue-Bold", size: 17.0)!
        return UIFont(name: "System-Bold", size: 17.0)!
    }
    
    class var smallDetailFont:UIFont {
//        return UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        return UIFont(name: "System-Light", size: 12.0)!
    }
    
    class var cellTitleFont:UIFont {
//        return UIFont(name: "HelveticaNeue-Medium", size: 18.0)!
        return UIFont(name: "System-Medium", size: 18.0)!
    }
    
    class var cellSubtitleFont:UIFont {
//        return UIFont(name: "HelveticaNeue-LightItalic", size: 14.0)!
        return UIFont(name: "System-LightItalic", size: 14.0)!
    }

    class func configure() -> Void {
        configureBottomButton()
        configureTabBar()

        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

//        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
//        UINavigationBar.appearance().barTintColor = InterfaceConfiguration.keyColor
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    class func configureBottomButton() -> Void {
        //BottomButtonView.appearance().backgroundColor = InterfaceConfiguration.keyColor
        BottomButton.appearance().setTitleColor(UIColor.black, for: UIControlState())
    }
    
    class func configureTabBar() {
        //UITabBar.appearance().barTintColor = UIColor(red: 100.0, green: 100.0, blue: 100.0, alpha: 1.0);
//        UITextField.appearance().tintColor = UIColor.orangeColor()
//        UINavigationBar.appearance().barTintColor = UIColor(red: 177/255, green: 23/255, blue: 50/255, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColor(red: 41/255, green: 31/255, blue: 67/255, alpha: 1.0) // blue
//        UINavigationBar.appearance().tintColor = UIColor(red: 245/255, green: 24/255, blue: 24/255, alpha: 1.0) // red
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

//        UISearchBar.appearance().barTintColor = UIColor(red: 177/255, green: 23/255, blue: 50/255, alpha: 1.0)
        UISearchBar.appearance().barTintColor = UIColor(red: 41/255, green: 31/255, blue: 67/255, alpha: 1.0)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0), NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState())
    }
    
    class func formattedDate(_ format:DateFormat,date:Date) -> String {
        switch format {
            case .short:
                return shortDateFormatter.string(from: date)
            case .long:
                return longDateFormatter.string(from: date)
        }
    }
    
}

