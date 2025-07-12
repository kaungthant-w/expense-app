//
//  hsu_expenseApp.swift
//  HSU expense
//
//  Created by kmt on 7/9/25.
//

import SwiftUI

@main
struct hsu_expenseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
