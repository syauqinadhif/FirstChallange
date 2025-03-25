import SwiftUI

struct TransactionRow: View {
    let date: String
    let transactions: [FinancialTransaction]
    @Binding var expandedDate: String?

    var body: some View {
        let grouped = groupedTransactions() // Ambil transaksi yang sudah dikelompokkan

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
                VStack {
                    ForEach(grouped, id: \.key) { category, totalAmount, isExpense in
                        TransactionDetailRow(category: category, amount: totalAmount, isExpense: isExpense)
                    }
                }
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
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

    /// **Mengelompokkan transaksi berdasarkan kategori agar tidak ada duplikasi.**
    func groupedTransactions() -> [(key: String, totalAmount: Int, isExpense: Bool)] {
        let grouped = Dictionary(grouping: transactions, by: { $0.category ?? "Others" })
        return grouped.map { key, transactions in
            let totalAmount = transactions.reduce(0) { $0 + Int($1.amount) }
            let isExpense = transactions.first?.isExpense ?? false
            return (key, totalAmount, isExpense)
        }.sorted { $0.isExpense && !$1.isExpense } // Urutkan: Expense dulu, lalu Income
    }
}
