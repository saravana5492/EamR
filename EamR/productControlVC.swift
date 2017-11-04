//
//  productControlVC.swift
//  EamR
//
//  Created by Apple on 16/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import FloatRatingView
import SDWebImage

class productControlVC: UIViewController, FloatRatingViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, MXSegmentedPagerDelegate, MXSegmentedPagerDataSource {

    // Control page allocations ***
    @IBOutlet var navProductLabel: UILabel!
    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var contView: UIView!
    @IBOutlet var addToCartView: UIView!
    @IBOutlet var bottomBarView: UIView!
    @IBOutlet var viewBtmSpace: NSLayoutConstraint!
    var segmentedPager = MXSegmentedPager()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    var productIdStr: String!
    var profileIdStr: String!
    var prodQntyStr: String!
    var prodPriceStr: String!
    var eventId: String!
    
    var selectedProduct = NSDictionary()
    var simProductsArray = NSArray()
    var simProdImagesArray = NSArray()
    var loadingDit = NSDictionary()
    
    @IBOutlet var productOverView: UIView!
    @IBOutlet var productFullDetail: UIView!
    @IBOutlet var productReviewView: UIView!
    
    @IBOutlet var chatView: UIView!
    @IBOutlet var shareView: UIView!
    @IBOutlet var cartView: UIView!

    // Product Overview page allocation ***
    @IBOutlet var prodDetView: UIView!
    @IBOutlet var prodName: UILabel!
    @IBOutlet var prodPrice: UILabel!
    @IBOutlet var prodImageView: UIImageView!
    @IBOutlet var firstReviewLbl: UILabel!
    @IBOutlet var giftImageView: UIImageView!
    @IBOutlet var downloadImageView: UIImageView!
    @IBOutlet var viewMoreByCMBtn: UIButton!
    @IBOutlet var otherOptCV: UICollectionView!
    @IBOutlet var fastDelivDateLbl: UILabel!
    @IBOutlet var normalDelivDateLbl: UILabel!
    @IBOutlet var cashOnDelivLbl: UILabel!
    @IBOutlet var miniProdDetailView: UITextView!
    @IBOutlet var viewAllProdDetBtn: UIButton!
    @IBOutlet var overAllRatingView: FloatRatingView!
    @IBOutlet var overAllRatingCount: UILabel!
    @IBOutlet var writeReviewBtn: UIButton!
    @IBOutlet var reviewTextLbl: UILabel!
    @IBOutlet var reviewrNameLbl: UILabel!
    @IBOutlet var reviewOrderNumLbl: UILabel!
    @IBOutlet var reviewRatingView: FloatRatingView!
    @IBOutlet var viewAllRevRatBtn: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    var firstReviewDict = NSDictionary()
    

    //Product Full Detail control ***
    @IBOutlet var allProdDetView: UIView!
    @IBOutlet var allProdImageView: UIImageView!
    @IBOutlet var allProdImageName: UILabel!
    @IBOutlet var allProdImagePrice: UILabel!
    @IBOutlet weak var allProdDetailLbl: UILabel!
    @IBOutlet weak var allProdScrollView: UIScrollView!
    @IBOutlet weak var allProdImageLblHeight: NSLayoutConstraint!
    
    //Product Review control ***
    var productReviewsArray = NSArray()
    @IBOutlet var reviewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scrolling segment control ***
        self.contView.addSubview(segmentedPager)
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.selectionIndicatorColor = UIColor(red: 254 / 255.0, green: 62 / 255.0, blue: 47 / 255.0, alpha: 1.0)
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 254 / 255.0, green: 62 / 255.0, blue: 47 / 255.0, alpha: 1.0)]
        segmentedPager.segmentedControl.selectedSegmentIndex = 0
        segmentedPager.pager.gutterWidth = 20
        
        segmentedPager.delegate = self
        segmentedPager.dataSource = self
        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Hide Navigation bar control ***
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Bottom tool bar control ***
        //bottomBarView.isHidden = true
        //viewBtmSpace.constant = 0

        chatView.isHidden = true
        shareView.isHidden = true
        cartView.isHidden = true
        
        // Product Detail view Dictionary ***
        let data = UserDefaults.standard.value(forKey: "productDetail")
        self.loadingDit = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        self.selectedProduct = self.loadingDit
        
        self.simProductsArray = self.selectedProduct["similar_products"] as! NSArray
        self.simProdImagesArray = self.selectedProduct.value(forKeyPath: "similar_products.photo1") as! NSArray
        
        print("Images Array: \(simProdImagesArray)")
        
        // Assign Navigation Head ***
        navProductLabel.text = self.selectedProduct["name"] as? String
        self.addToCartView.layer.cornerRadius = 3.0
        
        // Load Product Over view details ***
        loadProductDetails()
        
        // Load all product details ***
        loadAllProductDetail()

        // Get Product Reviews ***
        getProductReviews()
        // Get product reviews Web service ***
    }

    override func viewWillAppear(_ animated: Bool) {
        //super.viewDidAppear(true)
        getProductReviews()
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
        segmentedPager.frame.size.width = contView.frame.size.width
        segmentedPager.frame.size.height = contView.frame.size.height - 8.0
        super.viewWillLayoutSubviews()
    }
    
    
    //-mark <MXSegmentedPagerDelegate>
    func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelectViewWithTitle title: String) {
        if title == "Reviews" {
            // Get productDetails ***
            //self.appDelegate.showProgress(true)
            //getProductReviews()
            addToCartView.isHidden = true
        } else {
            addToCartView.isHidden = false
        }
        print("\(title) page selected.")
    }
    
    //-mark <MXSegmentedPagerDataSource>
    func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        return 3
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        if index < 3 {
            return ["Overview", "Product Details", "Reviews"][index]
        }
        return "Page \(Int(index))"
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        
        if index < 3 {
            return [self.productOverView, self.productFullDetail, self.productReviewView][index]
        }
        return [self.productOverView, self.productFullDetail, self.productReviewView][index]
    }
    
