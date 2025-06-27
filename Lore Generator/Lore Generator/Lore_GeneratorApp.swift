//
//  Lore_GeneratorApp.swift
//  Lore Generator
//
//  Created by Alex  on 6/26/25.
//

import SwiftUI

@main
struct Lore_GeneratorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
