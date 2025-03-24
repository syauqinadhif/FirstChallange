import SwiftUI

struct ExpenseCard: View {
    var amount: Double
    
    var body: some View {
        VStack {
            Text("Rp \(amount, specifier: "%.2f")")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .trailing)
                
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.pRed)
                Spacer()
                Text("Expense")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.greyText)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
        .padding(.trailing, 15)
    }
}