// -------------------- Product Overview ------------------
    
    func loadProductDetails(){
        
        giftImageView.image = giftImageView.image?.withRenderingMode(.alwaysTemplate)
        giftImageView.tintColor = UIColor(red: 247 / 255.0, green: 62 / 255.0, blue: 47 / 255.0, alpha: 1.0)
        viewAllProdDetBtn.layer.cornerRadius = 3.0
        viewAllRevRatBtn.layer.cornerRadius = 3.0
        writeReviewBtn.layer.cornerRadius = 3.0
        
        // Required float rating view params
        self.overAllRatingView.emptyImage = UIImage(named: "not_selected_star")
        self.overAllRatingView.fullImage = UIImage(named: "selected_star")
        // Optional params
        self.overAllRatingView.delegate = self
        self.overAllRatingView.contentMode = UIViewContentMode.scaleAspectFit
        self.overAllRatingView.maxRating = 5
        self.overAllRatingView.minRating = 1
        self.overAllRatingView.rating = self.selectedProduct["overall_rating"]! as! Float
        self.overAllRatingView.editable = false
        self.overAllRatingView.halfRatings = false
        self.overAllRatingView.floatRatings = false
        
        

        var price = (self.selectedProduct["price"] as? String)! + " " as String
        price += (self.selectedProduct["currency"] as? String)!
        
        prodName.text = self.selectedProduct["name"] as? String
        prodPrice.text = price
        prodImageView.sd_setImage(with: URL(string: (self.selectedProduct["photo1"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        miniProdDetailView.text = self.selectedProduct["explanation"] as? String
        
        //let stri: String = String(self.selectedProduct["total_reviews"])
        let reviewCount:String! = "(\(self.selectedProduct["total_reviews"]!))"
        
        overAllRatingCount.text = reviewCount
        
    }
    
    func loadReviewDetails() {
        
        // Required float rating view params
        self.reviewRatingView.emptyImage = UIImage(named: "not_selected_star")
        self.reviewRatingView.fullImage = UIImage(named: "selected_star")
        // Optional params
        self.reviewRatingView.delegate = self
        self.reviewRatingView.contentMode = UIViewContentMode.scaleAspectFit
        self.reviewRatingView.maxRating = 5
        self.reviewRatingView.minRating = 1
        //let starRat: Float = (self.firstReviewDict["review_rating"] as! NSString).floatValue
        //print("FLoat Star Value: \(starRat)")
        self.reviewRatingView.rating = 3
        self.reviewRatingView.editable = false
        self.reviewRatingView.halfRatings = false
        self.reviewRatingView.floatRatings = false
        
        self.reviewTextLbl.text = self.firstReviewDict["reviewdesc"] as! String!
        self.reviewrNameLbl.text = self.firstReviewDict["user_name"] as! String!
        self.reviewOrderNumLbl.text = "EX4578SA"
        
    }
    
    /*@IBAction func addToWishlistAction(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            self.appDelegate.showProgress(true)
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_wishlist.php")
            
            let param: [String: Any] = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "productid" : self.selectedProduct["sno"] as! String]
            
            print(param, (url!.absoluteString))
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                let responseDictionary = (responseObject as! NSDictionary)
                print("Add to wishlist Exhibition Response: \(responseDictionary as Any)")
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
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
                print("Add to wishList Exhibition Error: \(String(describing: error))")
            })
        }
        else {
            
            let alertController = UIAlertController(title: "Failure", message:"Please Login to add Wishlist", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
        }
        
    }*/
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.simProdImagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? UICollectionViewCell)
        let prodImage: UIImageView? = (cell?.viewWithTag(10) as? UIImageView)
        
        prodImage?.sd_setImage(with: URL(string: (self.simProdImagesArray[indexPath.row] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        //prodImage?.image = UIImage(named: "exhibition.jpg")
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedProduct = self.simProductsArray[indexPath.row] as! NSDictionary
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        loadProductDetails()
        loadAllProductDetail()
        getProductReviews()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    @IBAction func viewMorebyCMAction(_ sender: Any) {
    }
    
    @IBAction func viewAllProdsAction(_ sender: Any) {
        
        segmentedPager.segmentedControl.selectedSegmentIndex = 1
        segmentedPager.pager.showPage(at: segmentedPager.segmentedControl.selectedSegmentIndex, animated: true)
        
    }
    
    @IBAction func writeReviewAction(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            UserDefaults.standard.set("product", forKey:"reviewFor")
            
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
    
    @IBAction func viewAllRevRatAction(_ sender: Any) {
        
        segmentedPager.segmentedControl.selectedSegmentIndex = 2
        segmentedPager.pager.showPage(at: segmentedPager.segmentedControl.selectedSegmentIndex, animated: true)
        
    }
    
//--------------------- Product Full Detail ____-------------------
    
    func loadAllProductDetail() {
        allProdImageName.text = self.selectedProduct["name"] as? String
        var price = (self.selectedProduct["price"] as? String)! + " " as String
        price += (self.selectedProduct["currency"] as? String)!
        allProdImagePrice.text = price
        allProdImageView.sd_setImage(with: URL(string: (self.selectedProduct["photo1"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        allProdDetailLbl.text = self.selectedProduct["explanation"] as? String
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.allProdScrollView.contentSize = (CGSize(width: UIScreen.main.bounds.width, height: self.allProdDetailLbl.frame.size.height ))
        
        print("Label height \(self.allProdDetailLbl.frame.size.height)")
    }

// -------------------- Product Review Action -------------------
    
    func getProductReviews(){
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/product_review_list.php")
        
        let param: [String: Any] = ["product_id" : self.selectedProduct["sno"] as! String]
        
        print(param, (url!.absoluteString))
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            
            self.reviewTextLbl.isHidden = false
            self.reviewrNameLbl.isHidden = false
            self.reviewOrderNumLbl.isHidden = false
            // Required float rating view params
            self.reviewRatingView.isHidden = false

            let responseDictionary = (responseObject as! NSDictionary)
            print("Product Review Count!")
            print(responseDictionary as Any)
            
            if (responseDictionary["status"] as AnyObject).integerValue == 1 {
                print("EamR Success")
                self.productReviewsArray = (responseDictionary["review_list"] as AnyObject) as! NSArray
                
                DispatchQueue.main.async { () -> Void in
                    self.firstReviewDict = (self.productReviewsArray[0] as AnyObject) as! NSDictionary
                    
                    self.loadReviewDetails()
                }
                
                self.reviewTableView.reloadData()
                
            } else {
                self.reviewTextLbl.isHidden = true
                self.reviewrNameLbl.isHidden = true
                self.reviewOrderNumLbl.isHidden = true
                // Required float rating view params
                self.reviewRatingView.isHidden = true

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
        return self.productReviewsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier: String = "reviewCell"
        var cell: reviewCell? = (tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? reviewCell)
        if cell == nil {
            cell = reviewCell(style: .default, reuseIdentifier: CellIdentifier)
        }
        let dict = (self.productReviewsArray[indexPath.row] as AnyObject) as! NSDictionary
        
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
            UserDefaults.standard.set("product", forKey:"reviewFor")
            
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

    
// -------------------- Tool Bar buttons Action ------------------
    
    @IBAction func addToCartAction(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "loggedIn") == false {
            let alertController = UIAlertController(title: "Sorry", message:"Please login to purchase products", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
        }
        else {
            
            self.appDelegate.showProgress(true)
            
            productIdStr = self.selectedProduct["sno"] as! String
            profileIdStr = UserDefaults.standard.value(forKey: "ProfileID") as! String
            eventId = UserDefaults.standard.value(forKey: "selExhibId") as! String
            prodQntyStr = "1"
            prodPriceStr = self.selectedProduct["price"] as! String

            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_cart.php")
            
            //let rateInt : String = self.selectedProduct["price"] as! String
            
            //let prodPriceFlt: Float = Float(rateInt)! * 2
            
            let param = ["profile_id" : profileIdStr, "product_id" : productIdStr, "product_qty" : prodQntyStr, "product_price" : prodPriceStr, "event_id": eventId]
            
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
                    let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        self.navigationController?.popViewController(animated: true)
                    })
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
    

    
    @IBAction func homeAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: homePageVC? = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? homePageVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func topBackAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func chatAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: chatListVC? = storyboard.instantiateViewController(withIdentifier: "chatListVC") as? chatListVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)

        
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
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
    
    @IBAction func myCartAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: myCartVC? = storyboard.instantiateViewController(withIdentifier: "myCartVC") as? myCartVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)
        
    }

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
