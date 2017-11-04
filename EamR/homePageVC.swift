//
//  homePageVC.swift
//  EamR
//
//  Created by Apple on 11/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage
import DatePickerDialog
import CoreLocation

class homePageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, SKSplashDelegate, PayPalPaymentDelegate {
    
    @IBOutlet var topNavView: UIView!
    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var exhibitionTableView: UITableView!
    @IBOutlet var tableBtmSpace: NSLayoutConstraint!
    @IBOutlet var upComeOnGoBtn: UIButton!
    @IBOutlet var bottomBarView: UIView!
    var exhibitionListArray = NSArray()
    @IBOutlet var selectionLabel: UILabel!
    @IBOutlet var selectionBtn: UIButton!
    @IBOutlet var dropDownTableView: UITableView!
    var dropDownArray = [String]()
    var filteredArray = NSArray()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var searchBy: String!
    var exhibitionType: String!
    var lat: String!
    var long: String!
    var splashView: SKSplashView?
    var userName: String!
    var userEmail: String!
    var locationManager:CLLocationManager!
    var location : CLLocation!
    var isSearchBtnPressed : Bool = false
    var isUserBlocked : Bool = false
    var isTableEnd : Bool = false
    
    
    @IBOutlet var datePickerBtn: UIButton!
    
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var payPalConfig = PayPalConfiguration()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isSearchBtnPressed = false
        
        //locationManager = CLLocationManager()
        //locationManager.delegate = self
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.requestAlwaysAuthorization()
        
        // let location: CLLocation? = locationManager.location
        // Configure the new event with information from the location
        // let longitude = location?.coordinate.longitude
        //let latitude = location?.coordinate.latitude
        
        // lat = String(longitude!)
        // long = String(latitude!)
        
