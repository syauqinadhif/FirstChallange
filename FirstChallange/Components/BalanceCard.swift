import SwiftUI

struct BalanceCard: View {
    var title: String
    var amount: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "plusminus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.pBlue)
                    Spacer()
                    Text("Rp \(amount, specifier: "%.2f")")
                        .font(.largeTitle)
                        .bold()
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
