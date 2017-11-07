//
//  Bid.swift
//  AuctionApp
//

//import UIKit
import Foundation
import Kinvey
import RealmSwift
import Realm

class Bid: Entity {

    @objc dynamic var email: String!
    @objc dynamic var name: String!
    @objc dynamic var bidderNumber: String!
    @objc dynamic var amount:Int = 0
    @objc dynamic var itemId: String!

    override class func collectionName() -> String {
        // return the name of the backend collection corresponding to this entity
        return "bids"
    }
    
    // Map properties in your backend collection to the members of this entity
    override func propertyMapping(_ map: Map) {
        // This maps the "_id", "_kmd", and "_acl" properties
        super.propertyMapping(map)
        
        // Each propety in your entity should be mapped using the following scheme:
        // <member variable> <- ("<query property name>", map["<backend property name>"])
        email <- ("email", map["email"])
        name <- ("name", map["name"])
        bidderNumber <- ("bidderNumber", map["bidderNumber"])
        amount <- ("amount", map["amt"])
        itemId <- ("itemId", map["itemId"])
    }
}

enum BidType {
    case extra(Int)
    case custom(Int)
}
