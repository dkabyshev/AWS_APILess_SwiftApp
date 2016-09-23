//
//  UIViewController_ex.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/22/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertError(message: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: message,
                                                preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}