        // print(lat, long)
        
        
        
        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        print("Logged in user profile id: \(String(describing: UserDefaults.standard.value(forKey: "ProfileID")))")
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        searchBy = "2";
        exhibitionType = "2"
        getExhibitionList()
        checkUserBlock()
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            splashAnimate()
        }
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.white
        searchBar.layer.borderColor = UIColor.lightGray.cgColor
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.cornerRadius = 5.0
        
        selectionLabel.layer.borderColor = UIColor.lightGray.cgColor
        selectionLabel.layer.borderWidth = 1.0
        selectionLabel.layer.cornerRadius = 5.0
        selectionLabel.textColor = UIColor.lightGray
        
        dropDownTableView.isHidden = true
        dropDownTableView.layer.borderColor = UIColor.red.cgColor
        dropDownTableView.layer.borderWidth = 1.0
        dropDownTableView.layer.cornerRadius = 5.0
        
        dropDownArray = ["Exhibition Name", "Country", "Venue", "Industry", "Dates"]
        
        // Clear rule color ------------------
        exhibitionTableView.separatorColor = UIColor.clear
        upComeOnGoBtn.layer.cornerRadius = 4.0
        
        bottomBarView.isHidden = true
        tableBtmSpace.constant = 0
        
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.font = UIFont.systemFont(ofSize: 11)
        
        //searchBar.returnKeyType = UIReturnKeyType.done
        
        datePickerBtn.isHidden = true
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "EamR"
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        
        payPalConfig.payPalShippingAddressOption = .payPal;
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        PayPalMobile.preconnect(withEnvironment:PayPalEnvironmentProduction)
        //PayPalMobile.preconnect(withEnvironment:PayPalEnvironmentSandbox)
        
        //appDelegate.showProgress(true)
        getExhibitionList()
        checkUserBlock()
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            bottomBarView.isHidden = false
            tableBtmSpace.constant = 52
        }
        else {
            bottomBarView.isHidden = true
            tableBtmSpace.constant = 0
        }
        
        //determineMyCurrentLocation()
    }
    
    
    func splashAnimate() {
        //Twitter style splash
        let twitterSplashIcon = SKSplashIcon(image: UIImage(named: "splashIcon"), animationType: .bounce)
        splashView = SKSplashView(splashIcon: twitterSplashIcon, animationType: .none)
        splashView?.delegate = self
        //Optional -> if you want to receive updates on animation beginning/end
        splashView?.backgroundColor = UIColor.white
        splashView?.animationDuration = 1.5
        //Optional -> set animation duration. Default: 1s
        view.addSubview(splashView!)
        splashView?.startAnimation()
    }
    
    //@IBAction func sideMenuAction(_ sender: Any) {
    //NotificationCenter.default.post(name: KVSideMenu.Notifications.toggleRight, object: self)
    //}
    
    func checkUserBlock() {
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/blocked_users.php")
            let param = ["profile_id": UserDefaults.standard.value(forKey: "ProfileID")!]
            
            print(param)
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                var responseDictionary = NSDictionary()
                responseDictionary = (responseObject as! NSDictionary)
                print("Block user status")
                print(responseDictionary as Any)
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    self.isUserBlocked = false
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                    
                    let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                        self.isUserBlocked = true
                        
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                    
                }
                
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                self.appDelegate.showProgress(false)
                print("Error: \(String(describing: error))")
            })
            
            
        } else {
            
        }
    }
    
    func getExhibitionList() {
        
        
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            
            if (UserDefaults.standard.bool(forKey: "launchedBefore") == true && isTableEnd == false) {
                appDelegate.showProgress(true)
            } else if UserDefaults.standard.bool(forKey: "launchedBefore") == false {
                //appDelegate.showProgress(false)
            }
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/getexhiuser.php")
            let param = ["exhibition_type" : exhibitionType, "userid": UserDefaults.standard.value(forKey: "ProfileID")!]
            
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
                
                self.exhibitionTableView.isHidden = true
                self.isTableEnd = false
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    self.exhibitionListArray = (responseDictionary["categorylistvalues"] as AnyObject) as! NSArray
                    self.filteredArray = self.exhibitionListArray
                    self.exhibitionTableView.isHidden = false
                    self.exhibitionTableView.reloadData()
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                    let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                        
                        self.exhibitionTableView.isHidden = true
                        
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                }
                
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                self.appDelegate.showProgress(false)
                print("Error: \(String(describing: error))")
            })
            
        }
        else {
            
            if (UserDefaults.standard.bool(forKey: "launchedBefore") == true && isTableEnd == false)  {
                appDelegate.showProgress(true)
            } else if UserDefaults.standard.bool(forKey: "launchedBefore") == false {
                //appDelegate.showProgress(false)
            }
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/get_exhib.php")
            let param = ["exhibition_type" : exhibitionType]
            
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
                self.isTableEnd = false
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    self.exhibitionListArray = (responseDictionary["categorylistvalues"] as AnyObject) as! NSArray
                    self.filteredArray = self.exhibitionListArray
                    
                    self.exhibitionTableView.reloadData()
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                    let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                        
                        
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
    
    
    
    
    @IBAction func upComOnGoAction(_ sender: UIButton) {
        if upComeOnGoBtn.tag == 0 {
            upComeOnGoBtn.setTitle("O", for: .normal)
            upComeOnGoBtn.tag = 1
            exhibitionType = "1"
            getExhibitionList()
        }
        else {
            upComeOnGoBtn.setTitle("U", for: .normal)
            upComeOnGoBtn.tag = 0
            exhibitionType = "2"
            getExhibitionList()
        }
    }
    
    
    
    @IBAction func selectionBtnAction(_ sender: UIButton) {
        searchBar.resignFirstResponder()
        if (selectionBtn.tag == 0) {
            selectionBtn.tag = 1
            dropDownTableView.isHidden = false
        } else {
            selectionBtn.tag = 0
            dropDownTableView.isHidden = true
        }
        
    }
    
    // MARK: - Delegate methods (Optional)
    func splashView(_ splashView: SKSplashView, didBeginAnimatingWithDuration duration: Float) {
        print("Started animating from delegate")
        //To start activity animation when splash animation starts
    }
    
    func splashViewDidEndAnimating(_ splashView: SKSplashView) {
        print("Stopped animating from delegate")
        UserDefaults.standard.set(true, forKey: "launchedBefore")
        //To stop activity animation when splash animation ends
    }
    
    
    
    func determineMyCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    // MARK: - UITableViewDataSource
    // number of section(s), now I assume there is only 1 section
    func numberOfSections(in theTableView: UITableView) -> Int {
        return 1
    }
    
    // number of row in the section, I assume there is only 1 row
    func tableView(_ theTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if theTableView == dropDownTableView {
            return self.dropDownArray.count
        } else {
            return self.filteredArray.count
        }
    }
    
    func tableView(_ theTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if theTableView == dropDownTableView {
            var cell: dropDownCell? = (theTableView.dequeueReusableCell(withIdentifier: "ddCell") as? dropDownCell)
            if cell == nil {
                cell = dropDownCell(style: .default, reuseIdentifier: "ddCell")
            }
            
            cell?.ddLabel.text = dropDownArray[indexPath.row]
            
            return cell!
        } else {
            var cell: exhibitionCell? = (theTableView.dequeueReusableCell(withIdentifier: "exhibitionCell") as? exhibitionCell)
            if cell == nil {
                cell = exhibitionCell(style: .default, reuseIdentifier: "exhibitionCell")
            }
            
            let dict = (self.filteredArray[indexPath.row] as AnyObject) as! NSDictionary
            
            //print("Dict: \(dict)")
            
            let startDateStr : String = dict["start_date"] as! String
            let endDateStr : String = dict["end_date"] as! String
            let dateFormatter = DateFormatter()
            let dateFormatter1 = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            let date = dateFormatter.date(from: startDateStr)
            let endDate = dateFormatter.date(from: endDateStr)
            
            dateFormatter1.dateFormat = "dd-MMM-yyyy"
            let startDateF = dateFormatter1.string(from: date!)
            let endDateF = dateFormatter1.string(from: endDate!)
            
            let exhibDate = startDateF + " to " + endDateF
            
            if  dict["payment_status"] as? String == "Paid" {
                cell?.payStatusImg.image = UIImage(named: "paid")
            } else if dict["payment_status"] as? String == "Unpaid" {
                cell?.payStatusImg.image = UIImage(named: "unpaid")
            }  else if dict["payment_status"] as? String == "Free" {
                cell?.payStatusImg.image = UIImage(named: "")
            }
            
            
            //print("Distance: \(dict["distance"] as! String)")
            
            
            cell?.nameLbl.text = dict["name"] as? String
            cell?.countryLbl.text = dict["place"] as? String
            cell?.venuLbl.text = dict["venu"] as? String
            cell?.industryLbl.text = dict["industry"] as? String
            cell?.startDateLbl.text = startDateF  //dict["name"] as? String
            cell?.endDateLbl.text = endDateF
            cell?.descTV.text = dict["shortdes"] as? String
            cell?.newDistLbl.text = "\(dict["distance"] as! String) km"
            //cell?.activity.isHidden = false
            //cell?.activity.startAnimating()
            cell?.exbImageView.sd_setImage(with: URL(string: (dict["image"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
            //cell?.exbImageView.image = UIImage(named:"exhibition.jpg")
            //cell?.activity.stopAnimating()
            //cell?.activity.isHidden = true
            
            
            cell?.descTV.isScrollEnabled = false
            cell?.descTV.isEditable = false
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(Int(indexPath.row)) row")
        
        searchBar.resignFirstResponder()
        
        if tableView == dropDownTableView {
            if indexPath.row == 0 {
                searchBy = "2"
                datePickerBtn.isHidden = true
                self.searchBar.text = ""
                self.searchBar(self.searchBar, textDidChange: "")
            } else if indexPath.row == 1 {
                searchBy = "1"
                datePickerBtn.isHidden = true
                self.searchBar.text = ""
                self.searchBar(self.searchBar, textDidChange: "")
            } else if indexPath.row == 2 {
                searchBy = "3"
                datePickerBtn.isHidden = true
                self.searchBar.text = ""
                self.searchBar(self.searchBar, textDidChange: "")
            } else if indexPath.row == 3 {
                searchBy = "4"
                datePickerBtn.isHidden = true
                self.searchBar.text = ""
                self.searchBar(self.searchBar, textDidChange: "")
            } else if indexPath.row == 4 {
                searchBy = "5"
                datePickerBtn.isHidden = false
                self.searchBar.text = ""
                self.searchBar(self.searchBar, textDidChange: "")
            }
            
            selectionLabel.text = dropDownArray[indexPath.row]
            selectionBtn.tag = 0
            selectionLabel.textColor = UIColor.black
            dropDownTableView.isHidden = true
            
        } else {
            
            print("Exhibition table called")
            
            if (isUserBlocked == true) {
                
                print("Blocked user is true")
                
                let refreshAlert = UIAlertController(title: "Sorry", message: "You have blocked by admin", preferredStyle: UIAlertControllerStyle.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    //let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                    //UserDefaults.standard.set(data, forKey: "payExhib")
                    
                    //self.buyExhibition()
                }))
                
                present(refreshAlert, animated: true, completion: nil)
                
            } else {
                let dict = (self.filteredArray[indexPath.row] as AnyObject) as! NSDictionary
                
                
                if dict["type"] as? String == "Upcoming" {
                    
                    let refreshAlert = UIAlertController(title: "Sorry", message: "You can't attend Upcoming Events", preferredStyle: UIAlertControllerStyle.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        //let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                        //UserDefaults.standard.set(data, forKey: "payExhib")
                        
                        //self.buyExhibition()
                    }))
                    
                    present(refreshAlert, animated: true, completion: nil)
                    
                } else if dict["type"] as? String == "Ongoing" {

                    if UserDefaults.standard.bool(forKey: "loggedIn") == true {
                        
                        if dict["payment_status"] as? String == "Unpaid" {
                            let refreshAlert = UIAlertController(title: "Alert", message: "You have to pay to see this Exhibition.\nDo you want to pay?", preferredStyle: UIAlertControllerStyle.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                                let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                                UserDefaults.standard.set(data, forKey: "payExhib")
                                
                                self.buyExhibition()
                            }))
                            
                            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                                print("Handle Cancel Logic here")
                            }))
                            
                            present(refreshAlert, animated: true, completion: nil)
                        } else {
                            
                            UserDefaults.standard.set(dict["sno"] as? String, forKey: "recentExhibId")
                            //if UserDefaults.standard.bool(forKey: "loggedIn") == true {
                            addRecentView()
                            trackExhibition()
                            //}
                            
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "exhibDetail")
                            UserDefaults.standard.set(dict["sno"] as? String, forKey: "selExhibId")
                            
                            
                            tableView.deselectRow(at: indexPath, animated: false)
                            let infoController: exhibitionDetailsVC = storyboard?.instantiateViewController(withIdentifier: "exhibitionDetailsVC") as! exhibitionDetailsVC
                            self.navigationController?.pushViewController(infoController, animated: true)
                        }
                        
                    }
                    else {
                        
                        if dict["payment_status"] as? String == "Unpaid" {
                            let refreshAlert = UIAlertController(title: "Alert", message: "Please login to purchase this Exhibition's Entrance Fee", preferredStyle: UIAlertControllerStyle.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                                //let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                                //UserDefaults.standard.set(data, forKey: "payExhib")
                                
                                //self.buyExhibition()
                            }))
                            
                            
                            present(refreshAlert, animated: true, completion: nil)
                        } else {
                            
                            UserDefaults.standard.set(dict["sno"] as? String, forKey: "recentExhibId")
                            if UserDefaults.standard.bool(forKey: "loggedIn") == true {
                                addRecentView()
                                trackExhibition()
                            }
                            
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "exhibDetail")
                            UserDefaults.standard.set(dict["sno"] as? String, forKey: "selExhibId")
                            
                            tableView.deselectRow(at: indexPath, animated: false)
                            let infoController: exhibitionDetailsVC = storyboard?.instantiateViewController(withIdentifier: "exhibitionDetailsVC") as! exhibitionDetailsVC
                            self.navigationController?.pushViewController(infoController, animated: true)
                        }
                        
                    }
                }
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == dropDownTableView {
            return 30
        } else {
            return 150
        }
    }
    
    
    
    func buyExhibition() {
        
        let data = UserDefaults.standard.value(forKey: "payExhib")
        let payExhibDict: NSDictionary = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        
        
        let subTotal = NSDecimalNumber(string: payExhibDict["exhibition_price"]! as? String)
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subTotal, withShipping: nil, withTax: tax)
        let total: NSDecimalNumber? = subTotal.adding(tax)
        let payment = PayPalPayment()
        payment.amount = total!
        payment.currencyCode = "USD"
        payment.shortDescription = (payExhibDict["name"]! as? String)!
        payment.paymentDetails = paymentDetails
        
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self as PayPalPaymentDelegate)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            print("Payment not processalbe: \(payment)")
        }
    }
    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            //let paymentResultDic = completedPayment.confirmation as NSDictionary
            
            self.updatedBoughtExhib()
            
            
        })
    }
    
    
    func updatedBoughtExhib() {
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/purchase_exhib.php")
        
        
        let data = UserDefaults.standard.value(forKey: "payExhib")
        let payExhibDict: NSDictionary = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        
        let param: [String: Any] = ["userid" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "exhibition" : (payExhibDict["sno"]! as? String)!]
        
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
                let alertController = UIAlertController(title: "Success", message:"Entrance Fee Paid Successfully", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    
                    self.getExhibitionList()
                    
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            } else {
                let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    
                    
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Error: \(String(describing: error))")
        })
    }
    
    func addRecentView() {
        //self.appDelegate.showProgress(true)
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/recent_view.php")
        
        let param: [String: Any] = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "exhibition_id" : UserDefaults.standard.value(forKey: "recentExhibId")!]
        
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
                print("recent view updated")
            } else {
                print("EamR Failure")
                print("recent view not updated")
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Error: \(String(describing: error))")
        })
        
    }
    
    func trackExhibition() {
        
        print("Track Exhibition Called!!")
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/visit_exhibition.php")
        
        let param: [String: Any] = ["user_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "exhibition_id" : UserDefaults.standard.value(forKey: "recentExhibId")!]
        
        print(param, (url!.absoluteString))
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            
            let responseDictionary = (responseObject as! NSDictionary)
            print("Tracking Updated updated")
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
    
    
    func searchByCountryName(){
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/search_exhibition.php")
        
        let param: [String: Any] = ["search_exhibiton_name" : searchBar.text!, "exhibition_type": exhibitionType]
        
        print(param, (url!.absoluteString))
        
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
                
                if ((responseDictionary["categorylistvalues"] as? NSNull) != nil) {
                    let alertController = UIAlertController(title: "Sorry", message:"There is no Exhibition in given name", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else {
                    self.exhibitionListArray = (responseDictionary["categorylistvalues"] as AnyObject) as! NSArray
                    self.filteredArray = self.exhibitionListArray
                    self.updatedSearchedExhibition()
                    self.exhibitionTableView.reloadData()
                    
                }
            } else if (responseDictionary["status"] as! Int == 0) {
                
                let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    
                    self.updatedSearchedExhibition()
                    
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
                
            }
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Favorite Exhibition Error: \(String(describing: error))")
        })
    }
    
    
    func updatedSearchedExhibition() {
        
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_search_exhibition.php")
            
            
            let loginType: String = UserDefaults.standard.string(forKey: "userLoginType") as String!
            
            if (loginType == "1") {
                userName = UserDefaults.standard.value(forKey: "UserFullName")! as! String
                userEmail = UserDefaults.standard.value(forKey: "UserEmail")! as! String
            } else if (loginType == "2") {
                userName = UserDefaults.standard.value(forKey: "ggUserFullName")! as! String
                userEmail = UserDefaults.standard.value(forKey: "ggUserEmail")! as! String
            }
            
            let param: [String: Any] = ["search_exhibiton_name" : searchBar.text!, "user_id":UserDefaults.standard.value(forKey: "ProfileID")!, "user_name":userName, "user_email":userEmail]
            
            print("Update search Exhibitions: \(param)")
            
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
    
    
    @IBAction func datePickerAction(_ sender: Any) {
        let currentDate = Date()
        var dateComponents = DateComponents()
        var dateComponents1 = DateComponents()
        dateComponents.month = -12
        dateComponents1.month = +12
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        let dateTwo = Calendar.current.date(byAdding: dateComponents1, to: currentDate)
        
        DatePickerDialog().show(title: "Search here by Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: threeMonthAgo, maximumDate: dateTwo, datePickerMode: .date) { (date) in
            if let dt = date {
                let dateFormatter = DateFormatter()
                //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                //let date = dateFormatter.date(from: dt)
                
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let newDate = dateFormatter.string(from: dt)
                
                //self.searchBar.becomeFirstResponder()
                self.searchBar.text = newDate
                self.searchBar(self.searchBar, textDidChange: newDate)
                self.updatedSearchedExhibition()
                
            }
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearchBtnPressed = true
        
        let searchText: String = searchBar.text!
        
        if (searchBy == "2") {
            //let searchStr:String = searchBar.text!
            //searchByCountryName()
            let searchPredicate = NSPredicate(format: "name CONTAINS[C] %@", searchText)
            self.filteredArray = (self.exhibitionListArray as NSArray).filtered(using: searchPredicate) as NSArray
            print("Searched Array: \(self.filteredArray)")
            if(self.filteredArray.count == 0) {
                let alertController = UIAlertController(title: "Sorry", message:"No Exhibition Found", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    self.searchBar.text = ""
                    self.searchBar.resignFirstResponder()
                    //self.updatedSearchedExhibition()
                    self.getExhibitionList()
                    
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }

            updatedSearchedExhibition()
        } else if searchBy == "1" {
            let searchPredicate = NSPredicate(format: "place CONTAINS[C] %@", searchText)
            self.filteredArray = (self.exhibitionListArray as NSArray).filtered(using: searchPredicate) as NSArray
            print("Searched Array: \(self.filteredArray)")
            if(self.filteredArray.count == 0) {
                let alertController = UIAlertController(title: "Sorry", message:"No Exhibition Found", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    
                    self.searchBar.text = ""
                    self.searchBar.resignFirstResponder()

                    //self.updatedSearchedExhibition()
                    self.getExhibitionList()
                    
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }

            updatedSearchedExhibition()
        }else if searchBy == "3" {
            let searchPredicate = NSPredicate(format: "venu CONTAINS[C] %@", searchText)
            self.filteredArray = (self.exhibitionListArray as NSArray).filtered(using: searchPredicate) as NSArray
            print("Searched Array: \(self.filteredArray)")
            
            if(self.filteredArray.count == 0) {
                let alertController = UIAlertController(title: "Sorry", message:"No Exhibition Found", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    
                    self.searchBar.text = ""
                    self.searchBar.resignFirstResponder()

                    //self.updatedSearchedExhibition()
                    self.getExhibitionList()
                    
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
            updatedSearchedExhibition()
        } else if searchBy == "4" {
            let searchPredicate = NSPredicate(format: "industry CONTAINS[C] %@", searchText)
            self.filteredArray = (self.exhibitionListArray as NSArray).filtered(using: searchPredicate) as NSArray
            print("Searched Array: \(self.filteredArray)")
            if(self.filteredArray.count == 0) {
                let alertController = UIAlertController(title: "Sorry", message:"No Exhibition Found", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    
                    self.searchBar.text = ""
                    self.searchBar.resignFirstResponder()

                    //self.updatedSearchedExhibition()
                    self.getExhibitionList()
                    
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }

            updatedSearchedExhibition()
        } else if searchBy == "5" {
            let searchPredicate = NSPredicate(format: "start_date CONTAINS[C] %@ OR end_date CONTAINS[C] %@", searchText, searchText)
            self.filteredArray = (self.exhibitionListArray as NSArray).filtered(using: searchPredicate) as NSArray
            print("Searched Array: \(self.filteredArray)")
            if(self.filteredArray.count == 0) {
                let alertController = UIAlertController(title: "Sorry", message:"No Exhibition Found", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    
                    self.searchBar.text = ""
                    self.searchBar.resignFirstResponder()

                    //self.updatedSearchedExhibition()
                    self.getExhibitionList()
                    
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }

            updatedSearchedExhibition()
        }
        
        exhibitionTableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //dropDownTableView.isHidden = true
        if (searchText.characters.count ) == 0 {
            self.getExhibitionList()
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            
        }
        
        //exhibitionTableView.reloadData()
    }
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        dropDownTableView.isHidden = true
        self.searchBar.endEditing(true)
        
        let offset: CGPoint = exhibitionTableView.contentOffset
        let bounds: CGRect = exhibitionTableView.bounds
        let size: CGSize = exhibitionTableView.contentSize
        let inset: UIEdgeInsets = exhibitionTableView.contentInset
        let y = Float(offset.y + bounds.size.height - inset.bottom)
        let h = Float(size.height)

        let reload_distance: Float = 10
        if y > h + reload_distance {
            
            isTableEnd = true
            print("Table view scrolled to end")
            
            getExhibitionList()
        }
        
        /*if (self.exhibitionTableView.contentOffset.y >= (self.exhibitionTableView.contentSize.height - self.exhibitionTableView.bounds.size.height))
        {
            // Don't animate
             print("Table view scrolled to end 222")
        }*/
        
    }
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.searchBar.resignFirstResponder
        self.searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBy = "1";
        exhibitionType = "2"
        getExhibitionList()
        //exhibitionTableView.reloadData()
    }
    
    
    
    @IBAction func chatAction(_ sender: Any) {
        
        
        if (isUserBlocked == true) {
            
            print("Blocked user is true")
            
            let refreshAlert = UIAlertController(title: "Sorry", message: "You have blocked by admin", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                //let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                //UserDefaults.standard.set(data, forKey: "payExhib")
                
                //self.buyExhibition()
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let UIVC: chatListVC? = storyboard.instantiateViewController(withIdentifier: "chatListVC") as? chatListVC
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionFade
            //transition.subtype = kCATransitionFromTop;
            navigationController?.view.layer.add(transition, forKey: kCATransition)
            navigationController?.pushViewController(UIVC!, animated: false)
            
        }
        
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        if (isUserBlocked == true) {
            
            print("Blocked user is true")
            
            let refreshAlert = UIAlertController(title: "Sorry", message: "You have blocked by admin", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                //let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                //UserDefaults.standard.set(data, forKey: "payExhib")
                
                //self.buyExhibition()
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
        } else {
            
            UIPasteboard.general.string = "www.perfectrdp.us/eamr.life"
            
            let shareTitle: String = "Its very useful app. I am using it, download and use it!!"
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
        
    }
    
    @IBAction func cartAction(_ sender: Any) {
        
        if (isUserBlocked == true) {
            
            print("Blocked user is true")
            
            let refreshAlert = UIAlertController(title: "Sorry", message: "You have blocked by admin", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                //let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                //UserDefaults.standard.set(data, forKey: "payExhib")
                
                //self.buyExhibition()
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let UIVC: myCartVC? = storyboard.instantiateViewController(withIdentifier: "myCartVC") as? myCartVC
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionFade
            //transition.subtype = kCATransitionFromTop;
            navigationController?.view.layer.add(transition, forKey: kCATransition)
            navigationController?.pushViewController(UIVC!, animated: false)
        }
        
        
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
    
    // Exhibition: ---
    // Exhibitor: Logo, Country, Star Rating
    // Products:
    //  View More By Company Name: Need Service
    //  Similar Products: Need Service
    //  Fast Delivery Date:
    //  Normal Delivery Date:
    //  Cash on Delivery Available or Not:
    
}


