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
                        .contextMenu { Text("Rp \(amount.formatted())").font(.body) }
                }
                Text(title)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.greyText)
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 2) // Outline tanpa background
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 15)
    }
}
