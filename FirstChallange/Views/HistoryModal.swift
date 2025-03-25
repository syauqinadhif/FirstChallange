import SwiftUI
import CoreData

struct HistoryModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var expandedDate: String? = nil
    @ObservedObject var viewModel = TransactionViewModel()

    var groupedTransactions: [String: [FinancialTransaction]] {
        Dictionary(grouping: viewModel.transactions, by: { viewModel.formatDate($0.date ?? Date()) })
    }

    var sortedDates: [String] {
        groupedTransactions.keys.sorted(by: { $0 > $1 })
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header
                HStack {
                    Button("Close") { dismiss() }
                    Spacer()
                    Text("History").bold()
                    Spacer()
                }
                .padding()

                // Section Title "Recents"
                HStack {
                    Text("Recents").font(.title2).bold()
                    Spacer()
                    Button(action: { showDatePicker.toggle() }) {
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
                        .onChange(of: selectedDate) { _, newValue in
                            viewModel.fetchTransactionsForDate(newValue)
                            showDatePicker = false
                        }
                }

                // Transaction List
                List {
                    ForEach(sortedDates, id: \.self) { date in
                        if let transactions = groupedTransactions[date] {
                            TransactionRow(date: date, transactions: transactions, expandedDate: $expandedDate)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            viewModel.fetchLast7DaysTransactions()
        }
    }
}
