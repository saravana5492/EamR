//
//  exhibitionDetailsVC.swift
//  EamR
//
//  Created by Apple on 14/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//
/*
import UIKit
import SDWebImage
import AFNetworking
import FloatRatingView

class exhibitionDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FloatRatingViewDelegate, MXSegmentedPagerDelegate, MXSegmentedPagerDataSource {
    
    // Control page allocation ****
    @IBOutlet var navExhibNameLbl: UILabel!
    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var homeBtn: UIButton!
    @IBOutlet var contView: UIView!
    var selectedExhibition = NSDictionary()
    @IBOutlet var viewBtmSpace: NSLayoutConstraint!
    @IBOutlet var bottomBarView: UIView!
    @IBOutlet var reviewView: UIView!
    @IBOutlet var exhibitorsListView: UIView!
    @IBOutlet var exhibitionInfoView: UIView!
    var segmentedPager = MXSegmentedPager()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var chatView: UIView!
    @IBOutlet var shareView: UIView!
    @IBOutlet var cartView: UIView!
    
    var exhibDict = [String : NSArray]()
    var exhibArray = NSArray()
    var filteredArray = NSArray()
    var searchedArray = NSArray()
    
    @IBOutlet weak var searchIconIV: UIImageView!
    
    @IBOutlet weak var searchIconBtn: UIButton!
    // Exhibitors page allocation ***
    @IBOutlet var exhibitorsListTableView: UITableView!
    var exhibitorsListArray = NSArray()
    @IBOutlet weak var searchBar: UISearchBar!
    var isSearchExhib: Bool = false
    
    // Exhibition page info allocation ***
    @IBOutlet var exhibitionImageView: UIImageView!
    @IBOutlet var exbName: UILabel!
    @IBOutlet var exbDate: UILabel!
    @IBOutlet var exbCountry: UILabel!
    @IBOutlet var exbVenu: UILabel!
    @IBOutlet var exbIndus: UILabel!
    @IBOutlet var starRatingView: FloatRatingView!
    @IBOutlet var exbDesc: UILabel!
    @IBOutlet var exbOrganizer: UILabel!
    @IBOutlet var makeFavBtn: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var exhibTimerView: UIView!
    @IBOutlet var minuteLbl: UILabel!
    @IBOutlet var daysLbl: UILabel!
    @IBOutlet var secondsLbl: UILabel!
    @IBOutlet var hoursLbl: UILabel!
    var userName:String!
    var userEmail:String!
    
    let formatter = DateFormatter()
    //let userCalendar = NSCalendar.current
    
    /*let requestedComponent: NSCalendar.Unit = [
     NSCalendar.Unit.month,
     NSCalendar.Unit.day,
     NSCalendar.Unit.hour,
     NSCalendar.Unit.minute,
     NSCalendar.Unit.second
     ]*/
    
    // Reviews page allocation ***
    
    var exhibitionReviewsArray = NSArray()
    @IBOutlet var reviewTableView: UITableView!
    @IBOutlet var addNewReview: UIButton!
    
    
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
        
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.white
        searchBar.layer.borderColor = UIColor.lightGray.cgColor
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.cornerRadius = 5.0
        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        // Hide navigation control ****
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Bottom bar view control ***
        //bottomBarView.isHidden = true
        //viewBtmSpace.constant = 0
        chatView.isHidden = true
        shareView.isHidden = true
        cartView.isHidden = true
        
        // Selected Exhibtion Dictionary ***
        //self.selectedExhibition = UserDefaults.standard.value(forKey: "exhibDetail") as! NSDictionary
        
        let data = UserDefaults.standard.value(forKey: "exhibDetail")
        self.selectedExhibition = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        
        // Loading Navigation name on navigation label ***
        navExhibNameLbl.text = self.selectedExhibition["name"] as? String
        
        //Web service for Exhibitors List ***
        appDelegate.showProgress(true)
        getExhibitorsList()
        
        //Timer setup ***
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(printTimer), userInfo: nil, repeats: true)
        
        timer.fire()
        
        // Display Exhibition data ****
        loadExhibitionData()
        
        printTimer()
        //Web service for Reviews List ***
        getExhibitionReviews()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Segment Origin: \(segmentedPager.frame.origin.y)")
        print("ContView Origin: \(contView.frame.origin.y)")
        
        getExhibitionReviews()
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
        //searchBar.isHidden = true
        //isSearchExhib = false
        
        //searchIconIV.image = UIImage(named: "searchIcon")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.scrollView.contentSize = (CGSize(width: UIScreen.main.bounds.width, height: 478 + self.exbDesc.frame.size.height + self.exbIndus.frame.size.height))
    }
    
    
    // ---------------------- Search Bar Setup ----------------------
    
    
    @IBAction func searchIconTapped(_ sender: UIButton) {
        
        if (isSearchExhib == true) {
            isSearchExhib = false
            searchBar.resignFirstResponder()
            searchBar.isHidden = true
            searchIconIV.image = UIImage(named: "searchIcon")
            searchBar.text = ""
            getExhibitorsList()
            
        } else if (isSearchExhib == false) {
            
            isSearchExhib = true
            searchBar.isHidden = false
            
            searchIconIV.image = UIImage(named: "canIcon")
        }
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.characters.count ) == 0 {
            self.filteredArray = self.exhibArray
        }
        
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        getExhibitorsList()
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        isSearchExhib = false
        searchBar.text = ""
        searchIconIV.image = UIImage(named: "searchIcon")
        getExhibitorsList()
        
        self.view.endEditing(true)
    }
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.searchBar.resignFirstResponder
        self.searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearchExhib = false
        self.filteredArray = self.exhibArray
        exhibitorsListTableView.reloadData()
        
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
        if (title == "Info" || title == "Reviews") {
            
            //searchIconBtn.isHidden = true
            //searchIconIV.isHidden = true
            
        } else {
            //searchIconBtn.isHidden = false
            //searchIconIV.isHidden = false
        }
        
        print("\(title) page selected.")
    }
    
    //-mark <MXSegmentedPagerDataSource>
    func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        return 3
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        if index < 3 {
            return ["Booths", "Info", "Reviews"][index]
        }
        return "Page \(Int(index))"
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        
        if index < 3 {
            return [self.exhibitorsListView, self.exhibitionInfoView, self.reviewView][index]
        }
        return [self.exhibitorsListView, self.exhibitionInfoView, self.reviewView][index]
    }
    
    
    //------------------------Exhibtitors List ------------------------
    
    func getExhibitorsList() {
        
        self.appDelegate.showProgress(true)
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/exhibitor_sort_by_name.php")
        
        let param: [String: Any] = ["event_id" : self.selectedExhibition["sno"] as! String, "srch_kwd": searchBar.text!]
        
        print(param)
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            
            let responseDictionary = (responseObject as! NSDictionary)
            print(responseDictionary as Any)
            
            self.exhibDict.removeAll()
            print("Exhib Dictionary: \(self.exhibDict)")
            
            if (responseDictionary["status"] as AnyObject).integerValue == 1 {
                print("EamR Success")
                self.exhibitorsListArray = (responseDictionary["exhibitor_list"] as AnyObject) as! NSArray
                
                print("Check this one")
                print(self.exhibitorsListArray)
                
                if (self.exhibitorsListArray.count != 0){
                    
                    for var i in (0..<self.exhibitorsListArray.count)
                    {
                        let tempDict = self.exhibitorsListArray[i] as! NSDictionary
                        print(tempDict)
                        
                        self.exhibDict[Array(tempDict)[0].key as! String] = Array(tempDict)[0].value as? NSArray
                        print(self.exhibDict)
                    }
                    
                    
                    self.exhibArray = (Array(self.exhibDict.keys) as NSArray).sorted { ($0 as! String).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending } as NSArray
                    print("Final Exhibitors Array TWO: \(self.exhibArray)")
                    
                    self.filteredArray = self.exhibArray
                    
                    self.exhibitorsListTableView.reloadData()
                } else {
                    if (self.isSearchExhib == true) {
                        
                        self.updatedSearchedExhibitor()
                    }
                    
                }
                
            } else {
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            
            
            print("Error: \(String(describing: error))")
        })
    }
    
    
    func updatedSearchedExhibitor() {
        
        print("updatedSearchedExhibitor Updated")
        
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
    
    // ---------------- Reviews & Ratings -------------------
    
    func getExhibitionReviews() {
        
        //appDelegate.showProgress(true)
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/exhibition_review_list.php")
        
        let param: [String: Any] = ["exhibition_id" : self.selectedExhibition["sno"] as! String]
        
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
                self.exhibitionReviewsArray = (responseDictionary["review_list"] as AnyObject) as! NSArray
                
                self.reviewTableView.reloadData()
                
            } else {
                print("EamR Failure")
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            
            print("Error: \(String(describing: error))")
        })
        
    }
    
    @IBAction func addNewReviewAction(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            UserDefaults.standard.set("exhibition", forKey:"reviewFor")
            
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
    
    // ---------------- Exhibitor lost and Review List loading --------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == exhibitorsListTableView {
            return self.filteredArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == exhibitorsListTableView {
            return self.filteredArray[section] as? String
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == exhibitorsListTableView {
            let sectionTitle: String = (self.filteredArray[section] as? String)!
            let sectionContent: NSArray = self.exhibDict[sectionTitle]!
            
            return sectionContent.count
        } else {
            return self.exhibitionReviewsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == exhibitorsListTableView {
            let cell: exhibitorsCell? = (tableView.dequeueReusableCell(withIdentifier: "exhibitorsCell") as? exhibitorsCell)
            
            
            let sectionTitle: String = (self.filteredArray[indexPath.section] as? String)!
            let sectionContent: NSArray = self.exhibDict[sectionTitle]!
            
            let dict = (sectionContent[indexPath.row] as AnyObject) as! NSDictionary
            
            print("Exhibitors Dict: \(dict)")
            
            
            cell?.nameLbl?.text = dict["name"] as? String
            cell?.countryLbl?.text = "Singapore" //dict["name"] as? String
            cell?.venuLbl?.text = "Singapore" //dict["name"] as? String
            cell?.descLabel?.text = dict["shortdes"] as? String
            
            
            if dict["image"] is NSNull {
                // do something with null JSON value here
                cell?.exbiImageView.image = UIImage(named: "placeholder")
            } else {
                cell?.exbiImageView?.sd_setImage(with: URL(string: (dict["image"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
            }
            
            
            return cell!
            
        } else {
            let CellIdentifier: String = "reviewCell"
            var cell: reviewCell? = (tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? reviewCell)
            if cell == nil {
                cell = reviewCell(style: .default, reuseIdentifier: CellIdentifier)
            }
            
            let dict = (self.exhibitionReviewsArray[indexPath.row] as AnyObject) as! NSDictionary
            
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
            //cell?.reviewerName?.text = dict["user_name"] as? String
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
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView == exhibitorsListTableView {
            return self.exhibArray as? [String]
        } else {
            return nil
        }
    }
    
    // MARK: - UITableViewDelegate
    // when user tap the row, what action you want to perform
    func tableView(_ theTableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if theTableView == exhibitorsListTableView {
            theTableView.deselectRow(at: indexPath, animated: false)
            
            let sectionTitle: String = (self.filteredArray[indexPath.section] as? String)!
            let sectionContent: NSArray = self.exhibDict[sectionTitle]!
            
            
            let dict = (sectionContent[indexPath.row] as AnyObject) as! NSDictionary
            
            print("Selected Exhib Dict: \(dict)")
            
            UserDefaults.standard.set(dict["sno"] as? String, forKey: "recentExhibId")
            if UserDefaults.standard.bool(forKey: "loggedIn") == true {
                trackExhibitor()
            }
            
            
            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
            UserDefaults.standard.set(data, forKey: "exhibitorDetail")
            
            
            let infoController: exhibitorsDetailVC? = storyboard?.instantiateViewController(withIdentifier: "exhibitorsDetailVC") as? exhibitorsDetailVC
            navigationController?.pushViewController(infoController!, animated: true)
        } else {
            // Reviews no action ---
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == exhibitorsListTableView {
            return 128
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == exhibitorsListTableView {
            return 128
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func trackExhibitor() {
        
        print("Track Exhibitor Called!!")
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/visit_exhibitor.php")
        
        let param: [String: Any] = ["user_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "exhibitor_id" : UserDefaults.standard.value(forKey: "recentExhibId")!]
        
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
                print("Tracking Updated updated")
            } else {
                print("EamR Failure")
                print("Tracking Not updated")
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Tracking Error: \(String(describing: error))")
        })
    }
    
    
    //----------------------Load Exhibition Detail -----------------
    
    
    func printTimer() {
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss a"
        
        let dateStr: String = self.selectedExhibition["end_date"] as! String
        let dateTimeStr: String = dateStr + " a"
        
        
        let startTime = Date()
        let endTime = formatter.date(from: dateTimeStr)
        
        let timeDifference = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from:startTime, to:endTime!)
        
        daysLbl.text = "\(timeDifference.day!)"
        hoursLbl.text = "\(timeDifference.hour!)"
        minuteLbl.text = "\(timeDifference.minute!)"
        secondsLbl.text = "\(timeDifference.second!)"
    }
    
    func loadExhibitionData() {
        
        // Required float rating view params
        self.starRatingView.emptyImage = UIImage(named: "not_selected_star")
        self.starRatingView.fullImage = UIImage(named: "selected_star")
        // Optional params
        self.starRatingView.delegate = self
        self.starRatingView.contentMode = UIViewContentMode.scaleAspectFit
        self.starRatingView.maxRating = 5
        self.starRatingView.minRating = 1
        self.starRatingView.rating = (self.selectedExhibition["overall_rating"] as? Float)!
        self.starRatingView.editable = false
        self.starRatingView.halfRatings = false
        self.starRatingView.floatRatings = false
        
        
        let startDateStr : String = self.selectedExhibition["start_date"] as! String
        let endDateStr : String = self.selectedExhibition["end_date"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        let date = dateFormatter.date(from: startDateStr)
        let endDate = dateFormatter.date(from: endDateStr)
        
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let startDateF = dateFormatter.string(from: date!)
        let endDateF = dateFormatter.string(from: endDate!)
        
        let exhibDate = startDateF + " to " + endDateF
        
        exbName.text = self.selectedExhibition["name"] as? String
        exbDate.text = exhibDate
        exbCountry.text = self.selectedExhibition["place"] as? String
        exbVenu.text = self.selectedExhibition["venu"] as? String
        exbIndus.text = self.selectedExhibition["industry"] as? String
        exbDesc.text = self.selectedExhibition["explanation"] as? String
        exbOrganizer.text = self.selectedExhibition["organizer_name"] as? String
        exhibitionImageView.sd_setImage(with: URL(string: (self.selectedExhibition["image"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        //exhibitionImageView.image = UIImage(named:"exhibition.jpg")
        
        self.makeFavBtn.layer.cornerRadius = 3.0
        
    }
    
    
    
    // Make favorite exhibition action ***
    @IBAction func makeFavoriteAction(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            self.appDelegate.showProgress(true)
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_favourite.php")
            
            let param: [String: Any] = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "exhibitionid" : self.selectedExhibition["sno"] as! String]
            
            print(param, (url!.absoluteString))
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                let responseDictionary = (responseObject as! NSDictionary)
                print("Add to Favorite Exhibition Response: \(responseDictionary as Any)")
                
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
                print("Add to Favorite Exhibition Error: \(String(describing: error))")
            })
        }
        else {
            
            let alertController = UIAlertController(title: "Failure", message:"Please Login to make this favorite", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
        }
        
    }
    
    
    //@IBAction func sideMenuAction(_ sender: Any) {
    //NotificationCenter.default.post(name: KVSideMenu.Notifications.toggleRight, object: self)
    // }
    
    
    @IBAction func homeBtnAction(_ sender: UIButton) {
        
        //self.changeSideMenuViewControllerRoot(KVSideMenu.RootsIdentifiers.firstViewController)
        
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
    
}*/
