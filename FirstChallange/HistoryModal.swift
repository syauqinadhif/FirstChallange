import SwiftUI
import CoreData

// MARK: - Transaction Models
class TransactionDetail: Identifiable, Equatable, Hashable {
    let id = UUID()
    let icon: String
    let category: String
    let amount: String

    init(icon: String, category: String, amount: String) {
        self.icon = icon
        self.category = category
        self.amount = amount
    }

    static func == (lhs: TransactionDetail, rhs: TransactionDetail) -> Bool {
        return lhs.category == rhs.category
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
}

class TransactionItem: Identifiable {
    let id = UUID()
    let date: String
    let amount: String
    let color: Color
    var details: [TransactionDetail]

    init(date: String, amount: String, color: Color, details: [TransactionDetail] = []) {
        self.date = date
        self.amount = amount
        self.color = color
        self.details = details
    }
}

// MARK: - ViewModel
class TransactionViewModel: ObservableObject {
    @Published var transactions: [TransactionItem] = []
    private let persistenceController = PersistenceController.shared

    init() {
        fetchLast7DaysTransactions() //masih 7day??
    }

    func fetchLast7DaysTransactions() {
        let transactionsForLast7Days = persistenceController.getTransactionsForLast7Days()
        var tempTransactions: [TransactionItem] = []

        // Sort dates from newest to oldest
        let sortedDates = transactionsForLast7Days.keys.sorted(by: { $0 > $1 })

        for date in sortedDates {
            if let transactions = transactionsForLast7Days[date] {
                let formattedDate = formatDate(date)
                let income = transactions.filter { $0.category == "Income" }.reduce(0) { $0 + $1.amount }
                let expense = transactions.filter { $0.category != "Income" }.reduce(0) { $0 + $1.amount }

                let totalAmount = income > 0 ? (income - expense) : expense
                let color: Color = (income > 0 && totalAmount >= 0) ? .green : .red

                // Combine transactions with the same category
                var combinedDetails: [String: TransactionDetail] = [:]
                for transaction in transactions {
                    if let existingDetail = combinedDetails[transaction.category ?? "Unknown"] {
                        // Extract numeric value from existingDetail.amount (e.g., "Rp 1000" -> 1000)
                        let existingAmountString = existingDetail.amount.replacingOccurrences(of: "Rp ", with: "")
                        let existingAmount = Int(existingAmountString) ?? 0
                        
                        // Add the existing amount to the new transaction amount
                        let newAmount = existingAmount + Int(transaction.amount)
                        
                        // Update the combinedDetails dictionary with the new amount
                        combinedDetails[transaction.category ?? "Unknown"] = TransactionDetail(
                            icon: existingDetail.icon,
                            category: existingDetail.category,
                            amount: "Rp \(newAmount)"
                        )
                    } else {
                        // If the category doesn't exist in combinedDetails, add it
                        combinedDetails[transaction.category ?? "Unknown"] = TransactionDetail(
                            icon: "creditcard",
                            category: transaction.category ?? "Unknown",
                            amount: "Rp \(Int(transaction.amount))"
                        )
                    }
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

        // Gabungkan transaksi dengan kategori yang sama
        var combinedDetails: [String: TransactionDetail] = [:]
        for transaction in transactionsForDay {
            if let existingDetail = combinedDetails[transaction.category ?? "Unknown"] {
                // Extract numeric value from existingDetail.amount (e.g., "Rp 1000" -> 1000)
                let existingAmountString = existingDetail.amount.replacingOccurrences(of: "Rp ", with: "")
                let existingAmount = Int(existingAmountString) ?? 0
                
                // Add the existing amount to the new transaction amount
                let newAmount = existingAmount + Int(transaction.amount)
                
                // Update the combinedDetails dictionary with the new amount
                combinedDetails[transaction.category ?? "Unknown"] = TransactionDetail(
                    icon: existingDetail.icon,
                    category: existingDetail.category,
                    amount: "Rp \(newAmount)"
                )
            } else {
                // If the category doesn't exist in combinedDetails, add it
                combinedDetails[transaction.category ?? "Unknown"] = TransactionDetail(
                    icon: "creditcard",
                    category: transaction.category ?? "Unknown",
                    amount: "Rp \(Int(transaction.amount))"
                )
            }
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

// MARK: - History Modal View
struct HistoryModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var expandedDate: String? = nil
    @ObservedObject var viewModel = TransactionViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header
                HStack {
                    Button("Close") { dismiss() }
                    Spacer()
                    Text("History").bold()
                    Spacer()
//                    Button("Done") {}
                }
                .padding()

                // Section Title "Recents"
                HStack {
                    Text("Recents").font(.title2).bold()
                    Spacer()
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)

                // Date Picker
                if showDatePicker {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .onChange(of: selectedDate) { oldValue, newValue in
                            viewModel.fetchTransactionsForDate(newValue)
                            showDatePicker = false
                        }
                }

                // Transaction List
                List {
                    ForEach(viewModel.transactions) { transaction in
                        TransactionRow(transaction: transaction, expandedDate: $expandedDate)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: - Transaction Row View
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

// MARK: - Transaction Detail Row View
struct TransactionDetailRow: View {
    let detail: TransactionDetail

    var body: some View {
        VStack {
            HStack {
                Image(systemName: detail.icon).foregroundColor(getIconColor(for: detail.category)).font(.system(size: 20))
                Text(detail.category).font(.system(size: 18))
                Spacer()
                Text(detail.amount)
                    .foregroundColor(detail.category == "Income" ? .green : .red)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.vertical, 8)
            Divider()
        }
        .padding(.horizontal, 16)
    }

    func getIconColor(for category: String) -> Color {
        switch category {
        case "Food": return .blue
        case "Transport": return .yellow
        case "Bill": return .orange
        case "Shopping": return .purple
        default: return .primary
        }
    }
}

//#Preview {
//    HistoryModal()
//        .preferredColorScheme(.dark)
//}
