import SwiftUI

struct TransactionDetailRow: View {
    let category: String
    let amount: Int
    let isExpense: Bool

    var body: some View {
        VStack {
            HStack {
                Image(systemName: getCategoryIcon(category))
                    .foregroundColor(getCategoryColor(category))
                    .font(.system(size: 20))
                Text(category)
                    .font(.system(size: 18))
                Spacer()
                Text("Rp \(amount)")
                    .foregroundColor(isExpense ? .red : .green)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.vertical, 8)
            Divider()
        }
        .padding(.horizontal, 16)
    }
}
