

import SwiftUI

struct TransactionRow: View {
    let date: String
    @State var transactions: [FinancialTransaction]
    @Binding var expandedDate: String?

    var body: some View {
        VStack {
            Button(action: {
                expandedDate = expandedDate == date ? nil : date
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(date).font(.headline)
                        Text("Rp \(calculateTotalAmount())")
                            .font(.subheadline)
                            .foregroundColor(getTotalColor())
                    }
                    Spacer()
                    Image(systemName: expandedDate == date ? "chevron.down" : "chevron.right")
                }
                .padding(.vertical, 5)
            }
            .buttonStyle(PlainButtonStyle())

            if expandedDate == date {
                List {
                    ForEach(transactions, id: \.id) { transaction in
                        TransactionDetailRow(
                            category: transaction.category ?? "Others",
                            amount: Int(transaction.amount),
                            isExpense: transaction.isExpense
                        )
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            if let transactionID = transactions[index].id {
                                PersistenceController.shared.deleteTransaction(id: transactionID)
                            }
                        }
                        transactions.remove(atOffsets: offsets)
                    }
                }
//                List {
//                    ForEach(transactions, id: \.id) { transaction in
//                        TransactionDetailRow(
//                            category: transaction.category ?? "Others",
//                            amount: Int(transaction.amount),
//                            isExpense: transaction.isExpense
//                        )
//                        .swipeActions {
//                            Button(role: .destructive) {
//                                if let transactionID = transaction.id {
//                                    PersistenceController.shared.deleteTransaction(id: transactionID)
//                                }
//                                transactions.removeAll { $0.id == transaction.id }
//                            } label: {
//                                Label("Delete", systemImage: "trash")
//                            }
//
//                            Button {
////                                showTransactionInfo(transaction)
//                            } label: {
//                                Label("Info", systemImage: "info.circle")
//                            }
//                            .tint(.gray) // Warna tombol Info
//                        }
//                    }
//                }
                .listStyle(PlainListStyle())
                .frame(height: CGFloat(transactions.count) * 60)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
        }
    }

    func calculateTotalAmount() -> Int {
        let totalIncome = transactions.filter { !$0.isExpense }.reduce(0) { $0 + Int($1.amount) }
        let totalExpenses = transactions.filter { $0.isExpense }.reduce(0) { $0 + Int($1.amount) }
        return totalIncome - totalExpenses
    }

    func getTotalColor() -> Color {
        return calculateTotalAmount() >= 0 ? .green : .red
    }
}

