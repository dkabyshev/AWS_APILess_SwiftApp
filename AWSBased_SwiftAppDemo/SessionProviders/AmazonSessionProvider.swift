//
//  AmazonSessionProvider.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/22/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation

enum AmazonSessionProviderErrors: Error {
    case RestoreSessionFailed
    case LoginFailed
}

extension Error {
    var infoMessage: String? {
        return (self as NSError).userInfo["message"] as? String
    }
}

protocol AmazonSessionProvider {
    /**
     Each entry in logins represents a single login with an identity provider.
     The key is the domain of the login provider (e.g. 'graph.facebook.com')
     and the value is the OAuth/OpenId Connect token that results from an authentication with that login provider.
     */
    func getSessionTokens(completition: @escaping (([String : String]?, Error?) -> ()))
    func isLoggedIn() -> Bool
    func logout()
}
