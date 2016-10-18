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
        
        trackClient = TrackClient(_token: ApplicationState.sharedInstance().getToken() ?? "", _autoId: autoId ?? 0, _startTime: self.trackParams?.startDate ?? 0, _endTime: self.trackParams?.endDate ?? 0)
        viewModel = TrackViewModel(trackClient: trackClient!)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustInfoView()
        addBindsToViewModel()
    }
    
    func adjustInfoView(){
        self.view.bringSubviewToFront(self.infoView)
        
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
    
    func showTrackOnMap(track: Track){
        let marker = GMSMarker()
        marker.map = self.mapView
        
        self.mapView.selectedMarker = marker
        
        if let markerIconView = NSBundle.mainBundle().loadNibNamed("MarkerIcon", owner: self, options: nil)[0] as? MarkerIcon{
            marker.iconView = markerIconView
        }
        
        guard let trackArray = track.trackArray else { return }
        
        if trackArray.count > 0 {
            let trackItem = trackArray[0]
            if(trackItem.lat != nil && trackItem.lon != nil){
                marker.position = CLLocationCoordinate2D(latitude: Double(trackItem.lat!)!, longitude: Double(trackItem.lon!)!)
                (marker.iconView as! MarkerIcon).carImage.transform = CGAffineTransformMakeRotation(self.DegreesToRadians(CGFloat(Float(trackItem.azimut ?? "0")!)))
                marker.groundAnchor = CGPointMake(0.5, 0.5)
                self.mapView.camera = GMSCameraPosition(target: marker.position, zoom: 12, bearing: 0, viewingAngle: 0)
                if let interval = trackItem.time{
                    self.infoLabel.text = NSDate(timeIntervalSince1970: Double(interval)).toRussianString()
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
                        (marker.iconView as! MarkerIcon).carImage.transform = CGAffineTransformMakeRotation(self.DegreesToRadians(CGFloat(Float(trackItem.azimut ?? "0")!)))
                        marker.groundAnchor = CGPointMake(0.5, 0.5)
                        let update = GMSCameraUpdate.setCamera(GMSCameraPosition(target: marker.position, zoom: 12, bearing: 0, viewingAngle: 0))
                        self.mapView.animateWithCameraUpdate(update)
                        if let interval = trackItem.time{
                            self.infoLabel.text = NSDate(timeIntervalSince1970: Double(interval)).toRussianString()
                        } else {
                            self.infoLabel.text = ""
                        }
                    }
                }
                print(val)
        }.addDisposableTo(self.disposeBag!)

    }
    
    func moveMarker(marker: GMSMarker){
        
    }

    func createObservableFromArray(array: [TrackItem]) -> Observable<TrackItem>{
        return Observable.create({ (observer) -> Disposable in
            for(trackItem) in array{
                observer.on(.Next(trackItem))
            }
            observer.on(.Completed)
            return AnonymousDisposable{
            }
        })
    }


    //GMSMapViewDelegate
    //MARK: GMSMapViewDelegate
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let item = marker.userData as? TrackItem else { return nil }
        
        if let markerView = NSBundle.mainBundle().loadNibNamed("MarkerWindow", owner: self, options: nil)[0] as? MarkerWindow{
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.disposeBag = nil
    }
    
    func DegreesToRadians(degrees: CGFloat) -> CGFloat{
        return CGFloat(Double(degrees) * M_PI/180)
    }
    
    deinit{
        print("DEINIT")
    }

    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
