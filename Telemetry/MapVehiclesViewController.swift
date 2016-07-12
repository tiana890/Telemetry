//
//  MapVehiclesViewController.swift
//  Telemetry
//
//  Created by IMAC  on 12.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift

class MapVehiclesViewController: UIViewController {
    let viewModel = VehiclesViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.vehicles.bindTo(self.label.rx_text).addDisposableTo(self.disposeBag)
    }
}
