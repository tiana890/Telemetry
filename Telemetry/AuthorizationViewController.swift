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
        
        self.indicator.isHidden = true
        
        Observable.combineLatest(passwordTxtField.rx_text, loginTxtField.rx_text) { (txt1, txt2) -> Bool in
            if((txt1?.characters.count)! > 0 && (txt2?.characters.count)! > 0){
                return true
            }
            return false
            }.bindTo(enterButton.rx.enabled).addDisposableTo(self.disposeBag)
        
        enterButton.rx.tap.asObservable().map({ return false }).bindTo(self.indicator.rx.hidden).addDisposableTo(self.disposeBag)
        enterButton.rx.tap.asObservable().map({ return true }).bindTo(self.indicator.rx.animating).addDisposableTo(self.disposeBag)
        enterButton.rx.tap.asObservable().map({ return true }).bindTo(self.enterButton.rx.hidden).addDisposableTo(self.disposeBag)

        self.enterButton.rx.tap
        .subscribeNext { [unowned self] in
            self.addBindsToViewModel()
        }.addDisposableTo(self.disposeBag)
        setObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loginTxtField.text = "admin"
        self.passwordTxtField.text = "Bn1@v&ubDqJ#5Rv75!md"
    }
    
    func addBindsToViewModel(){
        
        let authViewModel = AuthorizationViewModel(authClient: AuthClient())
        
        authViewModel.authorize(self.loginTxtField.text ?? "", password: self.passwordTxtField.text ?? "")
            .debug()
            .observeOn(MainScheduler.instance)
            .doOnError(onError: { [unowned self](err) in
                self.indicator.isHidden = true
                if let error = err as? APIError{
                    self.showAlert("Ошибка", msg: error.getReason())
                } else {
                    self.showAlert("Ошибка", msg: "Невозможно авторизоваться")
                }
                self.enterButton.isHidden = false
            })
            .subscribeNext { [unowned self](ath) in
            if(ath.token != nil){
                ApplicationState.sharedInstance.saveToken(ath.token!)
                self.performSegue(withIdentifier: AuthorizationViewController.AUTH_SUCCESS_SEGUE_IDENTIFIER, sender: nil)
            } else {
                self.indicator.isHidden = true
                self.showAlert("Ошибка", msg: ath.reason ?? "Невозможно авторизоваться")
                self.enterButton.isHidden = false
            }
        }.addDisposableTo(self.disposeBag)
        

    }
    
    func setObservers(){
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow).observeOn(MainScheduler.instance).subscribeNext { [unowned self](notification) in
            let keyboardFrame: CGRect = ((notification as NSNotification).userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            self.scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0)
        }.addDisposableTo(self.disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide).observeOn(MainScheduler.instance).subscribeNext { [unowned self](notification) in
            self.scroll.contentInset = UIEdgeInsets.zero
        }.addDisposableTo(self.disposeBag)
        
    }
    
    //MARK: -Alerts
    
    func showAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
            
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("")
    }
        

}
