import SwiftUI

struct TransactionRow: View {
    let transaction: TransactionItem
    @Binding var expandedDate: String?

    var body: some View {
        VStack {
            Button(action: {
                expandedDate = expandedDate == transaction.date ? nil : transaction.date
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(transaction.date).font(.headline)
                        Text(transaction.amount).font(.subheadline).foregroundColor(transaction.color)
                    }
                    Spacer()
                    Image(systemName: expandedDate == transaction.date ? "chevron.down" : "chevron.right")
                }
                .padding(.vertical, 5)
            }
            .buttonStyle(PlainButtonStyle())

            if expandedDate == transaction.date {
                VStack {
                    ForEach(transaction.details) { detail in
                        TransactionDetailRow(detail: detail)
                    }
                }
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
            }
        }
    }
}
