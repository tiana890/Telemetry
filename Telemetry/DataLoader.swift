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

    func load(observable: Observable<E>) -> Observable<E>{
        return observable
                .catchError({ (errType) -> Observable<E> in
                    return Observable.error(RxError.Unknown)
                })
                .flatMap({ (element) -> Observable<E> in
                    let status = element.status ?? Status.Error
                    if(status == Status.Success){
                        return Observable.just(element)
                    } else {
                        return Observable.error(RxError.Unknown)
                    }
                })
        
    }
}
