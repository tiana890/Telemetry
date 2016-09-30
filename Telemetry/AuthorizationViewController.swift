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
    static let AUTH_SUCCESS_SEGUE_IDENTIFIER = "authSuccessSegueIdentifier"
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginTxtField: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicator.hidden = true
        
        Observable.combineLatest(passwordTxtField.rx_text, loginTxtField.rx_text) { (txt1, txt2) -> Bool in
            if(txt1.characters.count > 0 && txt2.characters.count > 0){
                return true
            }
            return false
            }.bindTo(enterButton.rx_enabled).addDisposableTo(self.disposeBag)
        
        enterButton.rx_tap.asObservable().map({ return false }).bindTo(self.indicator.rx_hidden).addDisposableTo(self.disposeBag)
        enterButton.rx_tap.asObservable().map({ return true }).bindTo(self.indicator.rx_animating).addDisposableTo(self.disposeBag)
        enterButton.rx_tap.asObservable().map({ return true }).bindTo(self.enterButton.rx_hidden).addDisposableTo(self.disposeBag)

        self.enterButton.rx_tap
        .subscribeNext { [unowned self] in
            self.addBindsToViewModel()
        }.addDisposableTo(self.disposeBag)
        setObservers()
    }
    
    
    
    func addBindsToViewModel(){
        
        let authViewModel = AuthorizationViewModel(authClient: AuthClient())
        
        authViewModel.authorize(self.loginTxtField.text ?? "", password: self.passwordTxtField.text ?? "")
            .debug()
            .observeOn(MainScheduler.instance)
            .doOnError({ [unowned self](err) in
                self.indicator.hidden = true
                if let error = err as? APIError{
                    self.showAlert("Ошибка", msg: error.getReason())
                } else {
                    self.showAlert("Ошибка", msg: "Невозможно авторизоваться")
                }
                self.enterButton.hidden = false
            })
            .subscribeNext { [unowned self](ath) in
            if(ath.token != nil){
                ApplicationState.sharedInstance().saveToken(ath.token!)
                self.performSegueWithIdentifier(AuthorizationViewController.AUTH_SUCCESS_SEGUE_IDENTIFIER, sender: nil)
            } else {
                self.indicator.hidden = true
                self.showAlert("Ошибка", msg: ath.reason ?? "Невозможно авторизоваться")
                self.enterButton.hidden = false
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("")
    }
        

}
