//
//  SignupViewModel.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/22/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation

final class SignupViewModel {
    var isLoading: ((Bool) -> ())?
    var onError: ((String) -> ())?
    var onDone: (() -> ())?
    
    init() {
    }
    
    func singup(email: String, password: String, firstName: String, lastName: String) {
        guard !email.isEmpty && !password.isEmpty && !firstName.isEmpty && !lastName.isEmpty else {
            onError?("All fields are required.")
            return
        }
        guard password.characters.count > 5 else {
            onError?("Password is too short (at least 6 symbols).")
            return
        }
        
        isLoading?(true)
        let sessionProvider = SignupUserPoolSessionProvider(username: email, password: password)
        AmazonClientManager.shared.login(sessionProvider: sessionProvider) { [weak self] (error) in
            guard error == nil else {
                self?.isLoading?(false)
                AmazonClientManager.shared.clearAll()
                self?.onError?(error?.infoMessage ?? "Failed to create new user")
                return
            }
            // Save new user
            let user = CognitoUser()
            user.firstName = firstName
            user.lastName = lastName
            user.email = email
            // Save info and proceed
            user.save() { (done) in
                self?.isLoading?(false)
                guard done else {
                    AmazonClientManager.shared.clearAll()
                    self?.onError?(error?.infoMessage ?? "Failed to create new user")
                    return
                }
                self?.onDone?()
            }
        }
    }
}
