//
//  BidSheetViewController.swift
//  AuctionApp
//

import UIKit
import Kinvey

protocol BidSheetViewControllerDelegate {
    func bidSheetViewControllerDidCancel(_ viewController: BidSheetViewController)
}

class BidSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var darkView: UIView!
    @IBOutlet var popUpContainer: UIView!
    @IBOutlet weak var bidSheetView: UITableView!

    var delegate: BidSheetViewControllerDelegate?
    var item: Item?
    var bids: Array<Bid> = []
    var winningbid: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        bidSheetView.separatorInset = UIEdgeInsets.zero

        if let itemUW = item{

            bids = itemUW.allBids
            winningbid = itemUW.currentPrice[0]

            popUpContainer.backgroundColor = UIColor.white
            popUpContainer.layer.cornerRadius = 5.0
            animateIn()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(bidSheetView.contentSize.height > bidSheetView.frame.size.height)
        {
            bidSheetView.setContentOffset(CGPoint(x: 0, y: bidSheetView.contentSize.height - bidSheetView.frame.size.height) , animated: true)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let me = Kinvey.sharedClient.activeUser as! CustomUser
        if(me.bidderNumber == "") {
            return bids.count
        } else {
            return bids.count + 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")

        let idx = indexPath.row
        let bidx = String(format: "%3d", idx+1)

        let me = Kinvey.sharedClient.activeUser as! CustomUser
        if(idx == bids.count)
        {
            cell!.backgroundColor = UIColor.white;
            cell!.textLabel?.textColor = UIColor.black;
            cell!.detailTextLabel?.textColor = UIColor.black;

            cell!.textLabel?.text = "\(bidx). Bidder \(me.bidderNumber ?? "")"
            cell!.detailTextLabel?.text = "$  ???"
        }
        else
        {
            let bid = bids[idx]
            let bidamt = String(format: "%5d", bid.amount)

            cell!.textLabel?.text = "\(bidx). Bidder \(bid.bidderNumber ?? "")"
            cell!.detailTextLabel?.text = "$\(bidamt)"

            if(bid.amount == winningbid)
            {
                cell!.backgroundColor = UIColor.green;
                cell!.textLabel?.textColor = UIColor.black
                cell!.detailTextLabel?.textColor = UIColor.black;
            }
            else
            {
                cell!.backgroundColor = UIColor.white;
                cell!.textLabel?.textColor = UIColor.lightGray;
                cell!.detailTextLabel?.textColor = UIColor.lightGray;
            }
        }

        if(cell!.responds(to: #selector(setter: UIView.layoutMargins)))
        {
            cell!.layoutMargins = UIEdgeInsets.zero
        }

        return cell!
    }

    @IBAction func didTapBackground(_ sender: AnyObject) {
        if delegate != nil {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.popUpContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01);
                self.darkView.alpha = 0
            }, completion: { (finished: Bool) -> Void in
                self.delegate!.bidSheetViewControllerDidCancel(self)
            })
        }
    }

    func animateIn(){
        popUpContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01);

        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.0,
            options: UIViewAnimationOptions.curveLinear,
            animations: {
                self.popUpContainer.transform = CGAffineTransform.identity
                self.darkView.alpha = 1.0
            },
            completion: { (fininshed: Bool) -> () in
            }
        )
    }
}
