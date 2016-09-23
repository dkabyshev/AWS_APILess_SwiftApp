//
//  AmazonClientManager.swift
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

let cognitoSyncKey = "cognitoSync"
let AmazonClientManagerDidLogoutNotification = Notification.Name("AmazonClientManagerDidLogoutNotification")
let KEYCHAIN_PROVIDER_KEY = "KEYCHAIN_PROVIDER_KEY"
typealias AmazonClientCompletition = ((Error?) -> ())

enum AmazonSessionProviderType: String {
    case FB, USERPOOL
}

final class AmazonClientManager {
    static let shared = AmazonClientManager()

    private let keyChain: UICKeyChainStore
    private var credentialsProvider: AWSCognitoCredentialsProvider?
    private var sessionProvider: AmazonSessionProvider?
    private let customIdentityProvider: CustomIdentityProvider
    
    var currentIdentity: String? {
        return credentialsProvider?.identityId
    }
    
    init() {
        keyChain = UICKeyChainStore(service: Bundle.main.bundleIdentifier!)
        self.customIdentityProvider = CustomIdentityProvider(tokens: nil)
        #if DEBUG
        AWSLogger.default().logLevel = .verbose
        #endif
        // Check if we have session indicator stored
        if keyChain[KEYCHAIN_PROVIDER_KEY] == AmazonSessionProviderType.FB.rawValue {
            sessionProvider = FBSessionProvider()
        } else if keyChain[KEYCHAIN_PROVIDER_KEY] == AmazonSessionProviderType.USERPOOL.rawValue {
            sessionProvider = UserPoolSessionProvider()
        }
    }
    
    // Tries to initiate a session with given session provider returns an error otherwise
    func login(sessionProvider: AmazonSessionProvider, completion: AmazonClientCompletition?) {
        self.sessionProvider = sessionProvider
        self.resumeSession(completion: completion)
    }
    
    // Tries to restore session or returns an error
    func resumeSession(completion: AmazonClientCompletition?) {
        if let sessionProvider = sessionProvider {
            sessionProvider.getSessionTokens() { [unowned self] (tokens, error) in
                guard let tokens = tokens, error == nil else {
                    completion?(error)
                    return
                }
                self.completeLogin(logins: tokens, completition: completion)
            }
        } else {
            completion?(AmazonSessionProviderErrors.RestoreSessionFailed)
        }
    }
    
    // Removes all associated session and cleans keychain
    func clearAll() {
        if let cognito = AWSCognito(forKey: cognitoSyncKey) {
            cognito.wipe()
        }
        sessionProvider?.logout()
        keyChain.removeAllItems()
        credentialsProvider?.clearKeychain()
        credentialsProvider?.clearCredentials()
        sessionProvider = nil
        customIdentityProvider.tokens = nil
    }
    
    func logOut() {
        clearAll()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: AmazonClientManagerDidLogoutNotification, object: nil)
        }
    }
    
    // Checks if we have logged in before
    func isLoggedIn() -> Bool {
        return sessionProvider?.isLoggedIn() ?? false
    }

    private func completeLogin(logins: [String : String]?, completition: AmazonClientCompletition?) {
        // Here we setup our default configuration with Credentials Provider, which uses our custom Identity Provider
        customIdentityProvider.tokens = logins
        self.credentialsProvider = AWSCognitoCredentialsProvider(regionType: COGNITO_REGIONTYPE,
                                                                 identityPoolId: COGNITO_IDENTITYPOOL_ID,
                                                                 identityProviderManager: customIdentityProvider)

        self.credentialsProvider?.getIdentityId().continue({ (task) in
            if (task.error != nil) {
                completition?(task.error)
            } else {
                let configuration = AWSServiceConfiguration(region: COGNITO_REGIONTYPE,
                                                            credentialsProvider: self.credentialsProvider)
                
                // Save confuguration as default for all AWS services
                // It can be set only once, any subsequent setters are ignored.
                AWSServiceManager.default().defaultServiceConfiguration = configuration
                AWSCognito.register(with: configuration, forKey: cognitoSyncKey)

                completition?(nil)
            }
            return task
        })
    }
}
