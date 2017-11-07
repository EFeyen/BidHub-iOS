//
//  AppDelegate.swift
//  AuctionApp
//

import UIKit
import Kinvey

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var dataManager:DataManager! = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Configure UI
        InterfaceConfiguration.configure();

        // Load the Kinvey Client
        setupKinveyClient()

        // Setup the Data Manager
        self.dataManager = DataManager()

        // Register for Push
        if #available(iOS 10.0, *) {
            Kinvey.sharedClient.push.registerForNotifications() { (succeed, error) in
                print("registerForNotifications(): \(succeed)")
                if let error = error {
                    print("error: \(error)")
                }
            }
        } else {
            Kinvey.sharedClient.push.registerForPush() { (succeed, error) in
                print("registerForPush(): \(succeed)")
                if let error = error {
                    print("error: \(error)")
                }
            }
        }

        // If we have an active user, proceed to the main view and bypass the login / signup view
        if Kinvey.sharedClient.activeUser != nil {
            let navController:UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController;
            self.window?.rootViewController = navController;
        }

        return true
    }

    func setupKinveyClient(_ appKey:String,appSecret:String) {
        Kinvey.sharedClient.userType = CustomUser.self
        Kinvey.sharedClient.initialize(appKey: appKey, appSecret: appSecret) {
            switch $0 {
            case .success(let user):
                if let user = user {
                    print("user: \(user)")
                }
            case .failure(let error):
                print("error: \(error)")
                self.presentKinveyConfigurationAlert()
            }
        }
    }

    func setupKinveyClient() {
        let kinveyConfig = loadKinveyConfig()
        let isValid = isKinveyConfigValid(kinveyConfig)

        assert(isValid, "Be sure you have defined your Kinvey configuration in Kinvey.plist - both AppKey and AppSecret")

        // Setup the Kinvey Client Library
        let appKey = kinveyConfig?.object(forKey: AuctionAppConstants.Config.AppKey) as! String
        let appSecret = kinveyConfig?.object(forKey: AuctionAppConstants.Config.AppSecret) as! String
        setupKinveyClient(appKey,appSecret: appSecret)
    }

    func loadKinveyConfig() -> NSDictionary! {
        if let path = Bundle.main.path(forResource: "Kinvey", ofType: "plist") {
            let kinveyDict = NSDictionary(contentsOfFile: path)
            return kinveyDict
        }
        return nil
    }

    func isKinveyConfigValid(_ config:NSDictionary!) -> Bool {
        // Verify that we were actually able to get something from the plist
        if(config == nil) {
            return false
        }

        let appKey = config.object(forKey: AuctionAppConstants.Config.AppKey) as! String?
        let appSecret = config.object(forKey: AuctionAppConstants.Config.AppSecret) as! String?

        // Verify that these values are not nil
        if (appKey == nil) || (appSecret == nil) {
            return false
        }

        // Verify that these aren't just empty strings
        if appKey!.isEmpty || appSecret!.isEmpty {
            return false
        }

        return true
    }

    func testKinveyConnection() {
        Kinvey.sharedClient.ping() { (result:Result<EnvironmentInfo, Swift.Error>) in
            switch result {
            case .success(let envInfo):
                print(envInfo);
            case .failure(let error):
                print(error)
            }
        };
    }

    func presentKinveyConfigurationAlert() {
        let alertController = UIAlertController(title: "Kinvey Config", message: "The application was not properly configured with the needed Kinvey appKey and appSecret.  You will need to create your own Kinvey app instance and load this information.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Read More", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            //TODO: Add the URL to launch
            UIApplication.shared.openURL(URL(string: "https://devcenter.kinvey.com/ios")!)
            alertController.dismiss(animated: true, completion: nil)
        }))

        let topWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.windowLevel = UIWindowLevelAlert + 1
        topWindow.makeKeyAndVisible()
        topWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if(Kinvey.sharedClient.activeUser != nil) {
            dataManager.newBidReceived(userInfo)
        }
    }
}

