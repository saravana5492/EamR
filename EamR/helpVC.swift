//
//  helpVC.swift
//  EamR
//
//  Created by Apple on 02/08/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage


class helpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var menuBtn: UIButton!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var helpListTableView: UITableView!
    var helpListArray = NSArray()
    var helpDetArray = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        self.helpListTableView.estimatedRowHeight = 44;
        
        getHelpList()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func getHelpList() {
        
        appDelegate.showProgress(true)
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/help.php")
        
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

                self.helpListArray = responseDictionary.value(forKeyPath: "Question Answer.question_name") as! NSArray
                self.helpDetArray = responseDictionary.value(forKey: "Question Answer") as! NSArray
                self.helpListTableView.reloadData()
                print("Question Array: \(self.helpListArray)")
                
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "help", for: indexPath)
        let helpQues: UILabel? = (cell?.viewWithTag(10) as? UILabel)
        
        helpQues?.text = helpListArray[indexPath.row] as? String;
        
        return cell!
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    
    func tableView(_ theTableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = (self.helpDetArray[indexPath.row] as AnyObject) as! NSDictionary
        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
        UserDefaults.standard.set(data, forKey: "selectedHelp")

        let infoController: helpDetailVC = storyboard?.instantiateViewController(withIdentifier: "helpDetailVC") as! helpDetailVC
        self.navigationController?.pushViewController(infoController, animated: true)
        
    }
    
    @IBAction func sideMenuAction(_ sender: Any) {
        NotificationCenter.default.post(name: KVSideMenu.Notifications.toggleRight, object: self)
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
