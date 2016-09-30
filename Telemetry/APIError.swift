//
//  APIError.swift
//  Telemetry
//
//  Created by IMAC  on 05.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit

enum APIErrorType: String{
    case NETWORK
    case UNKNOWN
    case CLOSE_SOCKET
    case NONE
}

class APIError: ErrorType {
    private var reason: String?
    var errorCode: Int?
    var errType: APIErrorType = .UNKNOWN
    
    init(errType: APIErrorType){
        self.errType = errType
    }
    
    init(_errType: APIErrorType, _reason: String?){
        self.errType = _errType
        self.reason = _reason
    }
    
    init(_errCode: Int?, _reason: String? ){
        self.errorCode = _errCode
        self.reason = _reason
    }

    func getReason() -> String{
        if let reas = self.reason {
            return reas
        }
        
        switch errType {
        case .NETWORK:
            return "Проверьте сетевое соединение"
        case .UNKNOWN:
            return "Неизвестная ошибка"
        default:
            return ""
            break
        }
    }
}
