import SwiftUI
import CoreData

struct HomePage: View {
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var showNewTransaction = false
    @State private var showHistory = false
    @State private var transactions: [FinancialTransaction] = []
    //@State private var selectedDate: Date = Date() // Holds the selected date
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: Bulan + Tahun Picker
    
    @State private var selectedIndex = 0
    
    // Generate all month-year combinations
    
    // MARK: ____
    @State private var showPicker = false
    
    // MARK: ____
    
    private let staticCategories = ["Foods", "Transports", "Bills", "Shops", "Others"]
    
    private var totalBalance: Int64 {
        transactions.reduce(0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) }
    }
    
    private var totalIncome: Int64 {
        transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Int64 {
        transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private func fetchTransactions() {
        transactions = PersistenceController.shared.getTransactionsForCurrentMonth()
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 15){
                HStack(spacing: 15) {
                    Button(action: { showDatePicker.toggle() }) {
                        Text(FormattedDate.getCurrentMonthYear(selectedDate))
                            .font(.title3).bold()
                            .foregroundStyle(Color.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        PersistenceController.shared.clearAllData()
                        transactions.removeAll()
                    }) {
                        Image(systemName: "arrow.circlepath")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    Button(action: { showHistory.toggle() }) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    Button(action: { showNewTransaction.toggle() }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 15)
                .sheet(isPresented: $showDatePicker) {
                    NavigationStack {
                        VStack {
                            YearMonthDatePicker(selectedDate: $selectedDate)
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Select Month & Year")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showDatePicker = false
                                }
                            }
                        }
                    }
                    .presentationDetents([.fraction(0.4)])
                }
                
                BalanceCard(title: "Balance", amount: totalBalance)
                
                HStack(spacing: 15) {
                    IncomeCard(amount: totalIncome)
                    ExpenseCard(amount: totalExpense)
                }
            }
            Text("Total Spending")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
            
            VStack(spacing: 20) {
                ForEach(staticCategories, id: \.self) { category in
                    SpendingRow(
                        category: category,
                        amount: transactions.filter { $0.category == category }.reduce(0) { $0 + $1.amount },
                        icon: getCategoryIcon(category)
                    )
                }
            }
            
            if showNewTransaction {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
        .blur(radius: showNewTransaction || showPicker ? 4 : 0)
        .blur(radius: showNewTransaction ? 3 : 0)
        .onAppear {
            fetchTransactions()
        }
        
        .sheet(isPresented: $showNewTransaction) {
            NewTransactionModal()
                .environment(\.managedObjectContext, viewContext)
                .onDisappear {
                    fetchTransactions()
                }
        }
        .sheet(isPresented: $showHistory) {
            HistoryModal()
                .environment(\.managedObjectContext, viewContext)
        }
        Spacer()
    }
}

#Preview {
    HomePage()
        .preferredColorScheme(.dark)
}
