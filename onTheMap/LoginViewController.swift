//
//  ViewController.swift
//  onTheMap
//
//  Created by Arjun Baru on 02/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var logoImage: UIImageView?
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logonDetails: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    var appDelegate : AppDelegate!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         appDelegate = UIApplication.shared.delegate as! AppDelegate
       self.usernameTextField.delegate = self
       self.passwordTextField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        settingUpView()
        self.reach()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.unsuscribeToNotificationCenter()
        
    }
    
    
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if passwordTextField.isFirstResponder{
            subscribeToKeyboardWillHideNotifications()
            passwordTextField.resignFirstResponder()
        }
    
        if ((usernameTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!){
            logonDetails.text = "Text field left empty"
            
        }else{
            
            logonDetails.text = "Connecting..."
            let activeView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            activeView.center = view.center
            activeView.startAnimating()
            view.addSubview(activeView)
            self.reach()
            let views = [usernameTextField!,passwordTextField!,loginButton!,logonDetails!] as [Any]
             changeAlphaFor(views as! [UIView], alpha: 0.5)
            
            
            udacityClient.sharedInstance().validateUsernameAndPassword(usernameTextField.text!,passwordTextField.text!)
            {(sessionID,error) in
                
                               
                if let sessionID = sessionID{
                 print(sessionID)
                udacityClient.sharedInstance().sessionID = sessionID
               self.appDelegate.userID = sessionID
                
                performUIUpdatesOnMain {
                    self.logonDetails.text = "loging in..."
                   self.completeLogin()
                    self.changeAlphaFor(views as! [UIView], alpha: 1.0)
                    activeView.stopAnimating()
                    }
            
            }else{
                
                    performUIUpdatesOnMain {
                        let alert = UIAlertController(title: "Error",message: "Invalid Username or Password",preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title:"Dismiss",style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.changeAlphaFor(views as! [UIView], alpha: 1.0)
                        activeView.stopAnimating()
                        self.logonDetails.text = "Enter Username And Password "
                }
            }
        }
    }
}
    
    private func completeLogin(){
       let controller = self.storyboard!.instantiateViewController(withIdentifier: "StudentTabBarViewController") as! UITabBarController
        self.present(controller, animated: true, completion: nil)
    }
    
}









// for Keyboard
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        subscribeToKeyboardWillHideNotifications()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        subscribeToKeyboardWillHideNotifications()
        unsuscribeToNotificationCenter()
        if passwordTextField.isFirstResponder{
        suscribeToKeyboardWillShowNotification()
            
        passwordTextField.text = ""
            
        }
    }
    func settingUpView(){
        usernameTextField.text = ""
        passwordTextField.text = ""
        logonDetails.text = "Enter Username And Password"
    }

    
    
     func suscribeToKeyboardWillShowNotification(){
        if view.frame.origin.y == 0{
            NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)}
    }
    
     func unsuscribeToNotificationCenter(){
        NotificationCenter.default.removeObserver(self)
    }
    func subscribeToKeyboardWillHideNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)}
    
    func keyboardWillShow(_ notification: Notification) {
        if view.frame.origin.y == 0 && (usernameTextField.isFirstResponder || passwordTextField.isFirstResponder){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    func keyboardWillHide(_ notification: Notification){
        if view.frame.origin.y != 0{
            view.frame.origin.y = 0}
    }
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    
    func changeAlphaFor(_ views: [UIView], alpha: CGFloat){
        
        for view in views{
            view.alpha = alpha
        }
    }
    
    func reach(){
        Reachability.isConnectedToNetwork(){(x) in
        print("value is \(x)")
        if x == false {
            performUIUpdatesOnMain {
                self.networkError()
            }
        }
        }
    }
    
    func networkError(){
        
        let alert = UIAlertController(title: "Error",message: "Unable To Connect To Internet",preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss" ,style: .default,handler: nil))
         self.present(alert, animated: true, completion: nil)
        
    }
}

