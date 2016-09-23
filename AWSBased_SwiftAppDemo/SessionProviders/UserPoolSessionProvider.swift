//
//  UserPoolSessionProvider.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/22/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider
import UICKeyChainStore

let KEYCHAIN_SESSION_KEY = "CognitoPoolKey"

class UserPoolSessionProvider: AmazonSessionProvider  {
    internal let awsUserPool: AWSCognitoIdentityUserPool
    private let keyChain: UICKeyChainStore
    
    init() {
        // Initialize AWS User Pool with separate configuration and empty credentials
        keyChain = UICKeyChainStore(service: Bundle.main.bundleIdentifier!)
        let configuration = AWSServiceConfiguration(region: COGNITO_REGIONTYPE, credentialsProvider: nil)
        let config = AWSCognitoIdentityUserPoolConfiguration(clientId: COGNITO_USERPOOL_KEY,
                                                             clientSecret: COGNITO_USERPOOL_SECRET_KEY,
                                                             poolId: COGNITO_USERPOOL_ID)
        AWSCognitoIdentityUserPool.register(with: configuration,userPoolConfiguration: config, forKey: "userpool")
        awsUserPool = AWSCognitoIdentityUserPool(forKey: "userpool")
    }

    func getSessionTokens(completition: @escaping (([String : String]?, Error?) -> ())) {
        if let user = awsUserPool.currentUser() {
            // Try to restore prev. session
            completeWith(task: user.getSession(), completition: completition)
        } else {
            completition(nil, AmazonSessionProviderErrors.RestoreSessionFailed)
        }
    }
    
    internal func completeWith(task: AWSTask<AWSCognitoIdentityUserSession>,
                               completition: @escaping (([String : String]?, Error?) -> ())) {
        // Execute AWSTask to get AWSCognitoIdentityUserSession, usualy getSession(...)
        task.continue({ [weak self] (task) in
            guard let session = task.result, task.error == nil else {
                completition(nil, task.error)
                return nil
            }
            self?.keyChain[KEYCHAIN_PROVIDER_KEY] = AmazonSessionProviderType.USERPOOL.rawValue
            self?.keyChain[KEYCHAIN_SESSION_KEY] = session.idToken?.tokenString ?? ""
            completition([COGNITO_USERPOOL_PROVIDER : session.idToken?.tokenString ?? ""], nil)
            return nil
        })
    }
    
    func isLoggedIn() -> Bool {
        return awsUserPool.currentUser()?.isSignedIn ?? false
    }
    
    func logout() {
        keyChain[KEYCHAIN_SESSION_KEY] = nil
        awsUserPool.clearAll()
    }
}
