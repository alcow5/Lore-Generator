//
//  Persistence.swift
//  Lore Generator
//
//  Created by Alex on 6/26/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample lore objects for preview
        let sampleLoreTexts = [
            "This ancient chalice was once used by the High Priestess of Moonwater to perform sacred rituals under the full moon.",
            "A mystical timepiece that belonged to a traveling merchant from the realm of Shadowlands.",
            "Legend speaks of this enchanted crystal that holds the power to reveal hidden truths."
        ]
        
        let sampleNames = ["Sacred Chalice", "Merchant's Timepiece", "Crystal of Truth"]
        
        for i in 0..<3 {
            let newLoreObject = LoreObject(context: viewContext)
            newLoreObject.id = UUID()
            newLoreObject.objectName = sampleNames[i]
            newLoreObject.loreText = sampleLoreTexts[i]
            newLoreObject.timestamp = Date().addingTimeInterval(-Double(i * 3600)) // Space them out by hours
            // Note: imageData is left nil for preview since we don't have sample images
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Lore_Generator")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
