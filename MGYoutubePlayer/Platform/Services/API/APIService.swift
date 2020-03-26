//
//  APIService.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/22/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

final class API: APIBase {
    static var shared = API()
    
    override func handleResponseError(response: HTTPURLResponse, data: Data, json: JSONDictionary?) -> Error {
        return super.handleResponseError(response: response, data: data, json: json)
    }
    
    override func preprocess(_ input: APIInputBase) -> Observable<APIInputBase> {
        return super.preprocess(input)
    }
}