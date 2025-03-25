//
//  BalanceCard.swift
//  FirstChallange
//
//  Created by Syauqi Ikhlasun Nadhif on 25/03/25.
//


import SwiftUI

struct BalanceCard: View {
    var title: String
    var amount: Int64
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "plusminus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.pBlue)
                    Spacer()
                    Text("Rp \(amount.formatted())")
                        .font(.largeTitle)
                        .bold()
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .contextMenu { Text("Rp \(amount.formatted())").font(.body)
                        }
                }
                Text(title)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.greyText)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 15)
    }
}
