//
//  CognitoUser.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/21/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognito

internal let cognitoSyncDataset = "userProfile"

final class CognitoUser {
    var userId: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    
    init() {
        userId = NSUUID().uuidString
    }
}

extension CognitoUser {
    // Save all user's data to CognitoSync
    func save(completition: @escaping ((Bool) -> ())) {
        // openOrCreateDataset - creates a dataset if it doesn't exists or open existing
        let dataset = AWSCognito(forKey: cognitoSyncKey).openOrCreateDataset(cognitoSyncDataset)
        dataset?.setString(firstName, forKey: "firstName")
        dataset?.setString(lastName, forKey: "lastName")
        dataset?.setString(email, forKey: "email")
        CognitoUser.sync(completition: completition)
    }
    
    static func sync(completition: @escaping ((Bool) -> ())) {
        // openOrCreateDataset - creates a dataset if it doesn't exists or open existing
        let dataset = AWSCognito(forKey: cognitoSyncKey).openOrCreateDataset(cognitoSyncDataset)
        // synchronize is going to:
        // 1) Fetch from AWS, if there were any changes
        // 2) Upload local changes to AWS
        dataset?.synchronize().continue({ (task) in
            DispatchQueue.main.async { completition(task.error == nil) }
            return nil
        })
    }
    
    static func currentUser(firstName: String? = nil, lastName: String? = nil) -> CognitoUser {
        let dataset = AWSCognito(forKey: cognitoSyncKey).openOrCreateDataset(cognitoSyncDataset)
        let user = CognitoUser()
        user.userId = dataset?.string(forKey: "userId") ?? NSUUID().uuidString
        user.firstName = dataset?.string(forKey:"firstName")
        user.lastName = dataset?.string(forKey:"lastName")
        user.email = dataset?.string(forKey:"email")
        return user
    }
}
