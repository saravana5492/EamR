//
//  privateChatVC.swift
//  EamR
//
//  Created by Apple on 04/08/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import IQKeyboardManagerSwift


class privateChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, RSKGrowingTextViewDelegate {

    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var sendMsgBtn: UIButton!
    @IBOutlet var chatUserImage: UIImageView!
    
    @IBOutlet var chatTVbottomSpace: NSLayoutConstraint!
    @IBOutlet var sendBtnBottomSpace: NSLayoutConstraint!
    
    var selectedChat = NSDictionary()
    var messagesArray = NSArray()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var navHeadLbl: UILabel!
    @IBOutlet var growingTextView: RSKGrowingTextView!
    
    // Seithi chat copy ***
    var topicDict = NSDictionary()
    var fbDetails = NSDictionary()
    var refreshControl: UIRefreshControl?
    var finalIndexPath: IndexPath?
    var dict = NSDictionary()
    var sendMsg: Bool = false
    var tabMove: Bool = false
    
    var messages = NSMutableArray()
    var sortedMessages = NSMutableDictionary()
    var dict1 = NSDictionary()

    @IBOutlet var tblChat: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        growingTextView.delegate = self;
        growingTextView.font = UIFont.systemFont(ofSize: 13.0)
        
        self.tblChat.separatorColor = UIColor.clear
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.growingTextView.layer.cornerRadius = 4
        self.sendMsgBtn.layer.cornerRadius = 3
        self.growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        
        //IQKeyboardManager.sharedManager().enable = false
        
        //NotificationCenter.default.addObserver(self, selector: #selector(chatPageVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(chatPageVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadChatPage(_:)), name: NSNotification.Name(rawValue: "MessageRecievedInChatScreen"), object: nil)

        
        // Selected Chat dictionary ***
        
        if (UserDefaults.standard.value(forKey: "pChatFrom") as! String == "chatList" ) {
            let data = UserDefaults.standard.value(forKey: "selectedChat")
            self.selectedChat = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        } else if (UserDefaults.standard.value(forKey: "pChatFrom") as! String == "userList" ) {
            let data = UserDefaults.standard.value(forKey: "selectedUser")
            self.selectedChat = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        }
        
        
        navHeadLbl.text = self.selectedChat["user_name"] as? String
        
        chatUserImage.sd_setImage(with: URL(string: (self.selectedChat["user_image"] as? String)!), placeholderImage: UIImage(named: "profilePlaceholder"))
        
