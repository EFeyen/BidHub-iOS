BidHub iOS
==============
iOS client for an open-source silent auction app forked from HubSpot's BidHub app. For an overview of their auction app project, [check out their blog post about it](http://dev.hubspot.com/blog/building-an-auction-app-in-a-weekend)!

![](http://i.imgur.com/qYtj1hAl.jpg)

## Getting started
The original app used Parse as the backend, but that service was shut down on January 30, 2017 so this project was rewritten to use [Kinvey](https://www.kinvey.com/). If you haven't yet, you're going to want to set up Kinvey by following the instructions in the [BidHub Cloud Code repository](https://github.com/ncauldwell/BidHub-CloudCode/tree/kinvey-backend). Make a note of your app key and app secret (Kinvey > Your App > The App's Environment > click the 3-dots next to your App name at the top of the left-nav).

All set?
 `git clone` this repository and open the project in Xcode.

Create a property list file, *AuctionApp/Kinvey.plist* and add it to your project. Then add 2 string entries, `AppKey` and `AppSecret` and add the application key and secret from your Kinvey app environment. Run the app and you should be all set... almost!
Next steps:
* sign up (in the app)
* assign bidder number (using the [Web Panel](https://github.com/HubSpot/BidHub-WebAdmin/tree/kinvey-backend) or the Kinvey console)
* bid

Try bidding on something. To keep an eye on the action, check out the [Web Panel](https://github.com/HubSpot/BidHub-WebAdmin/tree/kinvey-backend) where you can see all your items and bids.

Push isn't going to work yet, but you should be able to see Test Object 7 and bid on it.

## Customization

The  `AppIcon` is the app icon from HubSpot's BidHub. Customize to suit your needs.

## Push
Setting up push for iOS devices isn't terribly difficult, and luckily it's been [documented by Kinvey](https://devcenter.kinvey.com/ios/guides/push). Follow their guide up to the 'App Set Up' step and you'll be fine. The rest of that guide covers adding push to the app, which is already done.
