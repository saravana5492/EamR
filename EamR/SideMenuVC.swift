//
//  SideMenuVC.swift
//  EamR
//
//  Created by Apple on 13/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import AFNetworking
import SDWebImage


class SideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Logged in view ---
    @IBOutlet var loggedInView: UIView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userImageOuterView: UIView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var menuTableView: UITableView!
    
    //Login view ----
    @IBOutlet var logInView: UIView!
    @IBOutlet var dialCodeLabel: UILabel!
    @IBOutlet var enterNumBtn: UIButton!
    @IBOutlet var flagImageView: UIImageView!
    var menuCountArray = [String]()
    var dictCodes = [AnyHashable: Any]()
    var isUserBlocked: Bool = false

    @IBOutlet var loginViewWidth: NSLayoutConstraint!
    @IBOutlet var loggedInViewWidth: NSLayoutConstraint!
    
    @IBOutlet var loggedInViewTrailing: NSLayoutConstraint!
    @IBOutlet var logInViewTrailing: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Profile Image Circle design -----------
        userImageOuterView.layer.cornerRadius = 50.0
        userImageView.layoutIfNeeded()
        userImageView.layer.cornerRadius = 48.0
        userImageView.clipsToBounds = true
        // Menu Cell Identifiers ------------
        menuCountArray = ["one", "two", "three", "four", "five", "six", "seven", "eight"]
        
        // Menu table designing -------------
        menuTableView.separatorColor = UIColor.clear
        menuTableView.isScrollEnabled = true
        
        dictCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        
        //self.enterNumBtn.isUserInteractionEnabled = true
        logInView.isHidden = false
        //scrollView.isScrollEnabled = false
        loggedInView.isHidden = true
        
        //getProfileDetails()
        checkUserBlock()

        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            
            let bundle = "assets.bundle/"
            self.flagImageView.image = UIImage(named: bundle + countryCode.lowercased() + ".png")
            
            dialCodeLabel.text = dictCodes[countryCode] as? String
            
        } else {
            let bundle = "assets.bundle/"
            let countCode = "in"
            self.flagImageView.image = UIImage(named: bundle + countCode.lowercased() + ".png")
            dialCodeLabel.text = "+91"
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        //super.viewDidAppear(true)
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            logInView.isHidden = true
            loggedInView.isHidden = false
            logInViewTrailing.constant = UIScreen.main.bounds.width
            getProfileDetails()
            checkUserBlock()
        }
        else {
            logInView.isHidden = false
            logInViewTrailing.constant = 0
            loggedInView.isHidden = true
        }
    }
    
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
                let responseDictionary = (responseObject as! NSDictionary)
                print("Block user status")
                print(responseDictionary as Any)
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    self.isUserBlocked = false
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                
                    let refreshAlert = UIAlertController(title: "Sorry", message: "You have blocked by admin! Do you want to signout?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        
                        UserDefaults.standard.set(false, forKey: "loggedIn")
                        
                        // Clear User Details
                        let defaults = UserDefaults.standard
                        let dictionary = defaults.dictionaryRepresentation()
                        dictionary.keys.forEach { key in
                            defaults.removeObject(forKey: key)
                        }
                        defaults.synchronize()
                        
                        if (UserDefaults.standard.string(forKey: "logInFrom") == "fbLogin") {
                            let login = FBSDKLoginManager()
                            login.logOut()
                        }
                        else if (UserDefaults.standard.string(forKey: "logInFrom") == "googleLogin") {
                            GIDSignIn.sharedInstance().signOut()
                        }
                        
                        UserDefaults.standard.set(true, forKey: "launchedBefore")
                        
                        self.loggedOut()
                        
                    }))
                    
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                        self.revealViewController().revealToggle(animated: true)
                    }))
                    
                    self.present(refreshAlert, animated: true, completion: nil)
                    
                }
                
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                print("Error: \(String(describing: error))")
            })
            
            
        } else {
            
        }
    }
    
    
    func loggedOut() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc: SWRevealViewController? = sb.instantiateViewController(withIdentifier: "SWRevealViewController") as? SWRevealViewController
        vc?.modalTransitionStyle = .crossDissolve
        present(vc!, animated: true) { _ in }
    }
    
    
    func getProfileDetails() {
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/view_profile.php")
        
        let param: [String: Any] = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String]
        
        print(param, (url!.absoluteString))
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            //self.appDelegate.showProgress(false)
            let responseDictionary = (responseObject as! NSDictionary)
            print("Profile detail Response: \(responseDictionary as Any)")
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                self.userImageView.sd_setImage(with: URL(string: (responseDictionary["user_image"] as? String)!), placeholderImage: UIImage(named: "profilePlaceholder"))
                self.userNameLabel.text = responseDictionary["name"] as? String
                
            } else if (responseDictionary["status"] as! Int == 0) {
                print("EamR Failure")
                let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            //self.appDelegate.showProgress(false)
            print("Profile detail Error: \(String(describing: error))")
        })
    }
    
    // MARK: - UITableViewDataSource
    // number of section(s), now I assume there is only 1 section
    func numberOfSections(in theTableView: UITableView) -> Int {
        return 1
    }
    
    // number of row in the section, I assume there is only 1 row
    func tableView(_ theTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    // the cell will be returned to the tableView
    func tableView(_ theTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = (theTableView.dequeueReusableCell(withIdentifier: menuCountArray[indexPath.row]))
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: menuCountArray[indexPath.row])
        }
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    // when user tap the row, what action you want to perform
    func tableView(_ theTableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(Int(indexPath.row)) row")
        
        if indexPath.row == 4 {
            
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
    }
    
    
   /* @IBAction func regWithNum(_ sender: UIButton) {
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "registrationWithNumVC") as? registrationWithNumVC
        self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
    }*/
    
    
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
