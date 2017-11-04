//
//  placeOrderVC.swift
//  EamR
//
//  Created by Apple on 21/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking



class placeOrderVC: UIViewController, UITextViewDelegate, PayPalPaymentDelegate {

    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var buyBtn: UIButton!
    @IBOutlet var addressView: UIView!
    @IBOutlet var cityView: UIView!
    @IBOutlet var stateView: UIView!
    @IBOutlet var countryView: UIView!
    @IBOutlet var postCodeView: UIView!
    @IBOutlet var codImage: UIImageView!
    @IBOutlet var onlinePayImage: UIImageView!
    @IBOutlet var codBtn: UIButton!
    @IBOutlet var onlinePayBtn: UIButton!

    @IBOutlet var normalDelImage: UIImageView!
    @IBOutlet var fastDelImage: UIImageView!
    @IBOutlet var normalDelBtn: UIButton!
    @IBOutlet var fastDelBtn: UIButton!

    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var addressTF: UITextView!
    @IBOutlet var cityTF: UITextField!
    @IBOutlet var stateTF: UITextField!
    @IBOutlet var countryTF: UITextField!
    @IBOutlet var postCodeTF: UITextField!
    var placeholderLabel : UILabel!

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
        
        
        print("Total amount: \(String(describing: UserDefaults.standard.value(forKey: "payTotal")))")
        
        self.hideKeyboardWhenTappedAround()
        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
            self.navigationController?.setNavigationBarHidden(true, animated: false)

        buyBtn.layer.cornerRadius = 3.0
        
        addressView.layer.cornerRadius = 3.0
        addressView.layer.borderColor = UIColor.lightGray.cgColor
        addressView.layer.borderWidth = 1.0
        cityView.layer.cornerRadius = 3.0
        cityView.layer.borderColor = UIColor.lightGray.cgColor
        cityView.layer.borderWidth = 1.0
        stateView.layer.cornerRadius = 3.0
        stateView.layer.borderColor = UIColor.lightGray.cgColor
        stateView.layer.borderWidth = 1.0
        countryView.layer.cornerRadius = 3.0
        countryView.layer.borderColor = UIColor.lightGray.cgColor
        countryView.layer.borderWidth = 1.0
        postCodeView.layer.cornerRadius = 3.0
        postCodeView.layer.borderColor = UIColor.lightGray.cgColor
        postCodeView.layer.borderWidth = 1.0

        codBtn.setBackgroundImage(UIImage(named: "onBtn"), for: .selected)
        codBtn.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        onlinePayBtn.setBackgroundImage(UIImage(named: "onBtn"), for: .selected)
        onlinePayBtn.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        
        
