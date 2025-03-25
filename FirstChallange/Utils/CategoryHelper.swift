//
//  CategoryHelper.swift
//  FirstChallange
//
//  Created by Syauqi Ikhlasun Nadhif on 25/03/25.
//

import SwiftUI

func getCategoryIcon(_ category: String) -> String {
    let icons = [
        "Foods": "fork.knife.circle.fill",
        "Transports": "car.circle.fill",
        "Bills": "creditcard.circle.fill",
        "Shops": "cart.circle.fill",
        "Others": "list.bullet.circle.fill",
        "Income": "arrow.down.circle.fill"
    ]
    return icons[category] ?? "list.bullet.circle.fill"
}

func getCategoryColor(_ category: String) -> Color {
    let colors: [String: Color] = [
        "Foods": .pOrange,
        "Transports": .pLBlue,
        "Bills": .pPurple,
        "Shops": .pYellow,
        "Others": .white,
        "Income": .pGreen,
    ]
    return colors[category] ?? .white
}
