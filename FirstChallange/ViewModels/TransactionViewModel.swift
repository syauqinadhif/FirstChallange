import SwiftUI
import CoreData

class TransactionViewModel: ObservableObject {
    @Published var transactions: [TransactionItem] = []
    private let persistenceController = PersistenceController.shared

    init() {
        fetchLast7DaysTransactions()
    }

    func fetchLast7DaysTransactions() {
        let transactionsForLast7Days = persistenceController.getTransactionsForLast7Days()
        var tempTransactions: [TransactionItem] = []
        
        let sortedDates = transactionsForLast7Days.keys.sorted(by: { $0 > $1 })
        
        for date in sortedDates {
            if let transactions = transactionsForLast7Days[date] {
                let formattedDate = formatDate(date)
                let income = transactions.filter { $0.category == "Income" }.reduce(0) { $0 + $1.amount }
                let expense = transactions.filter { $0.category != "Income" }.reduce(0) { $0 + $1.amount }

                let totalAmount = income > 0 ? (income - expense) : expense
                let color: Color = (income > 0 && totalAmount >= 0) ? .green : .red

                var combinedDetails: [String: TransactionDetail] = [:]
                for transaction in transactions {
                    let category = transaction.category ?? "Unknown"
                    let newAmount = (Int(combinedDetails[category]?.amount.replacingOccurrences(of: "Rp ", with: "") ?? "0") ?? 0) + Int(transaction.amount)
                    
                    combinedDetails[category] = TransactionDetail(
                        icon: "creditcard",
                        category: category,
                        amount: "Rp \(newAmount)"
                    )
                }

                tempTransactions.append(
                    TransactionItem(
                        date: formattedDate,
                        amount: "Rp \(abs(totalAmount))",
                        color: color,
                        details: Array(combinedDetails.values)
                    )
                )
            }
        }
        transactions = tempTransactions
    }

    func fetchTransactionsForDate(_ date: Date) {
        let transactionsForDay = persistenceController.getTransactionsForDay(date: date)
        let formattedDate = formatDate(date)
        let income = transactionsForDay.filter { $0.category == "Income" }.reduce(0) { $0 + $1.amount }
        let expense = transactionsForDay.filter { $0.category != "Income" }.reduce(0) { $0 + $1.amount }

        let netAmount = income - expense
        let color: Color = (income > 0 && netAmount >= 0) ? .green : .red

        var combinedDetails: [String: TransactionDetail] = [:]
        for transaction in transactionsForDay {
            let category = transaction.category ?? "Unknown"
            let newAmount = (Int(combinedDetails[category]?.amount.replacingOccurrences(of: "Rp ", with: "") ?? "0") ?? 0) + Int(transaction.amount)
            
            combinedDetails[category] = TransactionDetail(
                icon: "creditcard",
                category: category,
                amount: "Rp \(newAmount)"
            )
        }

        transactions = [
            TransactionItem(
                date: formattedDate,
                amount: "Rp \(netAmount)",
                color: color,
                details: Array(combinedDetails.values)
            )
        ]
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
