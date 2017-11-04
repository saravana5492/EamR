//
//  settingsPageVC.swift
//  EamR
//
//  Created by Apple on 01/08/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import AFNetworking
import SDWebImage

class settingsPageVC: UIViewController {

    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var signOutView: UIView!
    @IBOutlet var accountDetView: UIView!
    @IBOutlet var profImageContView: UIView!
    @IBOutlet var profImageView: UIImageView!
    @IBOutlet var profUserName: UILabel!
    @IBOutlet var profUserNum: UILabel!
    @IBOutlet var profUserEmail: UILabel!
    @IBOutlet var signOutBtn: UIButton!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        accountDetView.backgroundColor = UIColor.white
        signOutView.backgroundColor = UIColor.white
        
        // Profile Image Circle design -----------
        profImageContView.layer.cornerRadius = 37.5
        profImageView.layoutIfNeeded()
        profImageView.layer.cornerRadius = 35.5
        profImageView.clipsToBounds = true

        self.appDelegate.showProgress(true)
        getProfileDetails()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getProfileDetails()
        signOutView.backgroundColor = UIColor.white
        accountDetView.backgroundColor = UIColor.white
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
                self.profImageView.sd_setImage(with: URL(string: (responseDictionary["user_image"] as? String)!), placeholderImage: UIImage(named: "profilePlaceholder"))
                self.profUserName.text = responseDictionary["name"] as? String
                
                let dialCode: String = (responseDictionary["dialing_code"] as? String)!
                let userNum: String =  (responseDictionary["phonenumber"] as? String)!
                if (responseDictionary["phonenumber"] as? String)!.characters.count == 0 {
                    self.profUserNum.text = "--"
                } else {
                    self.profUserNum.text = "\(dialCode) \(userNum)"
                }
                
                self.profUserEmail.text = responseDictionary["email"] as? String

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
    
    @IBAction func editAcntAction(_ sender: Any) {
        accountDetView.backgroundColor = UIColor.lightGray

        let infoController: editAccountVC = storyboard?.instantiateViewController(withIdentifier: "editAccountVC") as! editAccountVC
        self.navigationController?.pushViewController(infoController, animated: true)
    }

    @IBAction func signOutAction(_ sender: Any) {
        
        signOutView.backgroundColor = UIColor.lightGray

        DispatchQueue.main.async(execute: {
            let refreshAlert = UIAlertController(title: "Alert", message: "Do you want to sign out?", preferredStyle: UIAlertControllerStyle.alert)
            
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
                print("Handle Cancel Logic here")
                self.signOutView.backgroundColor = UIColor.white

            }))
            
            self.present(refreshAlert, animated: true, completion: nil)
        })
        
    }
    
    /*
 
     
     
    */
    
    func loggedOut() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc: SWRevealViewController? = sb.instantiateViewController(withIdentifier: "SWRevealViewController") as? SWRevealViewController
        vc?.modalTransitionStyle = .crossDissolve
        present(vc!, animated: true) { _ in }
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
