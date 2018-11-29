//
//  DatabaseWorker.swift
//  in-ios
//
//  Created by Piotr Soboń on 27/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import CoreData

class DatabaseWorker: NSObject {
    static let shared = DatabaseWorker()
    private var deviceId: String {
        return FileNamingHelper().getDeviiceUUID()
    }
    
    private override init() {
    }
    
    func addUsage(locale: String, label: String, itemType: String, itemId: Int, tileContext: String) {
        let context = PersistanceService.shared.backgroundManagedObjectContext
        var tileUsageMO: TileUsageEntity
        if let fetchedMO = fetchTileUsageEntity(itemId: itemId, itemType: itemType, label: label,
                                                locale: locale, tileContext: tileContext,
                                                onContext: context) {
            tileUsageMO = fetchedMO
        } else {
            tileUsageMO = NSEntityDescription.insertNewObject(forEntityName: TileUsageEntity.identifier, into: context) as! TileUsageEntity
            tileUsageMO.context = tileContext
            tileUsageMO.item_id = Int64(itemId)
            tileUsageMO.locale = locale
            tileUsageMO.device_id = FileNamingHelper().getDeviiceUUID()
            tileUsageMO.item_type = itemType
            tileUsageMO.total = 0
            tileUsageMO.label = label
        }
        context.performAndWait {
            tileUsageMO.total += 1
            do {
                try context.save()
            } catch let error {
                print("ERROR: cannot save context with new usage!")
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchTileUsageEntity(itemId: Int, itemType type: String, label: String,
                                      locale: String, tileContext: String,
                                      onContext context: NSManagedObjectContext) -> TileUsageEntity? {
        let request = NSFetchRequest<TileUsageEntity>(entityName: TileUsageEntity.identifier)
        let predicate = NSPredicate(format: "item_id == %d AND item_type == %@ AND locale == %@ AND context == %@ AND label == %@", Int64(itemId), type, locale, tileContext, label)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let tileUsageMO = try context.fetch(request).first
            return tileUsageMO
        } catch let error {
            print("ERROR: fetchTileUsageEntity: \(error.localizedDescription)")
        }
        return nil
    }
    
    func fetchAllTileUsage() -> [[String: Any]]? {
        let context = PersistanceService.shared.backgroundManagedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TileUsageEntity.identifier)
        request.resultType = .dictionaryResultType
        do {
            guard let results = try context.fetch(request) as? [[String: Any]] else {
                return nil
            }
            return results
        } catch let error {
            print("ERROR: cannot fetch TileUsage: \(error.localizedDescription)")
        }
        return nil
    }
    
    func removeTileUsage(itemId: Int, itemType: String, locale: String, tileContext: String) {
        let context = PersistanceService.shared.backgroundManagedObjectContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TileUsageEntity.identifier)
        let predicate = NSPredicate(format: "item_id == %d AND item_type == %@ AND locale == %@ AND context == %@",
                                    Int64(itemId), itemType, locale, tileContext)
        fetch.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let result = try context.execute(request) as? NSBatchDeleteResult
            if let removedIds = result?.result as? [NSManagedObjectID] {
                print("Successfully removed: \(removedIds.debugDescription)")
            }
        } catch let error {
            print("Cannot remove TileUsage: \(error.localizedDescription)")
        }
    }
}
