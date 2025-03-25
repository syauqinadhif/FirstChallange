import SwiftUI

struct SpendingRow: View {
    var category: String
    var amount: Int64
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
