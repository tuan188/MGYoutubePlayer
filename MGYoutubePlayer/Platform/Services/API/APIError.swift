//
//  APIError.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/22/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

struct APIExpiredTokenError: APIError {
    var errorDescription: String? {
        return NSLocalizedString("api.expiredTokenError",
                                 value: "Access token is expired",
                                 comment: "")
    }
}

struct APIResponseError: APIError {
    let statusCode: Int?
    let message: String
    
    var errorDescription: String? {
        return message
    }
}