        chatUserImage.layer.masksToBounds = true
        chatUserImage.layoutIfNeeded()
        chatUserImage.layer.cornerRadius = 21.5
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged)
        tblChat.addSubview(refreshControl!)
        tblChat.keyboardDismissMode = .onDrag
        
        // Web service for All messages ***
        self.appDelegate.showProgress(true)
        getMessages()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = false
        NotificationCenter.default.addObserver(self, selector: #selector(chatPageVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(chatPageVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadChatPage(_:)), name: NSNotification.Name(rawValue: "MessageRecievedInChatScreen"), object: nil)

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = true
        NotificationCenter.default.removeObserver(self)
    }

    
    func reloadChatPage(_ notification: NSNotification) {
        
        //var person = notification.object() as? [AnyHashable: Any]
        //if (person["facebookId"] == selectedFriend.frd_fb_Id) {
        //    getMessages()
        //}
        
        self.getMessages()
    }

    
    func growingTextView(_ textView: RSKGrowingTextView, willChangeHeightFrom growingTextViewHeightBegin: CGFloat, to growingTextViewHeightEnd: CGFloat) {
        
        print("Delegate called!!")
        
        let diff: CGFloat = (growingTextView.frame.size.height - growingTextViewHeightEnd)
        print("Sort Msg Count: \(diff)")
        //scrollTopSpace.constant += diff
    }
    
    @IBAction func msgSendAction(_ sender: Any) {
        
        
        if self.growingTextView.text.characters.count > 0 {
            self.appDelegate.showProgress(true)
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/single_chat_send.php")
            
            let param: [String: Any] = ["sender_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "receiver_id" : self.selectedChat["profile_id"] as! String, "message": self.growingTextView.text!]
            
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
                
                self.growingTextView.text = ""
                self.view.endEditing(true)
                
                
                if (responseDictionary["status"] as AnyObject).integerValue == 1 {
                    print("EamR Success")
                    
                    self.getMessages()
                 
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
    
    
    func getMessages() {
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/single_chat_receive.php")
        
        let param = ["from_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "to_id" : self.selectedChat["profile_id"] as! String]
        
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
            
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                
                self.messagesArray = (responseDictionary["messages"] as AnyObject) as! NSArray
                
                if self.messagesArray.count > 0 {
                    self.tblChat.reloadData()
                    
                    let numberOfSections = self.tblChat.numberOfSections
                    let numberOfRows = self.tblChat.numberOfRows(inSection: numberOfSections-1)
                    
                    if numberOfRows > 0 {
                        let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                        self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                    
                    //self.tableViewScrollToBottom(animated: true)
                    //self.finalIndexPath = IndexPath(row: self.tblChat.numberOfRows(inSection: 1), section: 1)
                    //self.tblChat.scrollToRow(at: self.finalIndexPath!, at: .bottom, animated: false)
                }
                //self.chatListTableView.reloadData()
            } else {
                print("EamR Failure")
                /*let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }*/
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
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        dict = messagesArray[indexPath.row] as! NSDictionary
        print("Dict Datas: \(dict)")
        let data: Data! = (dict["message"]! as AnyObject).data(using: String.Encoding.nonLossyASCII.rawValue)
        let valueUnicode = String(data: data!, encoding: String.Encoding.utf8)
        let dataa: Data? = valueUnicode?.data(using: String.Encoding.utf8)
        let goodValue = String(data: dataa!, encoding: String.Encoding.nonLossyASCII)
        
        let userProfile: String = dict["from_id"] as! String!
        
        if (userProfile == UserDefaults.standard.value(forKey: "ProfileID") as! String) {
            let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "right", for: indexPath)
            let arrowView: UIImageView? = (cell?.viewWithTag(95) as? UIImageView)
            let lblTime: UILabel? = (cell?.viewWithTag(93) as? UILabel)
            let lblName: UILabel? = (cell?.viewWithTag(37) as? UILabel)
            let lblDescription: UILabel? = (cell?.viewWithTag(30) as? UILabel)
            let imgBackground: UIImageView? = (cell?.viewWithTag(40) as? UIImageView)
            
            
            let dateStr : String = dict["sent_time"] as! String
            
            print("Review Date \(dateStr)")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            let date = dateFormatter.date(from: dateStr)
            
            dateFormatter.dateFormat = "dd MMM, HH:mm"
            let newDate = dateFormatter.string(from: date!)
            
            lblName?.text = "Me"
            lblTime?.text = newDate
            lblDescription?.text = goodValue
            
            cell?.selectionStyle = .none
            imgBackground?.layer.cornerRadius = 8.0
            imgBackground?.layer.masksToBounds = true
            imgBackground?.contentMode = .scaleAspectFill
            arrowView?.image = arrowView?.image?.withRenderingMode(.alwaysTemplate)
            arrowView?.tintColor = UIColor(red: 175 / 255.0, green: 227 / 255.0, blue: 225 / 255.0, alpha: 1.0)
            
            cell?.contentView.backgroundColor = UIColor.clear
            cell?.backgroundColor = UIColor.clear
            return cell!
            
        } else {
            let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "left", for: indexPath)
            let arrowView: UIImageView? = (cell?.viewWithTag(95) as? UIImageView)
            let lblTime: UILabel? = (cell?.viewWithTag(93) as? UILabel)
            let lblName: UILabel? = (cell?.viewWithTag(37) as? UILabel)
            let lblDescription: UILabel? = (cell?.viewWithTag(30) as? UILabel)
            let imgBackground: UIImageView? = (cell?.viewWithTag(40) as? UIImageView)
            
            let dateStr : String = dict["sent_time"] as! String
            
            print("Review Date \(dateStr)")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            let date = dateFormatter.date(from: dateStr)
            
            dateFormatter.dateFormat = "dd MMM, HH:mm"
            let newDate = dateFormatter.string(from: date!)
            
            lblName?.text = self.selectedChat["user_name"] as! String
            lblTime?.text = newDate
            lblDescription?.text = goodValue
            
            cell?.selectionStyle = .none
            imgBackground?.layer.cornerRadius = 8.0
            imgBackground?.layer.masksToBounds = true
            imgBackground?.contentMode = .scaleAspectFill
            arrowView?.image = arrowView?.image?.withRenderingMode(.alwaysTemplate)
            arrowView?.tintColor = UIColor(red: 255 / 255.0, green: 197 / 255.0, blue: 198 / 255.0, alpha: 1.0)
            
            cell?.contentView.backgroundColor = UIColor.clear
            cell?.backgroundColor = UIColor.clear
            return cell!
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageDict = messagesArray[indexPath.row] as! NSDictionary

        let adminName:String! = messageDict["admin_msg"] as! String
        
        if adminName == "Y" {
            
            let prodDict = messageDict["product_list"] as! NSDictionary
            
            UserDefaults.standard.set("admin", forKey: "productFrom")
            
            let data = NSKeyedArchiver.archivedData(withRootObject: prodDict)
            UserDefaults.standard.set(data, forKey: "productDetail")
            
            let infoController: productControlVC? = storyboard?.instantiateViewController(withIdentifier: "productControlVC") as? productControlVC
            navigationController?.pushViewController(infoController!, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(0)) {
            let numberOfSections = self.tblChat.numberOfSections
            let numberOfRows = self.tblChat.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    func handleRefresh(_ sender: Any) {
        getMessages()
    }
    
    func scrollViewDidScroll(_ aScrollView: UIScrollView) {
        let offset: CGPoint = aScrollView.contentOffset
        let bounds: CGRect = aScrollView.bounds
        let size: CGSize = aScrollView.contentSize
        let inset: UIEdgeInsets = aScrollView.contentInset
        let y: Float = Float(offset.y + bounds.size.height - inset.bottom)
        let h: Float = Float(size.height)
        let reload_distance: Float = 10
        if y > h + reload_distance {
            print("load more rows")
            getMessages()
        }
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            //self.view.frame.origin.y -= keyboardSize.height
            var userInfo = notification.userInfo!
            var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            chatTVbottomSpace.constant = keyboardFrame.size.height + 12
            sendBtnBottomSpace.constant = keyboardFrame.size.height + 17
            
            var contentInset:UIEdgeInsets = self.tblChat.contentInset
            contentInset.bottom = 0 // keyboardFrame.size.height
            self.tblChat.contentInset = contentInset
            
            print("Keyboard action called!!")
            
            //get indexpath
            //let indexpath = NSIndexPath(row: 1, section: 0)
            //self.tblChat.scrollToRow(at: indexpath as IndexPath, at: .bottom, animated: true)
            
            self.tableViewScrollToBottom(animated: true)
            
           /* let numberOfSections = self.tblChat.numberOfSections
            let numberOfRows = self.tblChat.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: true)
            } */
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            chatTVbottomSpace.constant = 12
            sendBtnBottomSpace.constant = 17
            
            let contentInset:UIEdgeInsets = UIEdgeInsets.zero
            self.tblChat.contentInset = contentInset
        }
    }

    
    @IBAction func sideMenuAction(_ sender: Any) {
        NotificationCenter.default.post(name: KVSideMenu.Notifications.toggleRight, object: self)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.growingTextView.text = ""
        self.view.endEditing(true)
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
