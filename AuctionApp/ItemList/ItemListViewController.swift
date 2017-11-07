//
//  ItemListViewController.swift
//  AuctionApp
//

import UIKit
import Kinvey

extension String {
    subscript (i: Int) -> String {
        return String(Array(arrayLiteral: self)[i])
    }
}

class ItemListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,ItemTableViewCellDelegate, BiddingViewControllerDelegate, BidSheetViewControllerDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var items:[Item] = [Item]()
    var timer:Timer?
    var filterType: FilterType = .all
    var sizingCell: ItemTableViewCell?
    var bottomContraint:NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        SVProgressHUD.setForegroundColor(UIColor(red: 157/225, green: 19/225, blue: 43/225, alpha: 1.0))
//        SVProgressHUD.setRingThickness(2.0)

        let colorView:UIView = UIView(frame: CGRect(x: 0, y: -1000, width: view.frame.size.width, height: 1000))
        colorView.backgroundColor = UIColor.white
        tableView.addSubview(colorView)

        //Refresh Control
        let refreshView = UIView(frame: CGRect(x: 0, y: 10, width: 0, height: 0))
        tableView.insertSubview(refreshView, aboveSubview: colorView)

        refreshControl.tintColor = UIColor(red: 157/225, green: 19/225, blue: 43/225, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(ItemListViewController.reloadItems), for: .valueChanged)
        refreshView.addSubview(refreshControl)

        sizingCell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell") as? ItemTableViewCell

        tableView.estimatedRowHeight = 392
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.alpha = 0.0
        reloadData(false, initialLoad: true)

