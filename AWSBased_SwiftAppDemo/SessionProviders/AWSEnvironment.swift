//
//  AWSEnvironment.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/22/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation
import AWSCore

let COGNITO_REGIONTYPE = AWSRegionType.unknown // e.g. AWSRegionType.USEast1
let COGNITO_REGIONTYPE_STR = "" // Your Cognito region, e.g us-east-1
let COGNITO_IDENTITYPOOL_ID = "" // e.g. "us-east-1:111e111-8efa-dead-b8d7-11c7f4e00de1"
let COGNITO_USERPOOL_ID = ""
let COGNITO_USERPOOL_KEY = ""
let COGNITO_USERPOOL_SECRET_KEY = ""
let COGNITO_USERPOOL_PROVIDER = "cognito-idp.\(COGNITO_REGIONTYPE_STR).amazonaws.com/\(COGNITO_USERPOOL_ID)"
