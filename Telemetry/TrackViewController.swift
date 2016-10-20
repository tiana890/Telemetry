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
    
    enum Speed: Int{
        case original = 1
        case x2 = 2
        case x3 = 3
        case x5 = 5
        case x10 = 10
    }
    
    var speed: Speed = .original
    var animationPeriod = 0.8
    
    var autoId: Int?
    var trackParams: (startDate: Int64?, endDate: Int64?)?
    
    var viewModel: TrackViewModel?
    var trackClient: TrackClient?
    var track: Track?

    @IBOutlet var infoView: UIVisualEffectView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
    var zoom = 12
    
    var disposeBag: DisposeBag? = DisposeBag()

    var iterationIndex = 0
    
    //MARK:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = GMSMapView(frame: self.view.frame)
        mapView!.delegate = self
        self.view.addSubview(mapView!)
        self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude:  55.75222, longitude: 37.61556), zoom: 10, bearing: 0, viewingAngle: 0)
        
        trackClient = TrackClient(_token: ApplicationState.sharedInstance.getToken() ?? "", _autoId: self.autoId ?? 0, _startTime: self.trackParams?.startDate ?? 0, _endTime: self.trackParams?.endDate ?? 0)
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
        
        HUD.show(.labeledProgress(title: "", subtitle: "Загрузка данных о треке"))
        self.viewModel!.track.observeOn(MainScheduler.instance)
            .subscribe(onNext: { (tr) in
                if((tr.trackArray?.count ?? 0) > 0){
                    self.track = tr
                    HUD.flash(.success)
                } else {
                    HUD.flash(.labeledError(title: "Внимание", subtitle: "Нет информации по данному запросу"), delay: 2.0, completion: { (val) in
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                    self.showTrackOnMap(tr)
                }, onError: { (err) in
                    var errorMsg = "Нет информации по данному запросу"
                    if(err is APIError){
                        errorMsg = (err as! APIError).getReason()
                    }
                    HUD.flash(.labeledError(title: "Внимание", subtitle: errorMsg), delay: 3.0, completion: { (val) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                }, onCompleted: { 
                    print("completed")
                }, onDisposed: { 
                    print("disposed")
            })
            .addDisposableTo(self.disposeBag!)
        
    }
    
    func showTrackOnMap(_ track: Track){
        
        self.mapView.clear()
        self.disposeBag = DisposeBag()
        let marker = GMSMarker()
        marker.map = self.mapView
        
        self.mapView.selectedMarker = marker
        
        if let markerIconView = Bundle.main.loadNibNamed("MarkerIcon", owner: self, options: nil)?[0] as? MarkerIcon{
            if let aId = self.autoId{
                if let auto = RealmManager.getAutoById(aId){
                    markerIconView.registrationNumber.text = PreferencesManager.showGarageNumber() ? (auto.garageNumber ?? "") : (auto.registrationNumber ?? "")
                    marker.iconView = markerIconView
                }
            }
        }
        
        guard let trArray = track.trackArray else { return }
        
        var trackArray = [TrackItem]()
        trackArray.append(contentsOf: trArray)
        
        trackArray.removeSubrange(0 ..< iterationIndex)
        
        if trackArray.count > 0 {
            self.moveMarker(marker, trackItem: trackArray[0], animated: false)
        }
     
        Observable<Int>.timer(0, period: animationPeriod/Double(self.speed.rawValue), scheduler: MainScheduler.instance)
            .take(trackArray.count)
            .subscribe { [unowned self](event) in
                guard let element = event.element else { return }
                self.iterationIndex += 1
                if(trackArray.count >= element){
                    self.moveMarker(marker, trackItem: trackArray[element], animated: true)
                }
        }.addDisposableTo(self.disposeBag!)

    }
    
    func moveMarker(_ marker: GMSMarker, trackItem: TrackItem, animated: Bool){
        guard (trackItem.lat != nil && trackItem.lon != nil) else { return }
        
        marker.position = CLLocationCoordinate2D(latitude: Double(trackItem.lat!)!, longitude: Double(trackItem.lon!)!)
        (marker.iconView as! MarkerIcon).carImage.transform = CGAffineTransform(rotationAngle: self.DegreesToRadians(CGFloat(Float(trackItem.azimut ?? "0")!)))
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        
        if let interval = trackItem.time{
            self.infoLabel.text = Date(timeIntervalSince1970: Double(interval)).toRussianString()
        } else {
            self.infoLabel.text = ""
        }
        
        guard animated else {
            
            self.mapView.camera = GMSCameraPosition(target: marker.position, zoom: self.mapView.camera.zoom, bearing: 0, viewingAngle: 0)
            return
        }
        let update = GMSCameraUpdate.setCamera(GMSCameraPosition(target: marker.position, zoom: self.mapView.camera.zoom, bearing: 0, viewingAngle: 0))
        self.mapView.animate(with: update)
        
        if let interval = trackItem.time{
            self.infoLabel.text = Date(timeIntervalSince1970: Double(interval)).toRussianString()
        } else {
            self.infoLabel.text = ""
        }

    }

    func createObservableFromArray(_ array: [TrackItem]) -> Observable<TrackItem>{
        return Observable.create({ (observer) -> Disposable in
            for(trackItem) in array{
                observer.on(.next(trackItem))
            }
            observer.on(.completed)
            return Disposables.create{
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
    

    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        var newSpeed: Speed = self.speed
        switch sender.selectedSegmentIndex {
        case 0:
            newSpeed = Speed.original
            break
        case 1:
            newSpeed = Speed.x2
            break
        case 2:
            newSpeed = Speed.x3
            break
        case 3:
            newSpeed = Speed.x5
            break
        case 4:
            newSpeed = Speed.x10
            break
        default:
            break
        }
        if(newSpeed.rawValue != self.speed.rawValue){
            self.speed = newSpeed
            self.showTrackOnMap(self.track!)
        }
    }
    
    
}
