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
    case noInternetConnection = 0
    case loading = 1
    case failed = 2
    case completed = 3
}

class LoadingViewModel: BaseViewModel {

    var status = Variable<Int>(0)
    let disposeBag = DisposeBag()
    
    // TODO: Update this method
    
    override init() {
        ReachabilityManager.shared.startMonitoring()
    }
    
    func setSubscribers() {
        DataManager.status.asObservable().subscribe(onNext: {
            event in
            if DataManager.status.value == DataStatus.dataLoadingCompleted.rawValue {
                self.status.value = LoadingStatus.completed.rawValue
            } else if DataManager.status.value == DataStatus.dataLoadingFailed.rawValue {
                self.status.value = LoadingStatus.failed.rawValue
            }
        }).disposed(by: disposeBag)
    }
    
    func requestData() {
        if ReachabilityManager.shared.isNetworkAvailable {
            self.status.value = LoadingStatus.loading.rawValue
            DataManager.setSubscribers()
            DataManager.loadRequiredData()
        } else {
            self.status.value = LoadingStatus.noInternetConnection.rawValue
        }
    }
}
