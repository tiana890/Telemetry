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
    @IBOutlet weak var serverTxtField: UITextField!
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicator.isHidden = true
        
        Observable.combineLatest(passwordTxtField.rx_text, loginTxtField.rx_text, serverTxtField.rx_text){ (txt1, txt2, txt3) -> Bool in
            if((txt1?.characters.count)! > 0 && (txt2?.characters.count)! > 0 && (txt3?.characters.count)! > 0){
                return true
            }
            return false
        }.bindTo(enterButton.rx.enabled).addDisposableTo(self.disposeBag)
        
        enterButton.rx.tap.asObservable().map({ return false }).bindTo(self.indicator.rx.hidden).addDisposableTo(self.disposeBag)
        enterButton.rx.tap.asObservable().map({ return true }).bindTo(self.indicator.rx.animating).addDisposableTo(self.disposeBag)
        enterButton.rx.tap.asObservable().map({ return true }).bindTo(self.enterButton.rx.hidden).addDisposableTo(self.disposeBag)

        self.enterButton.rx.tap
        .subscribe { [unowned self] (event) in
            guard !event.isStopEvent else { return }
            if(self.serverTxtField.text!.hasPrefix("http://")){
                PreferencesManager.saveAPIServer(self.serverTxtField.text ?? "")
                self.addBindsToViewModel()
            } else {
                self.indicator.isHidden = true
                self.enterButton.isHidden = false
                self.showAlert("Внимание", msg: "Введите сервер в формате \"http://xxxx.xx\"")
            }
            
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
        
        authViewModel.authorize(self.loginTxtField!.text ?? "", password: self.passwordTxtField!.text ?? "")
            .debug()
            .observeOn(MainScheduler.instance)
            .do(onError: { [unowned self](err) in
                self.indicator.isHidden = true
                if let error = err as? APIError{
                    self.showAlert("Ошибка", msg: error.getReason())
                } else {
                    self.showAlert("Ошибка", msg: "Невозможно авторизоваться")
                }
                self.enterButton.isHidden = false
            })
            .subscribe { [unowned self](event) in
                guard !event.isStopEvent else { return }
                guard let ath = event.element else {
                    self.indicator.isHidden = true
                    self.showAlert("Ошибка", msg: "Невозможно авторизоваться")
                    self.enterButton.isHidden = false
                    return
                }
                if(ath.token != nil){
                    let success = {
                        ApplicationState.sharedInstance.saveToken(ath.token!)
                        self.performSegue(withIdentifier: AuthorizationViewController.AUTH_SUCCESS_SEGUE_IDENTIFIER, sender: nil)
                    }
                    
                    let failure = {
                        self.indicator.isHidden = true
                        self.showAlert("Ошибка", msg: ath.reason ?? "Невозможно получить сервер телеметрии")
                        self.enterButton.isHidden = false
                    }
                    self.loadInfoHandler(token:ath.token!, success: success, failure: failure)

                } else {
                    self.indicator.isHidden = true
                    self.showAlert("Ошибка", msg: ath.reason ?? "Невозможно авторизоваться")
                    self.enterButton.isHidden = false
                }
        }.addDisposableTo(self.disposeBag)
    
    }
    
    func loadInfoHandler(token: String, success: @escaping ()->(), failure: @escaping ()->()){
        let infoClient = InfoClient(_token: token)
        
        infoClient.infoObservable()
        .observeOn(MainScheduler.instance)
        .do(onError: { (err) in
            failure()
        })
        .subscribe { (event) in
            guard !event.isStopEvent else { return }
            guard let info = event.element else {
                failure()
                return
            }
            guard let url = info.url else { return }
            PreferencesManager.saveServer(url)
            success()
            
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
