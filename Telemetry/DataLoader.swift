//
//  DataLoader.swift
//  Telemetry
//
//  Created by Agentum on 13.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift


class DataLoader<E: BaseResponse> {
    
    var STATUS_SUCCESS = "success"
    var STATUS_FAIL = "fail"

    func load(observable: Observable<E>) -> Observable<E>{
        return observable
                .catchError({ (errType) -> Observable<E> in
                    return Observable.error(RxError.Unknown)
                })
                .flatMap({ (element) -> Observable<E> in
                    let status = element.status ?? ""
                    if(status == self.STATUS_SUCCESS){
                        return Observable.just(element)
                    } else {
                        return Observable.error(RxError.Unknown)
                    }
                })
        
    }
}
