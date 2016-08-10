//
//  TrackViewController.swift
//  Telemetry
//
//  Created by IMAC  on 10.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import GoogleMaps

class TrackViewController: UIViewController, GMSMapViewDelegate {
    
    var autoId: Int64?
    var trackParams: (startDate: Int64?, endDate: Int64?)?

    @IBOutlet var mapView: GMSMapView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = GMSMapView(frame: self.view.frame)
        mapView!.delegate = self
        self.view.addSubview(mapView!)
        self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude:  55.75222, longitude: 37.61556), zoom: 10, bearing: 0, viewingAngle: 0)
        
        addBindsToViewModel()
    }
    
    func addBindsToViewModel(){
        
        let trackClient = TrackClient(_token: ApplicationState.sharedInstance().getToken() ?? "", _autoId: autoId ?? 0, _startTime: self.trackParams?.startDate ?? 0, _endTime: self.trackParams?.endDate ?? 0)
        let trackViewModel = TrackViewModel(trackClient: trackClient)
        trackViewModel.track.observeOn(MainScheduler.instance)
            .subscribe(onNext: { (tr) in
                print(tr)
                }, onError: { (err) in
                    print(err)
                }, onCompleted: { 
                    
                }, onDisposed: { 
                    
            })
            .addDisposableTo(self.disposeBag)
        
        trackViewModel.track.observeOn(MainScheduler.instance)
        .subscribeError { (err) in
            print(err)
        }.addDisposableTo(self.disposeBag)
        
        
    }
}
