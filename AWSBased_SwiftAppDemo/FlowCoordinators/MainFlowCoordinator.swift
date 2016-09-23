//
//  MainFlowCoordinator.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/21/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import Foundation
import Rswift
import SVProgressHUD

final class MainFlowCoordinator: NSObject, FlowCoordinator {
    private let parent: UIViewController
    private var main: UIViewController!
    
    var onDone: DoneHandler?
    
    init(parent: UIViewController) {
        self.parent = parent
    }
    
    internal func dismiss(completion: @escaping () -> ()) {
        main.dismiss(animated: false, completion: completion)
    }
    
    func present() {
        // Show app's main UI
        let mainView = R.storyboard.main.mainView()!
        mainView.viewModel = MainViewModel()
        main = mainView
        parent.present(main, animated: true, completion: nil)
    }
}
