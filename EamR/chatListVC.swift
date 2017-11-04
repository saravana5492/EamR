//
//  chatListVC.swift
//  EamR
//
//  Created by Apple on 17/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage
import EPContactsPicker
import MessageUI


class chatListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, EPPickerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var menuBtn: UIButton!
    @IBOutlet weak var chatListTableView: UITableView!
    var chatListArray = NSArray()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var paramTrack = NSDictionary()
    var contactsArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadChatList(_:)), name: NSNotification.Name(rawValue: "RecievedMessageinChatList"), object: nil)

        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.chatListTableView.separatorColor = UIColor.clear
        self.appDelegate.showProgress(true)
        getChatList()
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chatListVC.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.chatListTableView.addGestureRecognizer(longPressGesture)
        
        // Do any additional setup after loading the view.
    }
    
    
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.chatListTableView)
            var indexPath = self.chatListTableView.indexPathForRow(at: touchPoint)
            if indexPath != nil {
                
                let refreshAlert = UIAlertController(title: "Alert", message: "Do you want to delete this chat?", preferredStyle: UIAlertControllerStyle.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    
                    let dict = (self.chatListArray[(indexPath?.row)!] as AnyObject) as! NSDictionary
                    
                    let chatType: Int = (dict["chat_type"] as! NSString).integerValue
                    
                    if (chatType == 1) {
                        self.paramTrack = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID")!, "exhibitor_id": dict["exhibitor_id"] as! String, "type" : 1]
                        
                    } else {
                        self.paramTrack = ["receiver_id" : UserDefaults.standard.value(forKey: "ProfileID")!, "sender_id": dict["profile_id"] as! String, "type" : 2]
                    }
                    
                    let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/delete_chat.php")
                    
                    
                    //let param = ["product_id" : "1"]
                    
                    print(self.paramTrack)
                    
                    let manager = AFHTTPSessionManager()
                    manager.requestSerializer = AFHTTPRequestSerializer()
                    manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
                    let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
                    
                    manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
                    
                    manager.post((url!.absoluteString), parameters: self.paramTrack, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                        self.appDelegate.showProgress(false)
                        let responseDictionary = (responseObject as! NSDictionary)
                        print(responseDictionary as Any)
                        
                        if (responseDictionary["status"] as! Int == 1) {
                            print("EamR Success")
                            
                            let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                                self.getChatList()
                            })
                            alertController.addAction(ok)
                            self.present(alertController, animated: true) { _ in }
                            
                            
                        } else {
                            print("EamR Failure")
                            let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                            })
                            alertController.addAction(ok)
                            self.present(alertController, animated: true) { _ in }
                        }
                        
                    }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                        self.appDelegate.showProgress(false)
                        print("Error: \(String(describing: error))")
                    })
                    
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Handle Cancel Logic here")
                }))
                
                present(refreshAlert, animated: true, completion: nil)
                
                // your code here, get the row for the indexPath or do whatever you want
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getChatList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadChatList(_:)), name: NSNotification.Name(rawValue: "RecievedMessageinChatList"), object: nil)

        // No need for semicolon
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadChatList(_ notification: NSNotification) {
        self.getChatList()
    }
    
    func getChatList() {
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/user_chat_list.php")
        
        let param = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID")!]
        
        //let param = ["product_id" : "1"]

        print(param)
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            self.chatListTableView.isHidden = false
            let responseDictionary = (responseObject as! NSDictionary)
            print(responseDictionary as Any)
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                self.chatListArray = (responseDictionary["chat_list"] as AnyObject) as! NSArray
                
                if self.chatListArray.count == 0 {
                    self.chatListTableView.isHidden = true
                } else {
                    self.chatListTableView.reloadData()
                }
                
            } else {
                print("EamR Failure")
                let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
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
        return self.chatListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: chatCell? = (tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? chatCell)
        
        let dict = (self.chatListArray[indexPath.row] as AnyObject) as! NSDictionary
        
        print("Dict: \(dict)")
        
        let chatType: Int = (dict["chat_type"] as! NSString).integerValue
        
        if (chatType == 1) {
            let dateStr : String = dict["createddate"] as! String
            
            if dateStr != "" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
                let date = dateFormatter.date(from: dateStr)
                dateFormatter.dateFormat = "dd MMM"
                let newDate = dateFormatter.string(from: date!)
                cell?.exhLastTime?.text = newDate
            } else {
                cell?.exhLastTime?.text = ""
            }
            
            cell?.chatListImageView.sd_setImage(with: URL(string: (dict["exbh_image"] as? String)!), placeholderImage: UIImage(named: "profilePlaceholder"))
            cell?.exhCompName?.text = dict["exbh_name"] as? String
            cell?.exhCompLastMsg?.text = dict["message"] as? String
            cell?.imageBackView?.layer.cornerRadius = 31.5
            cell?.chatListImageView?.layer.masksToBounds = true
            cell?.chatListImageView?.layoutIfNeeded()
            cell?.chatListImageView?.layer.cornerRadius = 29.5
        } else {
            let dateStr : String = dict["createddate"] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            let date = dateFormatter.date(from: dateStr)
            dateFormatter.dateFormat = "dd MMM"
            let newDate = dateFormatter.string(from: date!)
            cell?.chatListImageView.sd_setImage(with: URL(string: (dict["user_image"] as? String)!), placeholderImage: UIImage(named: "profilePlaceholder"))
            cell?.exhCompName?.text = dict["user_name"] as? String
            cell?.exhCompLastMsg?.text = dict["message"] as? String
            cell?.exhLastTime?.text = newDate
            cell?.imageBackView?.layer.cornerRadius = 31.5
            cell?.chatListImageView?.layer.masksToBounds = true
            cell?.chatListImageView?.layoutIfNeeded()
            cell?.chatListImageView?.layer.cornerRadius = 29.5
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let dict = (self.chatListArray[indexPath.row] as AnyObject) as! NSDictionary
        
        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
        UserDefaults.standard.set(data, forKey: "selectedChat")
        
        let chatType: Int = (dict["chat_type"] as! NSString).integerValue
        
        if (chatType == 1) {
            let infoController: chatPageVC? = storyboard?.instantiateViewController(withIdentifier: "chatPageVC") as? chatPageVC
            navigationController?.pushViewController(infoController!, animated: true)
        } else {
            UserDefaults.standard.setValue("chatList", forKey: "pChatFrom")
            let infoController: privateChatVC? = storyboard?.instantiateViewController(withIdentifier: "privateChatVC") as? privateChatVC
            navigationController?.pushViewController(infoController!, animated: true)
        }
        
    }

    
    // Loading Contacts ***
    
    //MARK: EPContactsPicker delegates
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError)
    {
        print("Failed with error \(error.description)")
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact)
    {
        print("Contact \(contact.phoneNumbers) has been selected")
        contactsArray.adding(contact.phoneNumbers)
    }
    
    func epContactPicker(_: EPContactsPicker, didCancel error : NSError)
    {
        print("User canceled the selection");
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.phoneNumbers)")
            contactsArray.adding(contact.phoneNumbers)
        }
        /*
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Enter a message";
        messageVC.recipients = contactsArray as? [String]
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)*/
        
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

    }
    
    
    @IBAction func contactsAction(_ sender: Any) {
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.phoneNumber)
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        //self.present(navigationController, animated: true, completion: nil)

        let transition = CATransition()
        transition.duration = 0.0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        present(navigationController, animated: false, completion: nil)
        
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
