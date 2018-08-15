//
//  LoadingViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/14/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

enum LoadingStatus: Int {
    case failed = 0
    case completed = 1
}

class LoadingViewModel: BaseViewModel {

    var status = Variable<Int>(0)
    
    // TODO: Update this method
    
    func setSubscribers() {
        DataManager.status.asObservable().subscribe(onNext: {
            event in
            if DataManager.status.value == DataStatus.dataLoadingCompleted.rawValue {
                self.status.value = LoadingStatus.completed.rawValue
            }
        })
    }
    
    func requestData() {
        DataManager.setSubscribers()
        DataManager.loadRequiredData()
    }
}
