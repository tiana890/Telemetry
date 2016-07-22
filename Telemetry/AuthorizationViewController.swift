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
    let MAPS_SEGUE_IDENTIFIER = "mapsSegue"
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginTxtField: UITextField!
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBindsToViewModel()
        
    }
    
    func addBindsToViewModel(){
        let authViewModel = AuthorizationViewModel(authClient: AuthClient())

        
        passwordTxtField.rx_text.asObservable().bindTo(authViewModel.password).addDisposableTo(self.disposeBag)
        loginTxtField.rx_text.asObservable().bindTo(authViewModel.login).addDisposableTo(self.disposeBag)
        button.rx_tap
            .bindTo(authViewModel.didPressButton)
            .addDisposableTo(disposeBag)
        
        authViewModel.authModel.subscribeNext { (ath) in
            if(ath.token != nil){
                dispatch_async(dispatch_get_main_queue(), { 
                    self.performSegueWithIdentifier(self.MAPS_SEGUE_IDENTIFIER, sender: ath.token!)
                })
            }
        }.addDisposableTo(self.disposeBag)

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == MAPS_SEGUE_IDENTIFIER){
            if let destVC = segue.destinationViewController as? MapVehiclesViewController{
                destVC.token = (sender as! String)
            }
        }
    }
}
