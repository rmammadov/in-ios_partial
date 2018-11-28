//
//  SyncTileUsageUtil.swift
//  in-ios
//
//  Created by Piotr Soboń on 28/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class SyncTileUsageUtil {
    static let shared = SyncTileUsageUtil()
    
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    private let operationQueue = OperationQueue()
    
    private init() {
        operationQueue.maxConcurrentOperationCount = 4
    }
    
    public func checkAndStartSyncIfNeeded() {
        let now = Date()
        // If synchronization was not started, or date is wrong, set lastSyncDate to now and abort synchronization.
        guard let lastSyncDate = SettingsHelper.shared.lastSyncDate,
            lastSyncDate.compare(now) == .orderedAscending else {
            SettingsHelper.shared.lastSyncDate = now
            return
        }
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        
        // If lastSyncDate was not earlier then weekAgo then abort
        guard weekAgo.compare(lastSyncDate) == .orderedDescending
            else { return }
        startSynchronization()
    }
    
    private func startSynchronization() {
        guard let tileUsages = DatabaseWorker.shared.fetchAllTileUsage(), !tileUsages.isEmpty else {
            SettingsHelper.shared.lastSyncDate = Date()
            return
        }
        let operation = BlockOperation(block: {
            SettingsHelper.shared.lastSyncDate = Date()
        })
        tileUsages.forEach {
            let postUsagePperation = PostUsageOperation(usage: $0, session: session)
            operation.addDependency(postUsagePperation)
            operationQueue.addOperation(postUsagePperation)
        }
        operationQueue.addOperation(operation)
    }
}

private class PostUsageOperation: ConcurrentOperation {
    private let usage: [String: Any]
    private let session: URLSession
    init(usage: [String: Any], session: URLSession) {
        self.usage = usage
        self.session = session
    }
    override func main() {
        let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_USAGE)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        guard let param = TileUsageParam(dict: usage) else {
            print("Cannot create param from dict: \(usage)")
            completeOperation()
            return
        }
        guard let jsonData = try? JSONEncoder().encode(param) else {
            print("Cannot create jsonData from param: \(param)")
            completeOperation()
            return
        }
        urlRequest.httpBody = jsonData
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error: PostUsageOperation error: \(error.localizedDescription)")
                self.completeOperation()
                return
            }
            guard let content = data else {
                print("Error: PostUsageOperation error: content is nil")
                self.completeOperation()
                return
            }
            guard let usage = try? JSONDecoder().decode(TileUsageParam.self, from: content) else {
                print("ERROR: JSONSerialization error")
                self.completeOperation()
                return
            }
            DatabaseWorker.shared.removeTileUsage(itemId: usage.item_id, itemType: usage.item_type,
                                                  locale: usage.locale, tileContext: usage.context)
            self.completeOperation()
        }
        task.resume()
    }
    
    private struct TileUsageParam: Codable {
        let device_id: String
        let total: Int
        let locale: String
        let item_id: Int
        let item_type: String
        let context: String
        
        init?(dict: [String: Any]) {
            guard let deviceId = dict["device_id"] as? String,
                let total = dict["total"] as? Int,
                let locale = dict["locale"] as? String,
                let itemId = dict["item_id"] as? Int,
                let itemType = dict["item_type"] as? String,
                let context = dict["context"] as? String else {
                    return nil
            }
            self.device_id = deviceId
            self.total = total
            self.locale = locale
            self.item_id = itemId
            self.item_type = itemType
            self.context = context.isEmpty ? "-" : context
        }
    }
}

private class BlockOperation: ConcurrentOperation {
    private var block: () -> Void
    init(block: @escaping () -> Void) {
        self.block = block
    }
    
    override func main() {
        block()
        self.completeOperation()
    }
}
