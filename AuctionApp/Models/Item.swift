//
//  Item.swift
//  AuctionApp
//

//import UIKit
import Foundation
import Kinvey
import RealmSwift

enum ItemWinnerType {
    case single
    case multiple
}

class Item: Entity {

    @objc dynamic var name:String!
    @objc dynamic var price:Int = 0
    @objc dynamic var priceIncrement:Int = 5
    @objc dynamic var currentPrice:[Int] = [Int]()
    @objc dynamic var currentWinners:[String] = [String]()
    @objc dynamic var allBidders:[String] = [String]()
    @objc dynamic var numberOfBids:Int = 0
    @objc dynamic var donorName:String = ""
    @objc dynamic var donorUrl:String = ""
    @objc dynamic var imageUrl:String = ""
    @objc dynamic var itemDescription:String = ""
    @objc dynamic var quantity:Int = 0
    @objc dynamic var openTime:Date = Date()
    @objc dynamic var closeTime:Date = Date()

    @objc dynamic var allBids:Array<Bid>!

    override class func collectionName() -> String {
        // return the name of the backend collection corresponding to this entity
        return "items"
    }
    
    // Map properties in your backend collection to the members of this entity
    override func propertyMapping(_ map: Map) {
        // This maps the "_id", "_kmd", and "_acl" properties
        super.propertyMapping(map)
        
        // Each propety in your entity should be mapped using the following scheme:
        // <member variable> <- ("<query property name>", map["<backend property name>"])
        name <- ("name", map["name"])
        price <- ("price", map["price"])
        priceIncrement <- ("priceIncrement", map["priceIncrement"])
        currentPrice <- ("currentPrice", map["currentPrice"])
        currentWinners <- ("currentWinners", map["currentWinners"])
        allBidders <- ("allBidders", map["allBidders"])
        numberOfBids <- ("numberOfBids", map["numberOfBids"])
        donorName <- ("donorName", map["donorname"])
        donorUrl <- ("donorUrl", map["donorurl"])
        imageUrl <- ("imageUrl", map["imageurl"])
        itemDescription <- ("itemDescription", map["decription"])
        quantity <- ("quantity", map["qty"])
        openTime <- ("openTime", map["opentime"], KinveyDateTransform()) // use a transform when needed
        closeTime <- ("closeTime", map["closetime"], KinveyDateTransform()) // use a transform when needed
    }

    var winnerType: ItemWinnerType {
        get {
            if quantity > 1 {
                return .multiple
            }else{
                return .single
            }
        }
    }

    var minimumBid: Int {
        get {
            if !currentPrice.isEmpty {
                return currentPrice.min()!
            }else{
//                return Int(truncating: price)
                return price
            }
        }
    }

    var isWinning: Bool {
        get {
            let user = Kinvey.sharedClient.activeUser
            return currentWinners.contains(user!.email!)
        }
    }

    var hasBid: Bool {
        get {
            let user = Kinvey.sharedClient.activeUser
            return allBidders.contains(user!.email!)
        }
    }
}


