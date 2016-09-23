//
//  FBSessionProvider.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/22/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider
import FBSDKCoreKit
import FBSDKLoginKit
import UICKeyChainStore

let COGNITO_FB_PROVIDER = "graph.facebook.com"

final class FBSessionProvider: AmazonSessionProvider {
    private let keyChain: UICKeyChainStore
    
    init() {
        keyChain = UICKeyChainStore(service: Bundle.main.bundleIdentifier!)
    }
    
    func getSessionTokens(completition: @escaping (([String : String]?, Error?) -> ())) {
        guard FBSDKAccessToken.current() != nil else {
            completition(nil, AmazonSessionProviderErrors.LoginFailed)
            return
        }
        keyChain[KEYCHAIN_PROVIDER_KEY] = AmazonSessionProviderType.FB.rawValue
        completition([COGNITO_FB_PROVIDER : FBSDKAccessToken.current().tokenString], nil)
    }
    
    func isLoggedIn() -> Bool {
        return FBSDKAccessToken.current() != nil
    }
    
    func logout() {
        FBSDKLoginManager().logOut()
    }
}
