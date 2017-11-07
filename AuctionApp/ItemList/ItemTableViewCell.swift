//
//  ItemTableViewCell.swift
//  AuctionApp
//

import UIKit
import Kinvey

protocol ItemTableViewCellDelegate
{
    func cellDidPressBid(_ item: Item)
    func cellDidPressBidSheet(_ item: Item)
    func showAlert(_ title:String, message:String)
}

class ItemTableViewCell: UITableViewCell
{
    @IBOutlet var cardContainer: UIView!
    @IBOutlet var donorAvatar: UIImageView!
    @IBOutlet var bidNowButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var shadowView: UIView!
    @IBOutlet var moreInfoLabel: UILabel!
    @IBOutlet var moreInfoView: UIView!
    @IBOutlet var itemDescriptionLabel: UILabel!
    @IBOutlet var itemTitleLabel: UILabel!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var currentBidLabel: UILabel!
    @IBOutlet var numberOfBidsLabel: UILabel!
    @IBOutlet var numberOfBidsButton: UIButton!
    @IBOutlet var itemDonorLabel: UILabel!
    @IBOutlet var headerBackground: UIView!
    @IBOutlet var availLabel: UILabel!
    var alreadyLoaded: Bool!
    
    let defaultBackgroundColor = UIColor(white: 0, alpha: 0.7)
    let winningBackgroundColor = UIColor(red: 126.0/255.0, green: 211.0/255.0, blue: 33.0/255.0, alpha: 0.8)
    let outbidBackgroundColor = UIColor(red: 243.0/255.0, green: 158.0/255.0, blue: 18.0/255.0, alpha: 0.8)
    
    let defaultColor = UIColor(white: 0, alpha: 1)
    let winningColor = UIColor(red: 126.0/255.0, green: 211.0/255.0, blue: 33.0/255.0, alpha: 1)
    let outbidColor = UIColor(red: 243.0/255.0, green: 158.0/255.0, blue: 18.0/255.0, alpha: 1)
    
    var delegate: ItemTableViewCellDelegate?
    var item: Item?
    override func awakeFromNib() {
        super.awakeFromNib()
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.clipsToBounds = true
        alreadyLoaded = false

        shadowView.backgroundColor = UIColor(patternImage: UIImage(named:"cellBackShadow")!)
        
        donorAvatar.layer.cornerRadius = donorAvatar.frame.size.height/2
        donorAvatar.layer.masksToBounds = true
        donorAvatar.layer.borderColor = UIColor.gray.cgColor
        donorAvatar.layer.borderWidth = 0.1

        cardContainer.layer.cornerRadius = 4
        cardContainer.clipsToBounds = true

    }

    func callDelegateWithBid(){
        if let delegateUW = delegate {
            if let itemUW = item {
                delegateUW.cellDidPressBid(itemUW)
            }
        }
    }

    func callDelegateWithBidSheet(){
        if let delegateUW = delegate {
            if let itemUW = item {
                if(itemUW.allBids.count == 0)
                {
                    self.delegate?.showAlert("No Bids", message: "There are currently no bids on this item. Be the first!")
                }
                else
                {
                    delegateUW.cellDidPressBidSheet(itemUW)
                }
            }
        }
    }
    
    func setWinning(){
        headerBackground.backgroundColor = winningBackgroundColor
        moreInfoView.isHidden = false
        moreInfoView.backgroundColor = winningBackgroundColor
        if let itemUW = item {

            switch(itemUW.winnerType){
            case .multiple:
                let user = Kinvey.sharedClient.activeUser
                if let index = itemUW.currentWinners.index(of: (user?.email)!){
                    if(itemUW.closeTime.timeIntervalSinceNow < 0.0)
                    {
                        moreInfoLabel.text = "YOU WON! YOUR WINNING BID IS #\(index + 1)"
                    }
                    else
                    {
                        moreInfoLabel.text = "YOUR BID IS #\(index + 1)"
                    }
                }else{
                    fallthrough
                }
            case .single:
                if(itemUW.closeTime.timeIntervalSinceNow < 0.0)
                {
                    moreInfoLabel.text = "YOU WON! CONGRATULATIONS!"
                }
                else
                {
                    moreInfoLabel.text = "YOUR BID IS WINNING. NICE!"
                }
            }
        }
    }

    func setOutbid(){
        headerBackground.backgroundColor = outbidBackgroundColor
        moreInfoView.isHidden = false
        moreInfoView.backgroundColor = outbidBackgroundColor
        if let itemUW = item {
            if(itemUW.closeTime.timeIntervalSinceNow < 0.0)
            {
                moreInfoLabel.text = "YOU'VE BEEN OUTBID."
            }
            else
            {
                moreInfoLabel.text = "YOU'VE BEEN OUTBID. TRY HARDER?"
            }
        }
    }
    
    func setDefault(){
        headerBackground.backgroundColor = defaultBackgroundColor
        moreInfoView.isHidden = true
        moreInfoView.backgroundColor = defaultBackgroundColor
    }
    
    @IBAction func bidSheetPressed(_ sender: AnyObject) {
        callDelegateWithBidSheet()
    }
    
    @IBAction func bidNowPressed(_ sender: AnyObject) {
        callDelegateWithBid()
    }
}
