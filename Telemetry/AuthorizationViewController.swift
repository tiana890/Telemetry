//
//  AuthorizationViewController.swift
//  Telemetry
//
//  Created by Agentum on 13.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift


class AuthorizationViewController: UIViewController {
    let AUTH_SUCCESS_SEGUE_IDENTIFIER = "authSuccessSegueIdentifier"
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginTxtField: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicator.hidden = true
        addBindsToViewModel()
        setObservers()
    }
    
    func addBindsToViewModel(){
        
        let authViewModel = AuthorizationViewModel(authClient: AuthClient())
        
        passwordTxtField.rx_text.asObservable().bindTo(authViewModel.password).addDisposableTo(self.disposeBag)
        loginTxtField.rx_text.asObservable().bindTo(authViewModel.login).addDisposableTo(self.disposeBag)
        enterButton.rx_tap
            .bindTo(authViewModel.didPressButton)
            .addDisposableTo(disposeBag)
        
        //authViewModel.didPressButton.asObservable().map({ return false }).bindTo(self.indicator.rx_hidden).addDisposableTo(self.disposeBag)
        //authViewModel.didPressButton.asObservable().map({ return true }).bindTo(self.indicator.rx_animating).addDisposableTo(self.disposeBag)
        
        authViewModel.authModel.observeOn(MainScheduler.instance).subscribeNext { [unowned self](ath) in
            if(ath.token != nil){
                self.performSegueWithIdentifier(self.AUTH_SUCCESS_SEGUE_IDENTIFIER, sender: ath.token!)
            } else {
                self.indicator.hidden = true
                self.showAlert("Ошибка", msg: "Невозможно авторизоваться")
            }
        }.addDisposableTo(self.disposeBag)

    }
    
    func setObservers(){
        
        NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardWillShowNotification).observeOn(MainScheduler.instance).subscribeNext { [unowned self](notification) in
            let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            self.scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0)
        }.addDisposableTo(self.disposeBag)
        
        NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardWillHideNotification).observeOn(MainScheduler.instance).subscribeNext { [unowned self](notification) in
            self.scroll.contentInset = UIEdgeInsetsZero
        }.addDisposableTo(self.disposeBag)
        
    }
    
    //MARK: -Alerts
    
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
            
    }
        
    
    //MARK: -Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == AUTH_SUCCESS_SEGUE_IDENTIFIER){
            if let destVC = segue.destinationViewController as? MapVehiclesViewController{
                destVC.token = (sender as! String)
            }
        }
    }
}
