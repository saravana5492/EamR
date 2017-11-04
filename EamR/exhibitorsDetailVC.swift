//
//  exhibitorsDetailVC.swift
//  EamR
//
//  Created by Apple on 15/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage
import FloatRatingView

import AVFoundation
import AVKit



class exhibitorsDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FloatRatingViewDelegate, UITableViewDelegate, UITableViewDataSource, MXSegmentedPagerDelegate, MXSegmentedPagerDataSource {

    // Control Page allocation ***
    @IBOutlet var navExhibitorLabel: UILabel!
    @IBOutlet var menuBtn: UIButton!
    var selectedExhibitor = NSDictionary()
    @IBOutlet var bottomBarView: UIView!
    @IBOutlet var viewBtmSpace: NSLayoutConstraint!
    @IBOutlet var containView: UIView!
    @IBOutlet var shopProductsView: UIView!
    @IBOutlet var exhibitorDetailView: UIView!
    @IBOutlet var exhibitorReviewView: UIView!
    @IBOutlet var chatRoomView: UIView!
    var segmentedPager = MXSegmentedPager()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var labelHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var chatView: UIView!
    @IBOutlet var shareView: UIView!
    @IBOutlet var cartView: UIView!
    
    // Shoping products control ***
    @IBOutlet var companyLogo: UIImageView!
    @IBOutlet var companyName: UILabel!
    @IBOutlet var companyCountry: UILabel!
    @IBOutlet var gridBoxView: UICollectionView!
    @IBOutlet var shortByBtn: UIButton!
    @IBOutlet var changeViewBtn: UIButton!
    @IBOutlet var changeViewImage: UIImageView!
    @IBOutlet var prodScrollView: UIScrollView!
    var exhibitorEmail = String()
    var productsArray = NSArray()
    var productId: String!
    var profileId: String!
    var prodQnty: String!
    var prodPrice: String!
    var eventId: String!
    var listOn: Bool = false
    var sortByStr: String!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredArray =  NSArray()
    var userName: String!
    var userEmail: String!
    var searchTextStr: String!
    var isTableEnd : Bool = false
    
    
    @IBOutlet var popUpView: UIView!

    // Exhibitors Detail Page allocation ***
    @IBOutlet weak var infoComImage: UIImageView!
    @IBOutlet weak var infoComLogo: UIImageView!
    @IBOutlet weak var infoComName: UILabel!
    @IBOutlet weak var infoComCountry: UILabel!
    @IBOutlet weak var infoComDesc: UILabel!
    @IBOutlet var starRatingView: FloatRatingView!
    @IBOutlet var infoVideoView: UIView!
    var avPlayer: AVPlayer?

    var player: AVPlayer!
    var avpController = AVPlayerViewController()

    // Exhibitor Review Page ***
    var exhibitorReviewsArray = NSArray()
    @IBOutlet var reviewTableView: UITableView!

