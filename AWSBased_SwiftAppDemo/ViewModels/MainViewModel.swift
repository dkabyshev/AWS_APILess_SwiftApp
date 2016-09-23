//
//  MainViewModel.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/22/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation

final class MainViewModel {
    var firstName: String?
    var lastName: String?
    
    init() {
        let user = CognitoUser.currentUser()
        firstName = user.firstName
        lastName = user.lastName
    }
    
    func logout() {
        AmazonClientManager.shared.logOut()
    }
}