        normalDelBtn.setBackgroundImage(UIImage(named: "onBtn"), for: .selected)
        normalDelBtn.addTarget(self, action: #selector(buttonClickedDel(_:)), for: .touchUpInside)
        fastDelBtn.setBackgroundImage(UIImage(named: "onBtn"), for: .selected)
        fastDelBtn.addTarget(self, action: #selector(buttonClickedDel(_:)), for: .touchUpInside)


        addressTF.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter your address"
        placeholderLabel.font = UIFont.systemFont(ofSize: (addressTF.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        addressTF.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (addressTF.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !addressTF.text.isEmpty

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
        PayPalMobile.preconnect(withEnvironment:PayPalEnvironmentProduction)
        //PayPalMobile.preconnect(withEnvironment:PayPalEnvironmentSandbox)
    }
    
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10:
            if codBtn.isSelected == true {
                codBtn.isSelected = false
                onlinePayBtn.isSelected = true
            }
            else {
                codBtn.isSelected = true
                onlinePayBtn.isSelected = false
            }
        case 20:
            if onlinePayBtn.isSelected == true {
                onlinePayBtn.isSelected = false
                codBtn.isSelected = true
            }
            else {
                onlinePayBtn.isSelected = true
                codBtn.isSelected = false
            }
        default:
            break
        
        }
    }
    
    @IBAction func buttonClickedDel(_ sender: UIButton) {
        switch sender.tag {
        case 10:
            if normalDelBtn.isSelected == true {
                normalDelBtn.isSelected = false
                fastDelBtn.isSelected = true
            }
            else {
                normalDelBtn.isSelected = true
                fastDelBtn.isSelected = false
            }
        case 20:
            if fastDelBtn.isSelected == true {
                fastDelBtn.isSelected = false
                normalDelBtn.isSelected = true
            }
            else {
                fastDelBtn.isSelected = true
                normalDelBtn.isSelected = false
            }
        default:
            break
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    @IBAction func buyAction(_ sender: Any) {

        
        if addressTF.text == "" {
            let alertController = UIAlertController(title: "Failure", message: "Please enter your address", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true) { _ in }
            
        } else if cityTF.text == "" {
            let alertController = UIAlertController(title: "Failure", message: "Please enter your city", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true) { _ in }

        } else if stateTF.text == "" {
            let alertController = UIAlertController(title: "Failure", message: "Please enter your state", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true) { _ in }
            
        } else if countryTF.text == "" {
            let alertController = UIAlertController(title: "Failure", message: "Please enter your country", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true) { _ in }
            
        } else if postCodeTF.text == "" {
            let alertController = UIAlertController(title: "Failure", message: "Please enter your postal code", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true) { _ in }
            
        } else if codBtn.isSelected == false && onlinePayBtn.isSelected == false {
            let alertController = UIAlertController(title: "Failure", message: "please select your payment method", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true) { _ in }
        } else if normalDelBtn.isSelected == false && fastDelBtn.isSelected == false {
            let alertController = UIAlertController(title: "Failure", message: "please select your Delivery type", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true) { _ in }
        } else {
            if codBtn.isSelected == true {
                self.appDelegate.showProgress(true)
                cashOnDelivery()
                
            }else{
                payPayPlaceOrder()
            }
        }
    }   
    
    func cashOnDelivery() {
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/checkout.php")! as NSURL
        
        let delType: String!
        
        if normalDelBtn.isSelected == true {
            delType = "1"
        } else {
            delType = "2"
        }
        
        let param = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as? String, "address" : addressTF.text!, "city" : cityTF.text!, "state" : stateTF.text!, "country" : countryTF.text!, "postal_code" : postCodeTF.text!, "payment_method" : "COD", "delivery_type": delType]
        
        print(param)
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url.absoluteString)!, parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            print("Check Out Response: \(responseObject as Any)")
            let responseDictionary = (responseObject as! NSDictionary)
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                let alertController = UIAlertController(title: "Success", message:"Thank you for your purchase. The Exhibitor has been notified of your purchase", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let UIVC: homePageVC? = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? homePageVC
                    let transition = CATransition()
                    transition.duration = 0
                    transition.type = kCATransitionFade
                    //transition.subtype = kCATransitionFromTop;
                    self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                    self.navigationController?.pushViewController(UIVC!, animated: false)

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
            print("Check Out Error: \(String(describing: error))")
        })
    }

    func payPayPlaceOrder() {
        // Optional: include multiple items
        //let item1 = PayPalItem(name: "Old jeans with holes", withQuantity: 2, withPrice: NSDecimalNumber(string: "84.99"), withCurrency: "USD", withSku: "Hip-0037")
        //let item2 = PayPalItem(name: "Free rainbow patch", withQuantity: 1, withPrice: NSDecimalNumber(string: "0.00"), withCurrency: "USD", withSku: "Hip-00066")
        //let item3 = PayPalItem(name: "Long-sleeve plaid shirt (mustache not included)", withQuantity: 1, withPrice: NSDecimalNumber(string: "37.99"), withCurrency: "USD", withSku: "Hip-00291")
        
        //let items = [item1, item2, item3]
        //let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        //let shipping = NSDecimalNumber(string: "5.99")
        //let tax = NSDecimalNumber(string: "2.50")
        //let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        
        let priceStr: Float = UserDefaults.standard.value(forKey: "payTotal") as! Float!
        
        let total = priceStr
        
        let payment = PayPalPayment(amount: total as! NSDecimalNumber, currencyCode: "USD", shortDescription: "EamR Products", intent: .sale)
        
        //payment.items = items
       // payment.paymentDetails = paymentDetails
        
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
            
            self.updatePurchaseSuccess()
            
        })
    }
    
    func updatePurchaseSuccess() {
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/checkout.php")! as NSURL
        
        let delType: String!
        
        if normalDelBtn.isSelected == true {
            delType = "1"
        } else {
            delType = "2"
        }
        
        let param = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as? String, "address" : addressTF.text!, "city" : cityTF.text!, "state" : stateTF.text!, "country" : countryTF.text!, "postal_code" : postCodeTF.text!, "payment_method" : "Paypal", "delivery_type": delType]
        
        print(param)
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url.absoluteString)!, parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            print("Check Out Response: \(responseObject as Any)")
            let responseDictionary = (responseObject as! NSDictionary)
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                let alertController = UIAlertController(title: "Success", message:"Thank you for your purchase. The Exhibitor has been notified of your purchase", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let UIVC: homePageVC? = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? homePageVC
                    let transition = CATransition()
                    transition.duration = 0
                    transition.type = kCATransitionFade
                    //transition.subtype = kCATransitionFromTop;
                    self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                    self.navigationController?.pushViewController(UIVC!, animated: false)
                    
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
            print("Check Out Error: \(String(describing: error))")
        })

        
    }
    
    
    @IBAction func sideMenuAction(_ sender: Any) {
        NotificationCenter.default.post(name: KVSideMenu.Notifications.toggleRight, object: self)
    }

    
    @IBAction func backAction(_ sender: Any) {
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
