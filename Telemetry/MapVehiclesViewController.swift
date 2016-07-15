//
//  MapVehiclesViewController.swift
//  Telemetry
//
//  Created by IMAC  on 12.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON

class MapVehiclesViewController: UIViewController{
    
    var viewModel :VehiclesViewModel?
    let disposeBag = DisposeBag()
    
    var token: String?
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: token ?? ""))
        self.addBindsToViewModel()
    }
    
    func addBindsToViewModel(){
        viewModel?.vehicles.bindTo(label.rx_text).addDisposableTo(self.disposeBag)
    }
    
}


