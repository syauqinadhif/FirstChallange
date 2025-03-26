import SwiftUI
import CoreData

struct HistoryModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var expandedDate: String? = nil
    @State private var hasSelectedDate: Bool = false  // Menandai apakah user sudah memilih tanggal
    @ObservedObject var viewModel = TransactionViewModel()

    var groupedTransactions: [String: [FinancialTransaction]] {
        Dictionary(grouping: viewModel.transactions, by: { viewModel.formatDate($0.date ?? Date()) })
    }

    var sortedDates: [String] {
        groupedTransactions.keys.sorted(by: { $0 > $1 })
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Section Title: Recents / Details
                HStack {
                    Text(hasSelectedDate ? "Details" : "Recents") // Perubahan di sini
                        .font(.title2).bold()
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
                    DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .onChange(of: selectedDate) {
                            viewModel.fetchTransactionsForDate(selectedDate)
                            hasSelectedDate = true  // User telah memilih tanggal
//                            showDatePicker = false
                        }
                }

                // Transaction List atau "No Transaction Recorded"
                if sortedDates.isEmpty {
                    Text("No Transaction Recorded")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
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
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.fetchLast7DaysTransactions()
        }
    }
}
