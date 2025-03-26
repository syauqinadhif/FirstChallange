//
//  IncomeCard.swift
//  FirstChallange
//
//  Created by Syauqi Ikhlasun Nadhif on 25/03/25.
//


import SwiftUI

struct IncomeCard: View {
    var amount: Int64
    
    var body: some View {
        VStack {
            Text("Rp \(amount.formatted())")
                .font(.title3)
                .bold()
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contextMenu {Text("Rp \(amount.formatted())").font(.body)
                }
                
            HStack {
                Image(systemName: "arrow.down.circle.fill")
//                Image(systemName: "arrow.down.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.pGreen)
                Spacer()
                Text("Income")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.greyText)
            }
        }
        .padding()
//        .background(Color.gray.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 2) // Outline tanpa background
        )
//        .cornerRadius(10)
        .frame(maxWidth: .infinity)
        .padding(.leading, 15)
    }
}
