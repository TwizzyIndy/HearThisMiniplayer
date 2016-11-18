//
//  networking.swift
//  HearThis
//
//  Created by Manuel Meyer on 18.11.16.
//  Copyright © 2016 Manuel Meyer. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkFetching {
    func get(url: NSURL, parameters: [String:Any],  response: @escaping ((FetchResult<[[String:Any]]>) -> Void))
}



protocol NetworkConnecting: NetworkFetching {
    
}

class NetworkConnector: NetworkConnecting {
    func get(url: NSURL, parameters: [String : Any], response: @escaping ((FetchResult<[[String:Any]]>) -> Void)) {
        
        Alamofire.request(url.absoluteString!, method: .get, parameters: parameters).responseJSON {
            networkResponse in
            switch networkResponse.result {
            case .success(let value):
                if let value = value as? [[String: Any]] {
                    response(FetchResult.success(value))
                } else {
                    response(FetchResult.error(FetchingError.undefined("Format error")))
                }
            case .failure(let error):
                response(FetchResult.error(error))
            }
        }
    }
}

class NetworkConnectorMock: NetworkConnecting {
    func get(url: NSURL, parameters: [String : Any], response: @escaping ((FetchResult<[[String : Any]]>) -> Void)) {
        response(FetchResult.success([["user":["id": "4711", "username":"Troubardix", "avatar_url":"https://Troubardix"]],
                                      ["user":["id": "2342", "username":"Walther von der Vogelweide", "avatar_url":"https://walther"]]])
        )
    }
}

enum FetchingError: Error {
    case undefined(String)
}


enum FetchResult<T> {
    case success(T)
    case error(Error)
}
