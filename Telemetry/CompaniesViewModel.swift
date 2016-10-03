//
//  OrganizationViewModel.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift


final class CompaniesViewModel{
    
    private let disposeBag = DisposeBag()
    let dataLoader = DataLoader<CompaniesResponse>()
    private let companiesClient: CompaniesClient
    //output
    var companies = PublishSubject<[Company]>()
    
    //MARK: Set up
    init(_companiesClient: CompaniesClient){
        self.companiesClient = _companiesClient
        

//        dataLoader.load(companiesClient.companiesObservable()).observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map { (companiesResponse) -> [Company] in
//            
//            return companiesResponse.companies ?? []
//        }.bindTo(companies).addDisposableTo(self.disposeBag)
    }
    
    func getCompaniesObservable() -> Observable<[Company]>{
        return dataLoader.load(companiesClient.companiesObservable()).map { (companiesResponse) -> [Company] in
            return companiesResponse.companies ?? []
        }
    }
    
}