//        let user = KCSUser.activeUser()
//        print("Logged in as: \(user.email)")
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ItemListViewController.pushRecieved(_:)), name: NSNotification.Name(rawValue: "pushRecieved"), object: nil)
        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(ItemListViewController.reloadItems), userInfo: nil, repeats: true)
        timer?.tolerance = 10.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
    }
    
    
    @objc func pushRecieved(_ notification: Notification)
    {
        if Kinvey.sharedClient.activeUser != nil
        {
            if let bidderEmail = notification.userInfo?["email"] as? String
            {
                if bidderEmail != Kinvey.sharedClient.activeUser?.email
                {
                    if let aps = notification.userInfo?["aps"] as? [AnyHashable: Any]{
                        if let alert = aps["alert"] as? String {
//                            CSNotificationView.show(in: self, tintColor: UIColor.white, font: UIFont(name: "Avenir-Light", size: 14)!, textAlignment: .center, image: nil, message: alert, duration: 5.0)
                            let alertui = UIAlertController(title: "", message: alert, preferredStyle: UIAlertControllerStyle.alert)
                            self.present(alertui, animated: true, completion: nil)
                            let when = DispatchTime.now() + 3
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                alertui.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            reloadData()
        }
    }
    
    //Hack for selectors and default parameters
    @objc func reloadItems(){
        reloadData()
    }
    
    func reloadData(_ silent: Bool = true, initialLoad: Bool = false) {
        if initialLoad {
            ViewControllerUtils.shared.showActivityIndicator(uiView: self.view)
//            SVProgressHUD.show()
        }

        Kinvey.sharedClient.activeUser?.refresh() { result in
            switch result {
                case .success:
                    print()
//                  let savedUser = results[0] as! KCSUser
                case .failure(let error):
                    //Error Case
                    if !silent {
                        self.showError("Error getting Items: " + error.localizedDescription)
                    }
                    print("Error getting items: " + error.localizedDescription)
            }
        }

        DataManager().sharedInstance.fetchItems{ (items, error) in
            if error != nil {
                //Error Case
                if !silent {
                    self.showError("Error getting Items")
                }
                print("Error getting items")
                
            }else{
                self.items = items!
                self.filterTable(self.filterType)
            }
            self.refreshControl.endRefreshing()
            
            if initialLoad {
                ViewControllerUtils.shared.hideActivityIndicator(uiView: self.view)
//                SVProgressHUD.dismiss()
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.tableView.alpha = 1.0
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        
        return configureCellForIndexPath(cell, indexPath: indexPath)
    }
    
    func configureCellForIndexPath(_ cell: ItemTableViewCell, indexPath: IndexPath) -> ItemTableViewCell {
        let item = items[indexPath.row]

        cell.itemImageView.image = nil
        let url:URL = URL(string: item.imageUrl)!
        if let imageData: NSData = NSData(contentsOf: url) {
            cell.itemImageView.image = UIImage(data: imageData as Data)?.scaleAndCropImage(toSize: cell.itemImageView.bounds.size)
        }
//        cell.itemImageView.setImageWith(url)

        cell.donorAvatar.image = nil;
        let donorAvatarUrl:URL = URL(string: item.donorUrl)!
        if let donorImageData: NSData = NSData(contentsOf: donorAvatarUrl) {
            cell.donorAvatar.image = UIImage(data: donorImageData as Data)?.scaleAndCropImage(toSize: cell.donorAvatar.bounds.size)
        }
/*
        cell.donorAvatar.setImageWith(URLRequest(url: donorAvatarUrl), placeholderImage: nil, success: { (urlRequest: URLRequest, response: HTTPURLResponse?, image: UIImage) -> Void in
            cell.donorAvatar.image = image.resizedImage(to: cell.donorAvatar.bounds.size)

        }, failure: { (urlRequest: URLRequest, response: HTTPURLResponse?, error: NSError) -> Void in
            print("error occured: \(error)")
        } as? (URLRequest, HTTPURLResponse?, Swift.Error) -> Void)
*/
        cell.itemDonorLabel.text = item.donorName
        cell.itemTitleLabel.text = item.name
        cell.itemDescriptionLabel.text = item.itemDescription
        
        if item.quantity > 1 {
            var bidsString = item.currentPrice.map({bidPrice in "$\(bidPrice)"}).joined(separator: ",")
            if (bidsString.isEmpty) {
                bidsString = "(none yet)"
            }

            cell.itemDescriptionLabel.text =
                "\(item.quantity) available! Highest \(item.quantity) bidders win. Current highest bids are \(bidsString)" +
                "\n\n" + cell.itemDescriptionLabel.text!
        }
        cell.delegate = self;
        cell.item = item
        
        var price: Int?
        var lowPrice: Int?

        switch (item.winnerType) {
        case .single:
            price = item.currentPrice.first
            cell.availLabel.text = "1 Available"
        case .multiple:
            price = item.currentPrice.first
            lowPrice = item.currentPrice.last
            cell.availLabel.text = "\(item.quantity) Available"
        }
        
        let bidString = (item.numberOfBids == 1) ? "Bid":"Bids"
//        cell.numberOfBidsLabel.text = "\(item.numberOfBids) \(bidString)"
        cell.numberOfBidsButton.setTitle("\(item.numberOfBids) \(bidString)", for: UIControlState())

        if let topBid = price {
            if let lowBid = lowPrice{
                if item.numberOfBids > 1{
                    cell.currentBidLabel.text = "$\(lowBid)-\(topBid)"
                }else{
                    cell.currentBidLabel.text = "$\(topBid)"
                }
            }else{
                cell.currentBidLabel.text = "$\(topBid)"
            }
        }else{
            cell.currentBidLabel.text = "$\(item.price)"
        }
        
        if !item.currentWinners.isEmpty && item.hasBid{
            if item.isWinning{
                cell.setWinning()
            }else{
                cell.setOutbid()
            }
        }else{
            cell.setDefault()
        }

        let me = Kinvey.sharedClient.activeUser as! CustomUser
        if(me.bidderNumber == "")
        {
            cell.dateLabel.text = "Bidder number not yet assigned."
            cell.bidNowButton.isHidden = true
        }
        else
        {
            if(item.closeTime.timeIntervalSinceNow < 0.0){
                cell.dateLabel.text = "Sorry, bidding has closed"
                cell.bidNowButton.isHidden = true
            }else{
                if(item.openTime.timeIntervalSinceNow < 0.0){
                    //open
                    cell.dateLabel.text = "Bidding closes \(item.closeTime.toStringWithRelativeTime().lowercased())."
                    cell.bidNowButton.isHidden = false
                }else{
                    cell.dateLabel.text = "Bidding opens \(item.openTime.toStringWithRelativeTime().lowercased())."
                    cell.bidNowButton.isHidden = true
                }
            }
        }
        
        return cell
    }

    //Cell Delegate
    func cellDidPressBid(_ item: Item)
    {
        let bidVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BiddingViewController") as? BiddingViewController
        if let biddingVC = bidVC {
            biddingVC.delegate = self
            biddingVC.item = item
            addChildViewController(biddingVC)
            view.addSubview(biddingVC.view)
            biddingVC.didMove(toParentViewController: self)
        }
    }

    //Cell Delegate to view Bid Sheet
    func cellDidPressBidSheet(_ item: Item)
    {
        let bidsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BidSheetViewController") as? BidSheetViewController
        if let bidSheetVC = bidsVC {
            bidSheetVC.delegate = self
            bidSheetVC.item = item
            addChildViewController(bidSheetVC)
            view.addSubview(bidSheetVC.view)
            bidSheetVC.didMove(toParentViewController: self)
        }
    }

    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func logoutPressed(_ sender: AnyObject) {
        if Kinvey.sharedClient.activeUser != nil
        {
            Kinvey.sharedClient.activeUser?.logout()
        }
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }

    @IBAction func infoPressed(_ sender: AnyObject) {
    }

    @IBAction func segmentBarValueChanged(_ sender: AnyObject) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        let segment = sender as! UISegmentedControl
        switch(segment.selectedSegmentIndex) {
        case 0:
          filterTable(.all)
        case 1:
            filterTable(.noBids)
        case 2:
            filterTable(.myItems)
        default:
            filterTable(.all)
        }
    }
    
    func filterTable(_ filter: FilterType) {
        filterType = filter
        self.items = DataManager().sharedInstance.applyFilter(filter)
        self.tableView.reloadData()
    }
    
    func bidOnItem(_ item: Item, amount: Int) {

        ViewControllerUtils.shared.showActivityIndicator(uiView: self.view)
//        SVProgressHUD.show()
        
        DataManager().sharedInstance.bidOn(item, amount: amount) { (success, errorString) -> () in
            if success {
                print("Wohooo")
                self.items = DataManager().sharedInstance.sortedItems
                self.reloadData()
                ViewControllerUtils.shared.hideActivityIndicator(uiView: self.view)
//                SVProgressHUD.dismiss()
            }else{
                self.showError(errorString)
                self.reloadData()
                ViewControllerUtils.shared.hideActivityIndicator(uiView: self.view)
//                SVProgressHUD.dismiss()
            }
        }
    }
    
    
    func showError(_ errorString: String) {
        
        if let _: AnyClass = NSClassFromString("UIAlertController") {
            
                let alertView = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                    print("Ok Pressed")
                })
                
                alertView.addAction(okAction)
                self.present(alertView, animated: true, completion: nil)
        }
        else {
            //make and use a UIAlertView
            let alertView = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
            alertView.show(self, sender: nil)
        }
    }

    ///Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterTable(.all)
        }else{
            filterTable(.search(searchTerm:searchText))
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.segmentBarValueChanged(segmentControl)
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    ///Bidding VC
    func biddingViewControllerDidBid(_ viewController: BiddingViewController, onItem: Item, amount: Int){
        viewController.view.removeFromSuperview()
        bidOnItem(onItem, amount: amount)
    }

    func biddingViewControllerDidCancel(_ viewController: BiddingViewController){
        viewController.view.removeFromSuperview()
    }

    //Bid Sheet VC
    func bidSheetViewControllerDidCancel(_ viewController: BidSheetViewController){
        viewController.view.removeFromSuperview()
    }
}