    // Chat room allocation
    @IBOutlet var chatRoomBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Scrolling segment control ***
        self.containView.addSubview(segmentedPager)
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.selectionIndicatorColor = UIColor(red: 254 / 255.0, green: 62 / 255.0, blue: 47 / 255.0, alpha: 1.0)
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 254 / 255.0, green: 62 / 255.0, blue: 47 / 255.0, alpha: 1.0)]
        segmentedPager.segmentedControl.selectedSegmentIndex = 0
        segmentedPager.pager.gutterWidth = 20
        
        segmentedPager.delegate = self
        segmentedPager.dataSource = self
        
        popUpView.layer.masksToBounds = false
        popUpView.layer.shadowColor = UIColor.black.cgColor
        popUpView.layer.shadowOpacity = 0.5
        popUpView.layer.shadowOffset = CGSize(width: -1, height: 1)
        popUpView.layer.shadowRadius = 1
        
        //popUpView.layer.shadowPath = UIBezierPath(rect: self.popUpView.bounds).cgPath
        //popUpView.layer.shouldRasterize = true
        //popUpView.layer.rasterizationScale = scalb ? UIScreen.main.scale : 1

        popUpView.isHidden = true
        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        searchTextStr = ""
        
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.font = UIFont.systemFont(ofSize: 10)
        
        // Hide navigation bar control ***
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        // Selected Exhibitor dictionary ***
        let data = UserDefaults.standard.value(forKey: "exhibitorDetail")
        self.selectedExhibitor = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        
        print("Selected Exhibitor: \(self.selectedExhibitor)")
        
        // Load Navigation bar and header label ***
        navExhibitorLabel.text = self.selectedExhibitor["name"] as? String
        companyName.text = self.selectedExhibitor["name"] as? String
        companyCountry.text = self.selectedExhibitor["exhibior_country"] as? String
        self.exhibitorEmail = (self.selectedExhibitor["email"] as? String)!
        
        
        companyLogo.sd_setImage(with: URL(string: (self.selectedExhibitor["logo"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        
        // Shortby button design ***
        shortByBtn.layer.borderColor = UIColor.black.cgColor
        shortByBtn.layer.borderWidth = 0.5
        shortByBtn.layer.cornerRadius = 5.0

        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.white
        searchBar.layer.borderColor = UIColor.lightGray.cgColor
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.cornerRadius = 5.0
        
        // Bottom tool bar view control ***
        //bottomBarView.isHidden = true
        //viewBtmSpace.constant = 0
        
        chatView.isHidden = true
        shareView.isHidden = true
        cartView.isHidden = true

        
        // Webservice for getting product details ***
        self.appDelegate.showProgress(true)
        sortByStr = ""
        getProducts()
        
        // Load exhibitor full details ***
        loadExhibitorData()

        // Webservice for getting reviews for this Exhibitor ***
        getExhibitorReviews()

    }
    
    @IBAction func selectionBtnAction(_ sender: UIButton) {
        if (shortByBtn.tag == 0) {
            shortByBtn.tag = 1
            popUpView.isHidden = false

        } else {
            shortByBtn.tag = 0
            popUpView.isHidden = true
        }
    }

    @IBAction func sortByAction(_ sender: UIButton) {
        
        if sender.tag == 10 {
            popUpView.isHidden = true
            shortByBtn.tag = 0
            self.appDelegate.showProgress(true)
            sortByStr = "a_z"
            getProducts()
        } else if sender.tag == 11 {
            popUpView.isHidden = true
            shortByBtn.tag = 0
            self.appDelegate.showProgress(true)
            sortByStr = "z_a"
            getProducts()
        } else if sender.tag == 12 {
            popUpView.isHidden = true
            shortByBtn.tag = 0
            self.appDelegate.showProgress(true)
            sortByStr = "1_9"
            getProducts()
        } else if sender.tag == 13 {
            popUpView.isHidden = true
            shortByBtn.tag = 0
            self.appDelegate.showProgress(true)
            sortByStr = "9_1"
            getProducts()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first

        if touch?.view != self.popUpView {
            self.popUpView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getExhibitorReviews()
         self.popUpView.isHidden = true
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            //bottomBarView.isHidden = false
            //viewBtmSpace.constant = 52
            chatView.isHidden = false
            shareView.isHidden = false
            cartView.isHidden = false

        }
        else {
            //bottomBarView.isHidden = true
            //viewBtmSpace.constant = 0
            chatView.isHidden = true
            shareView.isHidden = true
            cartView.isHidden = true

        }
    }
    

    
// ---------------------- Segmented Control __________________________
    
    override func viewWillLayoutSubviews() {
        segmentedPager.frame = CGRect()
        segmentedPager.frame.origin.x = 0.0
        segmentedPager.frame.origin.y = 0.0
        segmentedPager.frame.size.width = containView.frame.size.width
        segmentedPager.frame.size.height = containView.frame.size.height - 8.0
        super.viewWillLayoutSubviews()
    }
    
    
    //-mark <MXSegmentedPagerDelegate>
    func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelectViewWithTitle title: String) {
        if title == "Reviews" {
            // Get productDetails ***
            //self.appDelegate.showProgress(true)
            //getExhibitorReviews()
        } else {
        }

        print("\(title) page selected.")
    }
    
    //-mark <MXSegmentedPagerDataSource>
    func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        return 4
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        if index < 4 {
            return ["Shop", "Info", "Reviews", "Chat"][index]
        }
        return "Page \(Int(index))"
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        
        if index < 4 {
            return [ self.shopProductsView, self.exhibitorDetailView, self.exhibitorReviewView, self.chatRoomView][index]
        }
        return [self.shopProductsView, self.exhibitorDetailView, self.exhibitorReviewView, self.chatRoomView][index]
    }


    func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
//----------------------- Shopping Products -------------------
    
    func getProducts() {
        
        print("Products List Updated!!")
        
        let prodUrl = "http://perfectrdp.us/eamr.life/exhibition_webservice/get_products.php"
        
        let url = URL(string: prodUrl)
        
        let param = ["exhibitor_email": self.selectedExhibitor["email"]!, "sort_by" : sortByStr, "srch_kwd": searchTextStr]
        
        print("Product Request Parameter: \(param)")
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
           // print(responseObject as Any)
            let responseDictionary = (responseObject as! NSDictionary)
            
            //print("Get product response: \(responseDictionary)")
            
            if (responseDictionary["status"] as AnyObject).integerValue == 1 {
                //print("EamR Success")
                self.productsArray = (responseDictionary["categorylistvalues"] as AnyObject) as! NSArray
                self.filteredArray = self.productsArray
                self.gridBoxView.reloadData()
                //self.gridBoxView.reloadSections(IndexSet(index: 0))
                
            } else if (responseDictionary["status"] as AnyObject).integerValue == 0 {
                //print("EamR Failure")
                let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    
                    
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            //print("Error: \(String(describing: error))")
        })
        
    }
    
    // MARK: <UICollectionViewDataSource>
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if listOn == true {
            let reuseIdentifier: String = "singCell"
            let cell: singleCell? = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? singleCell
            
            let dict = (self.filteredArray[indexPath.row] as AnyObject) as! NSDictionary
            
            //print("Dict: \(dict)")
            
            var price = (dict["price"] as? String)! + " " as String
            price += (dict["currency"] as? String)!
            
            cell?.prodName?.text = dict["name"] as? String
            cell?.prodPrice?.text = price
            cell?.prodImage?.sd_setImage(with: URL(string: (dict["photo1"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
            cell?.prodDesc?.text = dict["explanation"] as? String
            cell?.addToCartBtn.tag = indexPath.row
            cell?.addToCartBtn.addTarget(self, action: #selector(addToCartAction(_:)), for: .touchUpInside)
            
            cell?.addToCartView?.layer.cornerRadius = 5.0
            cell?.giftImageView.image = cell?.giftImageView.image?.withRenderingMode(.alwaysTemplate)
            cell?.giftImageView.tintColor = UIColor(red: 247 / 255.0, green: 62 / 255.0, blue: 47 / 255.0, alpha: 1.0)
            
            return cell!
        } else {
            let reuseIdentifier: String = "multCell"
            let cell: multiCell? = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? multiCell
            
            let dict = (self.filteredArray[indexPath.row] as AnyObject) as! NSDictionary
            
            //print("Dict: \(dict)")
            
            cell?.prodName?.text = dict["name"] as? String
            
            var price = (dict["price"] as? String)! + " " as String
            price += (dict["currency"] as? String)!
            
            cell?.prodPrice?.text = price
            cell?.prodImage?.sd_setImage(with: URL(string: (dict["photo1"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
            
            cell?.addToCartView?.layer.cornerRadius = 5.0
            cell?.giftImageView?.image = cell?.giftImageView?.image?.withRenderingMode(.alwaysTemplate)
            cell?.giftImageView?.tintColor = UIColor(red: 247 / 255.0, green: 62 / 255.0, blue: 47 / 255.0, alpha: 1.0)
            cell?.addToCartBtn.tag = indexPath.row
            cell?.addToCartBtn.addTarget(self, action: #selector(addToCartAction(_:)), for: .touchUpInside)
            
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dict = (self.filteredArray[indexPath.row] as AnyObject) as! NSDictionary
        
        print("Selected Exhibitor: \(dict)")
        
        UserDefaults.standard.set(dict["sno"] as? String, forKey: "recentExhibId")
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            trackProduct()
        }

        UserDefaults.standard.set("list", forKey: "productFrom")
        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
        UserDefaults.standard.set(data, forKey: "productDetail")
        
        let infoController: productControlVC? = storyboard?.instantiateViewController(withIdentifier: "productControlVC") as? productControlVC
        navigationController?.pushViewController(infoController!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if listOn == true {
            return CGSize(width: gridBoxView.frame.size.width - 30, height: 140)
        }
        else {
            return CGSize(width: (gridBoxView.frame.size.width / 3) - 30, height: 150)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if listOn == true {
            return UIEdgeInsetsMake(5, 5, 10, 5)
        } else {
            return UIEdgeInsetsMake(10, 10, 10,10)
        }
    }
    
    // change background color when user touches cell
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray
    }
    
    // change background color back when user releases touch
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.white
    }
    
    
    func trackProduct() {
        
        print("Track Product Called!!")
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/recent_view_product.php")
        
        let param: [String: Any] = ["user_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "product_id" : UserDefaults.standard.value(forKey: "recentExhibId")!]
        
        print(param, (url!.absoluteString))
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            
            let responseDictionary = (responseObject as! NSDictionary)
            print("Tracking Exhibitor Updated updated")
            print(responseDictionary as Any)
            
            if (responseDictionary["status"] as AnyObject).integerValue == 1 {
                print("EamR Success")
                print("Tracking Product Updated updated")
            } else {
                print("EamR Failure")
                print("Tracking Product Not updated")
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Tracking Product Error: \(String(describing: error))")
        })
    }

    
    @IBAction func gridListToggle(_ sender: Any) {
        if changeViewBtn.tag == 0 {
            listOn = true
            changeViewBtn.tag = 1
            changeViewImage.image = UIImage(named: "listView")
            gridBoxView.reloadData()
        }
        else {
            listOn = false
            changeViewBtn.tag = 0
            changeViewImage.image = UIImage(named: "gridView")
            gridBoxView.reloadData()
        }
    }
    
    @IBAction func addToCartAction(_ sender: UIButton) {
        
        if UserDefaults.standard.bool(forKey: "loggedIn") == false {
            let alertController = UIAlertController(title: "Sorry", message:"Please login to purchase products", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
        }
        else {
            self.appDelegate.showProgress(true)

            let tag = sender.tag
            
            let cartDict = (self.productsArray[tag] as AnyObject) as! NSDictionary
            
            productId = cartDict["sno"] as! String
            profileId = UserDefaults.standard.value(forKey: "ProfileID") as! String
            eventId = UserDefaults.standard.value(forKey: "selExhibId") as! String
            prodQnty = "1"
            prodPrice = cartDict["price"] as! String
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_cart.php")
            
            //let rateInt : String = self.selectedProduct["price"] as! String
            
            //let prodPriceFlt: Float = Float(rateInt)! * 2
            
            let param = ["profile_id" : profileId, "product_id" : productId, "product_qty" : prodQnty, "product_price" : prodPrice, "event_id" : eventId]
            
            print(param)
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                print("Add to cart Response: \(responseObject as Any)")
                let responseDictionary = (responseObject as! NSDictionary)
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler:nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                    print("EamR Failure")
                    let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                }
                
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                self.appDelegate.showProgress(false)
                print("Add to cart Error: \(String(describing: error))")
            })
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        searchTextStr = searchBar.text!
        
        //let searchPredicate = NSPredicate(format: "name CONTAINS[C] %@", searchText)
        //self.filteredArray = (self.productsArray as NSArray).filtered(using: searchPredicate) as NSArray
        //print("Searched Array: \(self.filteredArray)")
        self.appDelegate.showProgress(true)
        getProducts()
        updatedSearchedProduct()
        
        gridBoxView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //dropDownTableView.isHidden = true
        if (searchText.characters.count ) == 0 {
            searchTextStr = ""
    //searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            self.getProducts()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder
        //dropDownTableView.isHidden = true
        self.searchBar.endEditing(true)
        
        let offset: CGPoint = gridBoxView.contentOffset
        let bounds: CGRect = gridBoxView.bounds
        let size: CGSize = gridBoxView.contentSize
        let inset: UIEdgeInsets = gridBoxView.contentInset
        let y = Float(offset.y + bounds.size.height - inset.bottom)
        let h = Float(size.height)
        
        let reload_distance: Float = 10
        if y > h + reload_distance {
            
            isTableEnd = true
            print("Table view scrolled to end")
            
            getProducts()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        //searchBar.text = ""
        searchTextStr = ""
        getProducts()
        //exhibitionTableView.reloadData()
    }
    
    func updatedSearchedProduct() {
        
        
         if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_search_product.php")
            
            
            let loginType: String = UserDefaults.standard.string(forKey: "userLoginType") as String!
            
            if (loginType == "1") {
                userName = UserDefaults.standard.value(forKey: "UserFullName")! as! String
                userEmail = UserDefaults.standard.value(forKey: "UserEmail")! as! String
            } else if (loginType == "2") {
                userName = UserDefaults.standard.value(forKey: "ggUserFullName")! as! String
                userEmail = UserDefaults.standard.value(forKey: "ggUserEmail")! as! String
            }
            
            let param: [String: Any] = ["search_name" : searchBar.text! , "product_price":"0.0",  "user_id":UserDefaults.standard.value(forKey: "ProfileID")!, "user_name":userName, "user_email":userEmail]
            
            print("Update search Product: \(param)")
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                let responseDictionary = (responseObject as! NSDictionary)
                print("Favorite Exhibition Response: \(responseDictionary as Any)")
                
                self.gridBoxView.isHidden = false
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    //
                } else if (responseDictionary["status"] as! Int == 0) {
                }
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                self.appDelegate.showProgress(false)
                print("Favorite Exhibition Error: \(String(describing: error))")
            })

         } else {
            
        }
    
        
    }
    
// ------------------ Exhibitor detail loading -----------------
    
    func  loadExhibitorData() {
        
        // Required float rating view params
        self.starRatingView.emptyImage = UIImage(named: "not_selected_star")
        self.starRatingView.fullImage = UIImage(named: "selected_star")
        // Optional params
        self.starRatingView.delegate = self
        self.starRatingView.contentMode = UIViewContentMode.scaleAspectFit
        self.starRatingView.maxRating = 5
        self.starRatingView.minRating = 1
        
        let starRat: Float = self.selectedExhibitor["exhibior_star_rating"]! as! Float
        self.starRatingView.rating = starRat
        self.starRatingView.editable = false
        self.starRatingView.halfRatings = false
        self.starRatingView.floatRatings = false
        
        //let moviePath = Bundle.main.path(forResource: "abc.mp4", ofType: nil)
        
        
        
        
        let videoString: String = self.selectedExhibitor["exhibior_upload_video_file"]! as! String

        if (videoString.characters.count != 0) {
            
            infoVideoView.isHidden = false
            infoComImage.isHidden = true
            
            let videoURL = URL(string: videoString)
            
            self.player = AVPlayer(url: videoURL!)
            self.avpController = AVPlayerViewController()
            self.avpController.player = self.player
            self.addChildViewController(avpController)
            self.infoVideoView.addSubview(avpController.view)
            self.avpController.view.frame = CGRect(x: 0, y: 0, width: self.infoVideoView.frame.size.width, height: self.infoVideoView.frame.size.height)
            //player.play()

        } else if (videoString.characters.count == 0) {
            infoComImage.isHidden = false
            infoVideoView.isHidden = true
        }
        
        
        infoComName.text = self.selectedExhibitor["name"] as? String
        infoComCountry.text = self.selectedExhibitor["exhibior_country"] as? String //self.selectedExhibitor["name"] as? String
        infoComDesc.text = self.selectedExhibitor["explanation"] as? String
        //infoComName.text = self.selectedExhibitor["name"] as? String
        //infoComName.text = self.selectedExhibitor["name"] as? String
        infoComImage.sd_setImage(with: URL(string: (self.selectedExhibitor["image"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        infoComLogo.sd_setImage(with: URL(string: (self.selectedExhibitor["logo"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollView.contentSize = (CGSize(width: UIScreen.main.bounds.width, height: 380 + self.infoComDesc.frame.size.height))
    }
    
// ------------------ Exhibitors Reviews ------------------------
    
    func getExhibitorReviews() {
        
        self.appDelegate.showProgress(true)

        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/exhibitor_review_list.php")
        
        let param: [String: Any] = ["exhibitor_id" : self.selectedExhibitor["sno"] as! String]
        
        print(param, (url!.absoluteString))
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            
            let responseDictionary = (responseObject as! NSDictionary)
            print(responseDictionary as Any)
            
            if (responseDictionary["status"] as AnyObject).integerValue == 1 {
                print("EamR Success")
                self.exhibitorReviewsArray = (responseDictionary["review_list"] as AnyObject) as! NSArray
                
                self.reviewTableView.reloadData()
                
            } else {
                print("EamR Failure")
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Error: \(String(describing: error))")
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exhibitorReviewsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier: String = "reviewCell"
        var cell: reviewCell? = (tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? reviewCell)
        if cell == nil {
            cell = reviewCell(style: .default, reuseIdentifier: CellIdentifier)
        }
        let dict = (self.exhibitorReviewsArray[indexPath.row] as AnyObject) as! NSDictionary
        
        print("Dict: \(dict)")
        let rateInt : String = dict["review_rating"] as! String
        let dateStr : String = dict["createddate"] as! String
        
        print("Review Date \(dateStr)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        let date = dateFormatter.date(from: dateStr)
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        let newDate = dateFormatter.string(from: date!)
        
        cell?.reviewText?.text = dict["reviewdesc"] as? String
        
        if ((dict["user_name"] as? NSNull) != nil) {
            cell?.reviewerName?.text = "userName"
        } else {
            cell?.reviewerName?.text = dict["user_name"] as? String
        }
        cell?.revieweHead?.text = dict["review_name"] as? String
        cell?.reviewDate?.text = newDate
        //cell?.reviewImageView.sd_setImage(with: URL(string: (dict["user_image"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        
        if ((dict["user_image"] as? NSNull) != nil) {
            cell?.reviewImageView?.image = UIImage(named:"profilePlaceholder")
        } else {
            cell?.reviewImageView.sd_setImage(with: URL(string: (dict["user_image"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        }

        
        cell?.starRating.emptyImage = UIImage(named: "not_selected_star")
        cell?.starRating.fullImage = UIImage(named: "selected_star")
        // Optional params
        cell?.starRating.delegate = self
        cell?.starRating.contentMode = UIViewContentMode.scaleAspectFit
        cell?.starRating.maxRating = 5
        cell?.starRating.minRating = 1
        cell?.starRating.rating = Float(rateInt)!
        cell?.starRating.editable = false
        cell?.starRating.halfRatings = false
        cell?.starRating.floatRatings = false
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    // when user tap the row, what action you want to perform
    func tableView(_ theTableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    @IBAction func addNewReviewAction(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            UserDefaults.standard.set("exhibitor", forKey:"reviewFor")
            
            let infoController: newReviewVC? = storyboard?.instantiateViewController(withIdentifier: "newReviewVC") as? newReviewVC
            navigationController?.pushViewController(infoController!, animated: true)
        }
        else {
            
            let alertController = UIAlertController(title: "Failure", message:"Please Login to write your review", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
        }
        
    }
    
// ------------------- Chat Room Action -------------------
    @IBAction func joinChatRoomAction(_ sender: UIButton) {
    
        if UserDefaults.standard.bool(forKey: "loggedIn") == false {
            let alertController = UIAlertController(title: "Sorry", message:"Please login to join chat room!", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
        }
        else {
            self.appDelegate.showProgress(true)
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/join_chat_group.php")
            
            let param: [String: Any] = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "exhibitor_id" : self.selectedExhibitor["sno"] as! String]
            
            print(param, (url!.absoluteString))
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                
                let responseDictionary = (responseObject as! NSDictionary)
                print(responseDictionary as Any)
                
                if (responseDictionary["status"] as AnyObject).integerValue == 1 {
                    print("EamR Success")
                    
                    let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        
                        //let data = NSKeyedArchiver.archivedData(withRootObject: self.selectedExhibitor)
                        //UserDefaults.standard.set(data, forKey: "selectedChat")
                        
                        //let infoController: chatPageVC? = self.storyboard?.instantiateViewController(withIdentifier: "chatPageVC") as? chatPageVC
                        //self.navigationController?.pushViewController(infoController!, animated: true)
                        
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else {
                    print("EamR Failure")
                    
                    let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        //self.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                }
                
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                self.appDelegate.showProgress(false)
                print("Error: \(String(describing: error))")
            })
        }
    }
    
// ------------------- Tool bar buttons action ------------------
    

    
    @IBAction func homeBtnAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: homePageVC? = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? homePageVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func topBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chatAction(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: chatListVC? = storyboard.instantiateViewController(withIdentifier: "chatListVC") as? chatListVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)

        
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        
        UIPasteboard.general.string = "www.perfectrdp.us/eamr.life"
        
        let shareTitle: String = "Its very useful app. I am using it, download use it!!"
        let itemsToShare: [Any] = [shareTitle]
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.postToTwitter]
        //if iPhone
        if UI_USER_INTERFACE_IDIOM() == .phone {
            present(activityVC, animated: true, completion: { _ in })
        }
        else {
            // Change Rect to position Popover
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.sourceView = view
            activityVC.popoverPresentationController?.sourceRect = view.frame
            present(activityVC, animated: true, completion: { _ in })
        }
    }
    
    @IBAction func myCartAction(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: myCartVC? = storyboard.instantiateViewController(withIdentifier: "myCartVC") as? myCartVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)
        
    }

    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
