import SwiftUI

struct IncomeCard: View {
    var amount: Double
    
    var body: some View {
        VStack {
            Text("Rp \(amount, specifier: "%.2f")")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .trailing)
                
            HStack {
                Image(systemName: "arrow.down.circle.fill")
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
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
        .padding(.leading, 15)
    }
}
