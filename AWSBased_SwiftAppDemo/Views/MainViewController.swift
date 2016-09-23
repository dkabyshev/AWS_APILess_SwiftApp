//
//  ViewController.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/21/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import UIKit
import AWSCognito
class MainViewController: UIViewController {
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    
    var viewModel: MainViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameLabel.text = viewModel.firstName
        lastNameLabel.text = viewModel.lastName
    }
    
    @IBAction func logoutAction(_ sender: AnyObject) {
        viewModel.logout()
    }
}
