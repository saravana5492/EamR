//
//  registrationWithSclActVC.swift
//  EamR
//
//  Created by Apple on 13/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import AFNetworking

class registrationWithSclActVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{

    @IBOutlet var fbImageView: UIImageView!
    @IBOutlet var gplusImageView: UIImageView!
    var dict : [String : AnyObject]!
    var userName : String?
    var userEmail : String!
    var userProfilePic : String!
    var userId : String!
    var userLoginType : String!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var fbView: UIView!
    @IBOutlet var gpView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        fbImageView.layer.masksToBounds = true
        fbImageView.layer.cornerRadius  = 5
        gplusImageView.layer.masksToBounds = true
        gplusImageView.layer.cornerRadius  = 5
        
        self.gpView.backgroundColor = UIColor.white
        self.fbView.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gpView.backgroundColor = UIColor.white
        self.fbView.backgroundColor = UIColor.white

        // No need for semicolon
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fbLoginAction(_ sender: UIButton) {
        
        self.fbView.backgroundColor = UIColor(red: 210 / 255.0, green: 228 / 255.0, blue: 255 / 255.0, alpha: 1.0)

        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.web

        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                }
            }
        }
    }
    
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]

                    print("FB login result: \(self.dict)")
                    
                    UserDefaults.standard.set(self.dict["email"] as! String, forKey:"UserEmail")
                    UserDefaults.standard.set(self.dict["name"] as! String, forKey:"UserFullName")
                    UserDefaults.standard.set(self.dict["id"] as! String, forKey:"UserFbID")
                    UserDefaults.standard.set(self.dict["id"] as! String, forKey:"ProfileID")
                    UserDefaults.standard.set(self.dict["email"] as! String, forKey:"Userdob")
                    if let imageURL = ((self.dict["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        //Download image from imageURL
                        UserDefaults.standard.set(imageURL, forKey:"UserProfilePic")
                    }
                    
                    self.userName = self.dict["name"] as? String
                    self.userEmail = self.dict["email"] as! String
                    self.userProfilePic = UserDefaults.standard.string(forKey: "UserProfilePic")
                    self.userId = self.dict["id"] as! String
                    self.userLoginType = "1"
                    
                    UserDefaults.standard.set("1", forKey:"userLoginType")
                    
                    self.userRegistration()
                    
                }
            })
        }
    }
    
    
    @IBAction func gplusLoginAction(_ sender: UIButton) {
        
        self.gpView.backgroundColor = UIColor(red: 255 / 255.0, green: 224 / 255.0, blue: 231 / 255.0, alpha: 1.0)
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()

    }
        
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId: String = user.userID
            //let dob: String = user.profile.
            // For client-side use only!
            var _: String = user.authentication.idToken
            // Safe to send to the server
            let fullName: String
                = user.profile.name
            //let givenName: String = user.profile.givenName
            //let familyName: String = user.profile.familyName
            let email: String = user.profile.email
            var profilePicStr = String()
            let profilePic: Bool = user.profile.hasImage
            if profilePic {
                let thumbSize = CGSize(width: 500, height: 500)
                let dimension: Int = Int(round(thumbSize.width * UIScreen.main.scale))
                let imageURL = user.profile.imageURL(withDimension: UInt(dimension))
                profilePicStr = (imageURL?.absoluteString)!
            }
            
            UserDefaults.standard.setValue(email, forKey: "ggUserEmail")
            UserDefaults.standard.setValue(fullName, forKey: "ggUserFullName")
            UserDefaults.standard.setValue(userId, forKey: "ProfileID")
            UserDefaults.standard.setValue(profilePicStr, forKey: "ggUserProfilePic")
            
            self.userName = fullName 
            self.userEmail = email
            self.userProfilePic = profilePicStr
            self.userId = userId
            self.userLoginType = "2"
            UserDefaults.standard.set("2", forKey:"userLoginType")
            
            self.userRegistration()
            
        } else {
            print("\(error.localizedDescription)")
        }
    }

    func userRegistration(){
        
        self.appDelegate.showProgress(true)
        
        //UserDefaults.standard.value(forKey: "deviceTocken") as! String
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/register_webservice.php")
        
        let param: [String: Any] = ["profile_id" : self.userId!, "name" : self.userName!, "type" : self.userLoginType!, "email" : self.userEmail!, "imgurl" : self.userProfilePic!, "device_token": UserDefaults.standard.value(forKey: "deviceTocken") as! String, "device_type": "2"]
        
        print("Parameter !!")
        print(param, (url!.absoluteString))
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>

        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            print("Login/Registration User Response: \(responseObject as Any)")
            let responseDictionary = (responseObject as! NSDictionary)
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in

                    if self.userLoginType == "1" {
                        UserDefaults.standard.set("fbLogin", forKey: "logInFrom")
                    } else {
                        UserDefaults.standard.set("googleLogin", forKey: "logInFrom")
                    }
                    
                    UserDefaults.standard.set(true, forKey: "loggedIn")
                    
                    
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc: SWRevealViewController? = sb.instantiateViewController(withIdentifier: "SWRevealViewController") as? SWRevealViewController
                    vc?.modalTransitionStyle = .crossDissolve
                    self.present(vc!, animated: true) { _ in }
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
                
            } else if (responseDictionary["status"] as! Int == 0) {
                print("EamR Failure")

                let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                    
                    if self.userLoginType == "1" {
                        //UserDefaults.standard.set("fbLogin", forKey: "logInFrom")
                    } else {
                        GIDSignIn.sharedInstance().signOut()
                    }
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Login/Registration User Error: \(String(describing: error))")
        })
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
