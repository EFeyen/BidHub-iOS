//
//  ItemManager.swift
//  AuctionApp
//

//import UIKit
import Foundation
import Kinvey

class DataManager: NSObject {

    var timer:Timer?

    var sharedInstance : DataManager {
        struct Static {
            static let instance : DataManager = DataManager()
        }
        
        return Static.instance
    }

    fileprivate var items:[Item]! = nil {
        didSet {
            sortedItems = items.sorted() { $0.closeTime.compare($1.closeTime) == ComparisonResult.orderedAscending }
        }
    }

    var sortedItems:[Item]! = nil {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: AuctionAppConstants.Notifications.ItemsUpdated), object:nil, userInfo:nil)
        }
    }

    fileprivate var bids:[Bid]! = nil {
        didSet {
            sortedBids = bids.sorted() { $0.amount < $1.amount }
        }
    }

    var sortedBids:[Bid]! = nil {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: AuctionAppConstants.Notifications.BidsUpdated), object:nil, userInfo:nil)
        }
    }

    let itemStore = DataStore<Item>.collection()
    let bidsStore = DataStore<Bid>.collection()

    func newBidReceived(_ bidInfo:[AnyHashable: Any]?) {
        if Kinvey.sharedClient.activeUser != nil
        {
            let message = bidInfo![AuctionAppConstants.PushNotifications.BidText] as! String
            let notificationUserInfo:[AnyHashable: Any]? = [
                AuctionAppConstants.Notifications.NewBidReceivedUserInfoBidKey : message
            ]
            let notification = Notification(name: Notification.Name(rawValue: AuctionAppConstants.Notifications.NewBidReceived), object: nil, userInfo:notificationUserInfo)
            NotificationCenter.default.post(notification)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "pushRecieved"), object: bidInfo)
        }
    }

    func fetchItems() {
        fetchItems { (results, error) -> () in
            // Do Something
        }
    }
    
    func fetchItems(_ completion: @escaping ([Item]?, NSError?) -> ()) {
        let sortTime = NSSortDescriptor(key: "closeTime", ascending: true)
        let sortName = NSSortDescriptor(key: "name", ascending: true)
        let query = Query(sortDescriptors: [sortTime, sortName])
        query.limit = 1000;
        itemStore.find(query, options: nil) { (results: Result<AnyRandomAccessCollection<Item>, Swift.Error>) in
            switch results {
            case .success(let allItems):
                // FIXME: I don't know how else to get the AnyRandomAccessCollection<Item> into an [Item]
                // Maybe (probably?) I should just change the app to use AnyCollection<Item> instead of [Item]
                self.items = allItems.reversed().reversed();
                for item in self.items {
                    let findItem = NSPredicate(format: "itemId = %@", item.entityId!)
                    let sortAmt = NSSortDescriptor(key: "amount", ascending: true)
                    let query = Query(predicate: findItem, sortDescriptors: [sortAmt])
                    query.limit = 1000
                    self.bidsStore.find(query, options: nil) { (results: Result<AnyRandomAccessCollection<Bid>, Swift.Error>) in
                        switch results {
                        case .success(let itemBids):
                            item.allBids = itemBids.reversed().reversed()
                        case .failure(let error):
                            print("ERROR FETCHING ITEM BIDS", terminator: "")
                            completion(nil, error as NSError?)
                        }
                    }
                }
                completion(self.items, nil)
            case .failure(let error):
                print("ERROR FETCHING ITEMS", terminator: "")
                completion(nil, error as NSError?)
            }
        }
    }

    func searchForQuery(_ query: String) -> ([Item]) {
        return applyFilter(.search(searchTerm: query))
    }

    func applyFilter(_ filter: FilterType) -> ([Item]) {
        return items.filter({ (item) -> Bool in
            return filter.predicate.evaluate(with: item)
        })
    }

    func bidOn(_ item:Item, amount: Int, completion: @escaping (Bool, _ errorCode: String) -> ()){

        let user = Kinvey.sharedClient.activeUser as? CustomUser
        let bid = Bid()
        bid.email = user?.email
        bid.name = (user?.first_name)! + " " + (user?.last_name)!
        bid.bidderNumber = user?.bidderNumber
        bid.amount = amount
        bid.itemId = item.entityId

        bidsStore.save(bid, options: nil) { (result: Result<Bid, Swift.Error>) in
            switch result {
            case .success(let bid):
                //save was successful
                NSLog("Successfully saved bid (id='%@').", bid.entityId!)
            case .failure(let error):
                //save failed
                let errorString:String = error.localizedDescription
                NSLog("Save failed, with error: %@", errorString)
                completion(false, errorString)
                return
            }

            self.itemStore.find(item.entityId!, options: nil) { (result: Result<Item, Swift.Error>) in
                switch result {
                case .success(let item):
                    NSLog("successful reload: %@", item as NSObject) // event updated
                    self.replaceItem(item)
                    completion(true, "")
                case .failure(let error):
                    let errorString:String = error.localizedDescription
                    NSLog("error occurred: %@", errorString)
                    completion(false, errorString)
                }
            }
        }
/*
        Bid(email: user.email, name: user.username, amount: amount, itemId: item.entityId!)
        .saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error != nil {
                
                if let errorString:String = error.userInfo["error"] as? String{
                    completion(false, errorCode: errorString)
                }else{
                    completion(false, errorCode: "")
                }
                return
            }
            
            let newItemQuery: PFQuery = Item.query()
            newItemQuery.whereKey("objectId", equalTo: item.objectId)
            newItemQuery.getFirstObjectInBackgroundWithBlock({ (item, error) -> Void in
                
                if let itemUW = item as? Item {
                    self.replaceItem(itemUW)
                }
                completion(true, errorCode: "")
            })
            
            let channel = "a\(item.objectId)"
            PFPush.subscribeToChannelInBackground(channel, block: { (success, error) -> Void in
                
            })
        }
*/
    }
    
    func replaceItem(_ item: Item) {
        items = items.map { (oldItem) -> Item in
            if oldItem.entityId == item.entityId {
                return item
            }
            return oldItem
        }
    }
}


enum FilterType: CustomStringConvertible {
    case all
    case noBids
    case myItems
    case search(searchTerm: String)
    
    var description: String {
        switch self{
        case .all:
            return "All"
        case .noBids:
            return "NoBids"
        case .myItems:
            return "My Items"
        case .search:
            return "Searching"
        }
    }
    
    var predicate: NSPredicate {
        switch self {
        case .noBids:
            return NSPredicate(block: { (object, bindings) -> Bool in
                if let item = object as? Item {
                    return item.numberOfBids == 0
                }
                return false
            })
        case .myItems:
            return NSPredicate(block: { (object, bindings) -> Bool in
                if let item = object as? Item {
                    return item.hasBid
                }
                return false
            })

        case .search(let searchTerm):
            return NSPredicate(block: { (object, bindings) -> Bool in
                if let item = object as? Item {
                    return item.name.contains(searchTerm) || item.donorName.contains(searchTerm) || item.itemDescription.contains(searchTerm)
                }
                return false
            })
//            return NSPredicate(format: "(donorName CONTAINS[c] %@) OR (name CONTAINS[c] %@) OR (itemDescription CONTAINS[c] %@)", searchTerm)
        case .all:
            fallthrough
        default:
            return NSPredicate(value: true)
        }
    }
}
