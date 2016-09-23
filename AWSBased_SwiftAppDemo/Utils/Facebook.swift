//
//  Facebook.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/22/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation
import FBSDKCoreKit

/**
 Executes one Facebook Graph request
 - path: a graph path for request
 - params: optional params to send with request
 - returns: Observable with DataProviderResult, in case of success the data is a dictionary
 */
func executeFBRequest(path: String, params: [String : String]?, completition: (([String:AnyObject]?, Error?) -> ())?){
    let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: path, parameters: params)
    _ = graphRequest.start {(connection, result, error) -> Void in
        completition?(result as? [String:AnyObject], error)
    }
}
