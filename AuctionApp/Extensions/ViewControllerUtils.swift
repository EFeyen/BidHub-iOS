//
//  ViewControllerUtils.swift
//  AuctionApp
//
//  Created by github user erangaeb on 8/14/14.
//  https://github.com/erangaeb/dev-notes/blob/master/swift/ViewControllerUtils.swift
//

import Foundation
import UIKit

class ViewControllerUtils {

    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    class var shared: ViewControllerUtils {
        struct Static {
            static let instance: ViewControllerUtils = ViewControllerUtils()
        }
        return Static.instance
    }

    /*
     Show customized activity indicator,
     actually add activity indicator to passing view
 
     @param uiView - add activity indicator to this view
     */
    func showActivityIndicator(uiView: UIView) {

        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:CGFloat(0.3))

        loadingView.frame = CGRect(x:0, y:0, width:80, height:80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red:CGFloat(68.0/256.0), green:CGFloat(68.0/256.0), blue:CGFloat(68.0/256.0), alpha:CGFloat(0.7))
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10

        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x:loadingView.frame.size.width / 2, y:loadingView.frame.size.height / 2);
        activityIndicator.hidesWhenStopped = true

        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }

    /*
     Hide activity indicator
     Actually remove activity indicator from its super view
 
     @param uiView - remove activity indicator from this view
     */
    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        uiView.willRemoveSubview(container)
        container.removeFromSuperview()
    }
}

//// In order to show the activity indicator, call the function from your view controller
//// ViewControllerUtils().showActivityIndicator(self.view)

//// In order to hide the activity indicator, call the function from your view controller
//// ViewControllerUtils().hideActivityIndicator(self.view)
