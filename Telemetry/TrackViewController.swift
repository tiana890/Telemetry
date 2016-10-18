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
import SwiftyJSON
import PKHUD

class TrackViewController: UIViewController, GMSMapViewDelegate {
    
    var autoId: Int64?
    var trackParams: (startDate: Int64?, endDate: Int64?)?
    
    var viewModel: TrackViewModel?
    var trackClient: TrackClient?

    @IBOutlet var infoView: UIVisualEffectView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var infoLabel: UILabel!
    
    var disposeBag: DisposeBag? = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = GMSMapView(frame: self.view.frame)
        mapView!.delegate = self
        self.view.addSubview(mapView!)
        self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude:  55.75222, longitude: 37.61556), zoom: 14, bearing: 0, viewingAngle: 0)
        
        trackClient = TrackClient(_token: ApplicationState.sharedInstance.getToken() ?? "", _autoId: autoId ?? 0, _startTime: self.trackParams?.startDate ?? 0, _endTime: self.trackParams?.endDate ?? 0)
        viewModel = TrackViewModel(trackClient: trackClient!)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustInfoView()
        addBindsToViewModel()
    }
    
    func adjustInfoView(){
        self.view.bringSubview(toFront: self.infoView)
        
    }
    
    func addBindsToViewModel(){
        
        self.viewModel!.track.observeOn(MainScheduler.instance)
            .subscribe(onNext: { (tr) in
                    self.showTrackOnMap(tr)
                }, onError: { (err) in
                    
                }, onCompleted: { 
                    print("completed")
                }, onDisposed: { 
                    print("disposed")
            })
            .addDisposableTo(self.disposeBag!)
        
    }
    
    func showTrackOnMap(_ track: Track){
        let marker = GMSMarker()
        marker.map = self.mapView
        
        self.mapView.selectedMarker = marker
        
        if let markerIconView = Bundle.main.loadNibNamed("MarkerIcon", owner: self, options: nil)?[0] as? MarkerIcon{
            marker.iconView = markerIconView
        }
        
        guard let trackArray = track.trackArray else { return }
        
        if trackArray.count > 0 {
            let trackItem = trackArray[0]
            if(trackItem.lat != nil && trackItem.lon != nil){
                marker.position = CLLocationCoordinate2D(latitude: Double(trackItem.lat!)!, longitude: Double(trackItem.lon!)!)
                (marker.iconView as! MarkerIcon).carImage.transform = CGAffineTransform(rotationAngle: self.DegreesToRadians(CGFloat(Float(trackItem.azimut ?? "0")!)))
                marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                self.mapView.camera = GMSCameraPosition(target: marker.position, zoom: 12, bearing: 0, viewingAngle: 0)
                if let interval = trackItem.time{
                    self.infoLabel.text = Date(timeIntervalSince1970: Double(interval)).toRussianString()
                } else {
                    self.infoLabel.text = ""
                }
            }
        }
     
        print("Track array count = \(trackArray.count)")
        Observable<Int>.timer(0, period: 0.1, scheduler: MainScheduler.instance)
            .take(Double(trackArray.count)*0.1, scheduler: MainScheduler.instance)
            .subscribeNext {(val) in
                if(trackArray.count >= val){
                    let trackItem = trackArray[val]
                    if(trackItem.lat != nil && trackItem.lon != nil){
                        marker.position = CLLocationCoordinate2D(latitude: Double(trackItem.lat!)!, longitude: Double(trackItem.lon!)!)
                        (marker.iconView as! MarkerIcon).carImage.transform = CGAffineTransform(rotationAngle: self.DegreesToRadians(CGFloat(Float(trackItem.azimut ?? "0")!)))
                        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                        let update = GMSCameraUpdate.setCamera(GMSCameraPosition(target: marker.position, zoom: 12, bearing: 0, viewingAngle: 0))
                        self.mapView.animate(with: update)
                        if let interval = trackItem.time{
                            self.infoLabel.text = Date(timeIntervalSince1970: Double(interval)).toRussianString()
                        } else {
                            self.infoLabel.text = ""
                        }
                    }
                }
                print(val)
        }.addDisposableTo(self.disposeBag!)

    }
    
    func moveMarker(_ marker: GMSMarker){
        
    }

    func createObservableFromArray(_ array: [TrackItem]) -> Observable<TrackItem>{
        return Observable.create({ (observer) -> Disposable in
            for(trackItem) in array{
                observer.on(.next(trackItem))
            }
            observer.on(.completed)
            return AnonymousDisposable{
            }
        })
    }


    //GMSMapViewDelegate
    //MARK: GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let item = marker.userData as? TrackItem else { return nil }
        
        if let markerView = Bundle.main.loadNibNamed("MarkerWindow", owner: self, options: nil)?[0] as? MarkerWindow{
//            markerView.company.text = item.speed
//            markerView.regNumber.text = auto.registrationNumber
//            markerView.model.text = auto.model
//            
//            if let lastUpdate = auto.lastUpdate{
//                let date = NSDate(timeIntervalSince1970: Double(lastUpdate))
//                let dateFormatter = NSDateFormatter()
//                dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
//                markerView.lastUpdate.text = dateFormatter.stringFromDate(date)
//            } else {
//                markerView.lastUpdate.text = ""
//            }
            return markerView
        }
        return nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.disposeBag = nil
    }
    
    func DegreesToRadians(_ degrees: CGFloat) -> CGFloat{
        return CGFloat(Double(degrees) * M_PI/180)
    }
    
    deinit{
        print("DEINIT")
    }

    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
