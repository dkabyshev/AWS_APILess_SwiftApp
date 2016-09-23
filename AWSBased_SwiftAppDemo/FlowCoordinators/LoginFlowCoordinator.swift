//
//  LoginFlowCoordinator.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/21/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation
import Rswift
import AWSCore
import AWSCognitoIdentityProvider
import SVProgressHUD

final class LoginFlowCoordinator: NSObject, FlowCoordinator {
    private let parent: UIViewController
    private var navigation: UINavigationController!

    var onDone: DoneHandler?
    
    init(parent: UIViewController) {
        self.parent = parent
    }
    
    internal func dismiss(completion: @escaping () -> ()) {
        navigation.popToRootViewController(animated: false)
        navigation.dismiss(animated: false, completion: completion)
    }
    
    func present() {
        let login = R.storyboard.login.loginView()!
        navigation = UINavigationController(rootViewController: login)
        let handleLoginDone = { [unowned self] in
            let _ = self.navigation.popToRootViewController(animated: false)
            self.navigation.dismiss(animated: false) {
                self.onDone?()
            }
        }
        login.viewModel = LoginViewModel()
        login.viewModel.onDone = handleLoginDone
        login.onCreareAccount =  { [unowned self] in
            // Show create account screen
            let createAccount = R.storyboard.login.createAccount()!
            createAccount.viewModel = SignupViewModel()
            createAccount.viewModel.onDone = handleLoginDone
            self.navigation.pushViewController(createAccount, animated: true)
        }
        parent.present(navigation, animated: true, completion: nil)
    }
}
