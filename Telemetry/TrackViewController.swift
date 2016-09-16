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

class TrackViewController: UIViewController, GMSMapViewDelegate {
    
    var autoId: Int64?
    var trackParams: (startDate: Int64?, endDate: Int64?)?
    
    var viewModel: TrackViewModel?
    var trackClient: TrackClient?

    @IBOutlet var mapView: GMSMapView!
    
    let disposeBag = DisposeBag()

    
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
        
        let track = Track()
        
        var trackItem1 = TrackItem(json: JSON(data:"{ \"lat\": 55.75222, \"lon\": 37.61556, \"speed\": 0, \"azimut\": 0, \"time\": 0 }".dataUsingEncoding(NSUTF8StringEncoding)!))
        
        var trackItem2 = TrackItem(json: JSON(data:"{ \"lat\": 55.7722, \"lon\": 37.78, \"speed\": 0, \"azimut\": 0, \"time\": 0 }".dataUsingEncoding(NSUTF8StringEncoding)!))
        
        var trackItem3 = TrackItem(json: JSON(data:"{ \"lat\": 55.7922, \"lon\": 37.61600, \"speed\": 0, \"azimut\": 0, \"time\": 0 }".dataUsingEncoding(NSUTF8StringEncoding)!))
        track.trackArray = []
        track.trackArray?.append(trackItem1)
        track.trackArray?.append(trackItem2)
        track.trackArray?.append(trackItem3)
        self.showTrackOnMap(track)
        //addBindsToViewModel()
    }
    
    func addBindsToViewModel(){
        
        self.viewModel!.track.observeOn(MainScheduler.instance)
            .subscribe(onNext: { (tr) in
                    print(tr)
                }, onError: { (err) in
                    print(err)
                }, onCompleted: { 
                    print("completed")
                }, onDisposed: { 
                    print("disposed")
            })
            .addDisposableTo(self.disposeBag)
        
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
                marker.position = CLLocationCoordinate2D(latitude: Double(trackItem.lat!), longitude: Double(trackItem.lon!))
                self.mapView.camera = GMSCameraPosition(target: marker.position, zoom: 12, bearing: 0, viewingAngle: 0)
            }
        }
        
        //let timer = NSTimer(timeInterval: 3, target: self, selector: #selector(TrackViewController.moveMarker), userInfo: <#T##AnyObject?#>, repeats: <#T##Bool#>)
//        let observableInt = Observable<Int>.interval(3, scheduler: MainScheduler.instance).asObservable()
//        let observableTrackItems = self.createObservableFromArray(trackArray).asObservable()
//        
//        
//        Observable<Int>.timer(3, period: Double(trackArray.count), scheduler: MainScheduler.instance)
//            .subscribeNext { (val) in
//                print(val)
//        }.addDisposableTo(self.disposeBag)
        
        
//        Observable<Int>.interval(3, scheduler: MainScheduler.instance)
//            .flatMap { [unowned self](time) -> Observable<TrackItem> in
//                return self.createObservableFromArray(trackArray)
//            }.subscribeNext { (trackItem) in
//                
//                CATransaction.begin()
//                CATransaction.setAnimationDuration(2)
//                if(trackItem.lat != nil && trackItem.lon != nil){
//                    marker.layer.latitude = Double(trackItem.lat!)
//                    marker.layer.longitude = Double(trackItem.lon!)
//                    let locationUpdate = GMSCameraUpdate.setTarget(marker.position, zoom: 12)
//                    self.mapView.animateWithCameraUpdate(locationUpdate)
//                }
//                
//                CATransaction.commit()
//            }.addDisposableTo(self.disposeBag)
//
//        

//        self.createObservableFromArray(trackArray)
//            .skip(0)
//            .debug()
//            .subscribeNext { (trackItem) in
//                
//                CATransaction.begin()
//                CATransaction.setAnimationDuration(2)
//                if(trackItem.lat != nil && trackItem.lon != nil){
//                    marker.layer.latitude = Double(trackItem.lat!)
//                    marker.layer.longitude = Double(trackItem.lon!)
//                    let locationUpdate = GMSCameraUpdate.setTarget(marker.position, zoom: 12)
//                    self.mapView.animateWithCameraUpdate(locationUpdate)
//                }
//
//                CATransaction.commit()
//                
//        }.addDisposableTo(self.disposeBag)
        

    }
    
    func moveMarker(){
        
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

}
