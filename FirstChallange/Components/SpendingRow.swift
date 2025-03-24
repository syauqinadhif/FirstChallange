import SwiftUI

struct SpendingRow: View {
    var category: String
    var amount: Double
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(getCategoryColor(category))

            Text(category)
                .font(.title3)
                .bold()
                .padding(.horizontal, 5)
                .foregroundStyle(Color.greyText)
            Spacer()
            Text("Rp \(amount.formatted())")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Color.white)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 15)
    }
}

// Fungsi bantu untuk ikon kategori
func getCategoryIcon(_ category: String) -> String {
    let icons = [
        "Foods": "fork.knife.circle.fill",
        "Transports": "car.circle.fill",
        "Bills": "creditcard.circle.fill",
        "Shops": "cart.circle.fill",
        "Others": "list.bullet.circle.fill"
    ]
    return icons[category] ?? "list.bullet.circle.fill"
}

// Fungsi bantu untuk warna kategori
func getCategoryColor(_ category: String) -> Color {
    let colors: [String: Color] = [
        "Foods": .pOrange,
        "Transports": .pLBlue,
        "Bills": .pPurple,
        "Shops": .pYellow,
        "Others": .white
    ]
    return colors[category] ?? .white
}
