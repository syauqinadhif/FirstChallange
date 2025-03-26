import SwiftUI

struct TransactionDetailRow: View {
    let category: String
    let amount: Int
    let isExpense: Bool
    let notes: String

    var body: some View {
        VStack {
            HStack {
                Image(systemName: getCategoryIcon(category))
                    .foregroundColor(getCategoryColor(category))
                    .font(.system(size: 20))
//                Text(category)
//                    .font(.system(size: 18))
                VStack(alignment: .leading) {
                    Text(notes)
                        .font(.system(size: 18))
//                    Text(category)
//                        .font(.subheadline)
                }
                Spacer()
                Text("Rp \(amount)")
                    .foregroundColor(isExpense ? .red : .green)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.vertical, 8)
        }
    }
}
