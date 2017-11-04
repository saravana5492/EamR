//
//  editAccountVC.swift
//  EamR
//
//  Created by Apple on 01/08/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage
import DatePickerDialog


class editAccountVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var addNewImageBtn: UIButton!
    @IBOutlet var userNameTF: UITextField!
    @IBOutlet var flagImgView: UIImageView!
    @IBOutlet var dialCodeLbl: UILabel!
    @IBOutlet var phoneNumTF: UITextField!
    @IBOutlet var userEmailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var updateBtn: UIButton!
    @IBOutlet var userDOBTF: UITextField!
    @IBOutlet var datePickerBtn: UIButton!
    var datePick: Bool = false
    
    var chosenImage: UIImage!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let picker = UIImagePickerController()
    var dictCodes = [AnyHashable: Any]()

    
    var userNameStr: String!
    var userEmailStr: String!
    var userImageStr: String!
    var userCountryCode: String!
    var userDialCode: String!
    var userPhoneNum: String!
    var userCountryStr: String!
    var userDOBStr: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        userDOBTF.isEnabled = false
        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 52 , width: self.view.frame.width, height: 52)

        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 400)
        
        picker.delegate = self
        
        // Profile Image Circle design -----------
        imageContainerView.layer.cornerRadius = 30.5
        userImageView.layoutIfNeeded()
        userImageView.layer.cornerRadius = 28.5
        userImageView.clipsToBounds = true

        self.appDelegate.showProgress(true)
        getProfileDetails()
        
        updateBtn.layer.cornerRadius = 3.0
        
                dictCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        
        let localIdentifier = Locale.current.identifier
        
        let locale = NSLocale(localeIdentifier: localIdentifier)
        if let countryCode = locale.object(forKey: .countryCode) as? String {
            self.userCountryCode = countryCode
            if let country:String = locale.displayName(forKey: .countryCode, value: countryCode) {
                self.userCountryStr = country
                print(country)
            }
        }
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            let bundle = "assets.bundle/"
            self.flagImgView.image = UIImage(named: bundle + countryCode.lowercased() + ".png")
            dialCodeLbl.text = dictCodes[countryCode] as? String
            
        } else {
            let bundle = "assets.bundle/"
            let countCode = "in"
            self.flagImgView.image = UIImage(named: bundle + countCode.lowercased() + ".png")
            dialCodeLbl.text = "+91"
        }
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func datePickerAction(_ sender: Any) {
        let currentDate = Date()
        var dateComponents = DateComponents()
        var dateComponents1 = DateComponents()
        dateComponents.year = -90
        dateComponents1.year = +0
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        let dateTwo = Calendar.current.date(byAdding: dateComponents1, to: currentDate)
        
        DatePickerDialog().show(title: "Date of Birth", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: threeMonthAgo, maximumDate: dateTwo, datePickerMode: .date) { (date) in
            if let dt = date {
                let dateFormatter = DateFormatter()
                let dateFormatter1 = DateFormatter()
                //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                //let date = dateFormatter.date(from: dt)
                
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter1.dateFormat = "dd MMM, yyyy"
                let newDate = dateFormatter.string(from: dt)
                let newDate1 = dateFormatter1.string(from: dt)
                
                self.userDOBStr = newDate
                self.datePick = true
                self.userDOBTF.text = newDate1
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 400)

        if (UserDefaults.standard.string(forKey: "logInFrom") == "fbLogin" || UserDefaults.standard.string(forKey: "logInFrom") == "googleLogin") {
            self.passwordTF.isEnabled = false
            self.passwordTF.textColor = UIColor.lightGray
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
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
            self.appDelegate.showProgress(false)
            let responseDictionary = (responseObject as! NSDictionary)
            print("Profile detail Response: \(responseDictionary as Any)")
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                self.userImageView.sd_setImage(with: URL(string: (responseDictionary["user_image"] as? String)!), placeholderImage: UIImage(named: "profilePlaceholder"))
                self.userNameTF.text = responseDictionary["name"] as? String
                self.userEmailTF.text = responseDictionary["email"] as? String
                self.userCountryStr = responseDictionary["country"] as? String
                self.userCountryCode = responseDictionary["country_code"] as? String
                self.userDialCode = responseDictionary["dialing_code"] as? String
                
                
                if (responseDictionary["dob"] as? String)!.characters.count == 0 {
                    self.userDOBTF.text = ""
                } else {
                    let dateFormatter = DateFormatter()
                    let dateFormatter1 = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter1.dateFormat = "dd MMM, yyyy"
                    let newDate = dateFormatter.date(from: (responseDictionary["dob"] as? String)!)
                    let newDate1 = dateFormatter1.string(from: newDate!)
                    
                    self.userDOBTF.text = newDate1
                    self.userDOBStr =  responseDictionary["dob"] as? String
                }
                
                if (responseDictionary["phonenumber"] as? String)!.characters.count == 0 {
                    self.phoneNumTF.text = ""
                } else {
                    self.phoneNumTF.text = responseDictionary["phonenumber"] as? String
                }
                if (responseDictionary["dialing_code"] as? String)!.characters.count == 0 {
                    //self.dialCodeLbl.text = ""
                } else {
                    self.dialCodeLbl.text = responseDictionary["dialing_code"] as? String
                }
                
                
                let bundle = "assets.bundle/"
                let countryCode: String! = responseDictionary["country_code"] as! String
                if (countryCode != ""){
                    self.flagImgView.image = UIImage(named: bundle + countryCode.lowercased() + ".png")
                }
                
            } else if (responseDictionary["status"] as! Int == 0) {
                print("EamR Failure")
                let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Profile detail Error: \(String(describing: error))")
        })
    }
    
    @IBAction func chooseDialCodeAction(_ sender: Any) {
        
        print("MICountry picker get called!!!")
        
        let picker = MICountryPicker { (name, code) -> () in
            print(code)
        }
        
        picker.showCallingCodes = true
        
        // delegate
        picker.delegate = self as? MICountryPickerDelegate
        
        // or closure
        picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
            picker.navigationController?.popViewController(animated: true)
            print(code, name, dialCode)
            
            self.userDialCode = dialCode
            self.dialCodeLbl.text = self.userDialCode
            //self.userDialCode = dialCode
            self.userCountryStr = name
            self.userCountryCode = code
            let bundle = "assets.bundle/"
            self.flagImgView.image = UIImage(named: bundle + code.lowercased() + ".png")
            
        }
        navigationController?.pushViewController(picker, animated: true)
        picker.navigationController?.setNavigationBarHidden(false, animated: false)
        picker.navigationController?.navigationBar.barTintColor = UIColor.red
        
    }
    
    func countryPicker(picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
         picker.navigationController?.setNavigationBarHidden(true, animated: false)
        picker.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func addNewImageAction(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    
    }
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        userImageView.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateAction(_ sender: Any) {
        
        self.appDelegate.showProgress(true)
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/edit_profile.php")! as NSURL
        
        if (chosenImage != nil) {
            let jpegCompressionQuality: CGFloat = 0.9 // Set this to whatever suits your purpose
            userImageStr = UIImageJPEGRepresentation(chosenImage, jpegCompressionQuality)?.base64EncodedString()
            
            //let imageData:NSData = UIImagePNGRepresentation(chosenImage)! as NSData
            //userImageStr = imageData.base64EncodedString(options: .lineLength64Characters)
        } else {
            userImageStr = ""
        }
        
                
        userNameStr = userNameTF.text!
        userEmailStr = userEmailTF.text!
        //userCountryCode = ""
        //userDialCode = self.dialCodeLbl.text!
        userPhoneNum = phoneNumTF.text!
        //userDOBStr =
        //userCountryStr = ""
        //let imageStr = userImageStr as String!
        
        let param = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as? String!, "name" : userNameStr!, "email" : userEmailStr!, "user_image" : userImageStr!, "country_code" : userCountryCode!, "dialing_code" : userDialCode!, "phonenumber" : userPhoneNum!, "country" : userCountryStr!, "dob": userDOBStr!]
        
        print(param as Dictionary!)
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url.absoluteString)!, parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            print("Edit Profile Response: \(responseObject as Any)")
            let responseDictionary = (responseObject as! NSDictionary)
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                    self.getProfileDetails()
                    //self.navigationController?.popViewController(animated: true)
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
            print("Edit Profile Error: \(String(describing: error))")
        })
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func cartAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: myCartVC? = storyboard.instantiateViewController(withIdentifier: "myCartVC") as? myCartVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)
        
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
