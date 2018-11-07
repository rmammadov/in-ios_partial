//
//  NetworkQueue.swift
//  in-ios
//
//  Created by Piotr Soboń on 06/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class NetworkQueue {
    static let shared: NetworkQueue = NetworkQueue()
    
    let queue = OperationQueue()
    
    private init() {
        queue.maxConcurrentOperationCount = 1
    }
    
    func addOperation(_ operation: Operation) {
        queue.addOperation(operation)
    }
}
