//
//  CreateAccountViewController.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/21/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateAccountViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var viewModel: SignupViewModel!
    
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
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func signupAction(sender: AnyObject) {
        viewModel.singup(email: emailTextField.text ?? "",
                         password: passwordTextField.text ?? "",
                         firstName: firstNameTextField.text ?? "",
                         lastName: lastNameTextField.text ?? "")
    }
}
