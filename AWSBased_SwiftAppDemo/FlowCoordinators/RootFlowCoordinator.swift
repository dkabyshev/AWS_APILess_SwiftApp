//
//  RootFlowCoordinator.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/21/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider
import SVProgressHUD

typealias DoneHandler = (() -> ())

protocol FlowCoordinator {
    func present()
    func dismiss(completion: @escaping () -> ())
}

// --- The purpose of this class is to instantiate the first flow, it could be either login or main
final class RootFlowCoordinator: NSObject {
    private let parent: UIViewController
    private var topFlowCoordinator: FlowCoordinator?
    private var loginFlowCoordinator: FlowCoordinator?
    
    init(parent: UIViewController) {
        self.parent = parent
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(didLogoutHandler),
                                               name: AmazonClientManagerDidLogoutNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func didLogoutHandler() {
        topFlowCoordinator?.dismiss() { [weak self] in
            self?.present()
        }
    }
    
    func present() {
        let loginFlowBlock = { [unowned self] in
            self.topFlowCoordinator = self.loginFlow(parent: self.parent)
            self.topFlowCoordinator?.present()
        }
        // Check if we logged-in and can resume session
        if AmazonClientManager.shared.isLoggedIn() {
            SVProgressHUD.show()
            AmazonClientManager.shared.resumeSession() { [unowned self] (error) in
                guard error == nil else {
                    SVProgressHUD.dismiss()
                    loginFlowBlock()
                    return
                }
                CognitoUser.sync() { _ in
                    SVProgressHUD.dismiss()
                    self.topFlowCoordinator = MainFlowCoordinator(parent: self.parent)
                    self.topFlowCoordinator?.present()
                }
            }
        } else {
            loginFlowBlock()
        }
    }
    
    private func loginFlow(parent: UIViewController) -> LoginFlowCoordinator {
        let login = LoginFlowCoordinator(parent: parent)
        login.onDone = {
            SVProgressHUD.show()
            CognitoUser.sync() { _ in
                SVProgressHUD.dismiss()
                self.topFlowCoordinator = MainFlowCoordinator(parent: self.parent)
                self.topFlowCoordinator?.present()
            }
        }
        return login
    }
    
    private func presentLogin() -> LoginFlowCoordinator {
        if let auth = topFlowCoordinator as? LoginFlowCoordinator {
            return auth
        }
        let login = loginFlow(parent: UIApplication.topViewController() ?? parent)
        loginFlowCoordinator = login
        DispatchQueue.main.async {
            self.loginFlowCoordinator?.present()
        }
        return login
    }
}
