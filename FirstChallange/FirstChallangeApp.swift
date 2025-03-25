//
//  FirstChallangeApp.swift
//  FirstChallange
//
//  Created by Syauqi Ikhlasun Nadhif on 10/03/25.
//

import SwiftUI

@main
struct FirstChallangeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomePage()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .preferredColorScheme(.dark)
        }
    }
}
