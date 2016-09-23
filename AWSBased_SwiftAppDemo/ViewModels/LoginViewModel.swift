//
//  LoginViewModel.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/22/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation

final class LoginViewModel {
    var isLoading: ((Bool) -> ())?
    var onError: ((String) -> ())?
    var onDone: (() -> ())?
    
    init() {
    }
    
    func login(email: String, password: String) {
        guard !email.isEmpty && !password.isEmpty else {
            onError?("All fields are required.")
            return
        }
        let sessionProvider = LoginUserPoolSessionProvider(username: email, password: password)
        AmazonClientManager.shared.login(sessionProvider: sessionProvider) { [unowned self] (error) in
            guard error == nil else {
                AmazonClientManager.shared.clearAll()
                DispatchQueue.main.async { [weak self] in
                    self?.onError?(error?.infoMessage ?? "Failed to login")
                }
                return
            }
            self.onDone?()
        }
    }
    
    func login(fbToken: String) {
        isLoading?(true)
        let params = ["fields": "id, email, first_name, last_name"]
        let sessionProvider = FBSessionProvider()
        AmazonClientManager.shared.login(sessionProvider: sessionProvider) { [unowned self] (error) in
            guard error == nil else {
                AmazonClientManager.shared.clearAll()
                DispatchQueue.main.async { [weak self] in
                    self?.onError?(error?.infoMessage ?? "Failed to login with Facebook")
                }
                return
            }
            // Sync user profile from CognitoSync storage
            CognitoUser.sync() { [unowned self] _ in
                let user = CognitoUser.currentUser()
                if user.firstName == nil || user.lastName == nil {
                    // Fetch basic info from Facebook, e.g. first and last name
                    executeFBRequest(path: "me", params: params) { (data, error) in
                        if error != nil {
                            DispatchQueue.main.async { [weak self] in
                                self?.onError?(error?.infoMessage ?? "Failed to login with Facebook")
                            }
                        }
                        user.firstName = data?["first_name"] as? String
                        user.lastName = data?["last_name"] as? String
                        user.email = data?["email"] as? String
                        // Save info and proceed
                        user.save() { (done) in
                            guard done == true else {
                                DispatchQueue.main.async { [weak self] in
                                    self?.onError?("Failed to login with Facebook")
                                }
                                return
                            }
                            self.onDone?()
                        }
                    }
                } else {
                    self.onDone?()
                }
            }
        }
    }
}
