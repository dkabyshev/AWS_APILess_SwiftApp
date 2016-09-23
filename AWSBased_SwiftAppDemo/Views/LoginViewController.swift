//
//  LoginViewController.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/21/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SVProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginWithEmailButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var onCreareAccount: (() -> ())?
    
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onError = { [weak self] in
            self?.showAlertError(message: $0)
        }
        viewModel.isLoading = {
            $0 == true ? SVProgressHUD.show() : SVProgressHUD.dismiss()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
}

extension LoginViewController {
    @IBAction func createAccountAction(sender: AnyObject) {
        onCreareAccount?()
    }
    
    @IBAction func loginWithEmailAction(sender: AnyObject) {
        viewModel.login(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    
    @IBAction func loginWithFacebookAction(sender: AnyObject) {
        loginToFacebookWithSuccess(successBlock: { [weak self] (token) -> () in
            self?.viewModel.login(fbToken: token)
        }, andFailure: { _ in
//            let murmur = Murmur(title: "Failed to login via Facebook",
//                backgroundColor: UIColor.snwSalmon15Color(),
//                titleColor: UIColor.snwOrangeyRedColor(),
//                font: UIFont(name: "AvalonT", size: 12)!)
//            delay(1) {
//                MainQueue.run() {
//                    show(whistle: murmur, action: .Show(0.5))
//                }
//            }
        })
    }
}

extension LoginViewController {
    func loginToFacebookWithSuccess(successBlock: @escaping (String) -> (),
                                    andFailure failureBlock: @escaping (NSError?) -> ()) {
        let facebookReadPermissions = ["public_profile", "email"]
        if FBSDKAccessToken.current() != nil {
            //For debugging, when we want to ensure that facebook login always happens
            FBSDKLoginManager().logOut()
        }
        
        FBSDKLoginManager().logIn(withReadPermissions: facebookReadPermissions, from: self) { (result, error) in
            guard let token = result?.token.tokenString, error == nil else {
                // Handle cancellations
                FBSDKLoginManager().logOut()
                failureBlock(nil)
                return
            }
            successBlock(token)
        }
    }
}
