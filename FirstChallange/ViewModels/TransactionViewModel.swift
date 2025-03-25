import SwiftUI
import CoreData

class TransactionViewModel: ObservableObject {
    @Published var transactions: [FinancialTransaction] = []
    private let persistenceController = PersistenceController.shared

    init() {
        fetchLast7DaysTransactions()
    }

    func fetchLast7DaysTransactions() {
        let transactionsForLast7Days = persistenceController.getTransactionsForLast7Days()
        let sortedTransactions = transactionsForLast7Days.values.flatMap { $0 }
            .sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) })
        
        transactions = sortedTransactions
    }

    func fetchTransactionsForDate(_ date: Date) {
        transactions = persistenceController.getTransactionsForDay(date: date)
    }

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
