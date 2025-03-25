import SwiftUI
import CoreData

struct HomePage: View {
    @State private var showNewTransaction = false
    @State private var showHistory = false
    @State private var transactions: [FinancialTransaction] = []
    //@State private var selectedDate: Date = Date() // Holds the selected date
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: Bulan + Tahun Picker
    
    @State private var selectedIndex = 0
    
    let years = stride(from: 2020, through: 2025, by: 1).map { Int($0) }
    let months = Array(1...12)
    
    // Generate all month-year combinations
    var monthYearOptions: [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let now = Date()
        
        for year in years {
            for month in months {
                if let date = calendar.date(from: DateComponents(year: year, month: month)),
                   date <= now { // ✅ Filter out future months
                    dates.append(date)
                }
            }
        }
        
        return dates
        // return Array(dates.suffix(6))
    }
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
                HStack {
                    // Month Picker
                    Button(formattedSelectedDate) {
                        showPicker.toggle()
                    }
                    .sheet(isPresented: $showPicker) {
                        NavigationStack {
                            HStack {
                                // Month Picker
                                Picker("Month", selection: Binding(
                                    get: {
                                        Calendar.current.component(.month, from: monthYearOptions[selectedIndex])
                                    },
                                    set: { newMonth in
                                        updateSelectedDate(month: newMonth, year: Calendar.current.component(.year, from: monthYearOptions[selectedIndex]))
                                    }
                                )) {
                                    ForEach(months, id: \.self) { month in
                                        Text(DateFormatter().monthSymbols[month - 1]).tag(month)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                                
                                // Year Picker
                                Picker("Year", selection: Binding(
                                    get: {
                                        Calendar.current.component(.year, from: monthYearOptions[selectedIndex])
                                    },
                                    set: { newYear in
                                        updateSelectedDate(
                                            month: Calendar.current.component(.month, from: monthYearOptions[selectedIndex]),
                                            year: newYear
                                        )
                                    }
                                )) {
                                    ForEach(years, id: \.self) { year in
                                        Text(formatYear(year)).tag(year) // ✅ Shows 2025, not 2.025
                                    }
                                }
                                .pickerStyle(.wheel)// You can try .menu or .inline too
                                .frame(maxHeight: 350)
                                .presentationDetents([.fraction(0.4)])
                            }
                            .navigationTitle("Pick Month")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("") {
                                    }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Submit") {
                                        showPicker = false
                                        fetchTransactions()
                                    }
                                }
                            }
                            Spacer()
                            
                        }
                    }
                    
                    
                    //                    Picker("Select Month and Year", selection: $selectedIndex) {
                    //                        ForEach(0..<monthYearOptions.count, id: \.self) { index in
                    //                            Text(formattedDate(monthYearOptions[index])).tag(index)
                    //                        }
                    //                    }
                    //                    .pickerStyle(.menu) // You can try .menu or .inline too
                    //                    .frame(maxHeight: 150)
                    
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
        .onAppear {
            setDefaultToCurrentMonth()
        }
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

struct MonthYearPickerModal: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedDate: Date
    
    let years = Array(2020...2025)
    let months = Array(1...12)
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Month", selection: Binding(
                    get: { Calendar.current.component(.month, from: selectedDate) },
                    set: { month in
                        updateDate(month: month, year: Calendar.current.component(.year, from: selectedDate))
                    }
                )) {
                    ForEach(months, id: \.self) { month in
                        Text(DateFormatter().monthSymbols[month - 1])
                            .tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                
                Picker("Select Year", selection: Binding(
                    get: { Calendar.current.component(.year, from: selectedDate) },
                    set: { year in
                        updateDate(month: Calendar.current.component(.month, from: selectedDate), year: year)
                    }
                )) {
                    ForEach(years, id: \.self) { year in
                        Text("\(year)").tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func updateDate(month: Int, year: Int) {
        if let newDate = Calendar.current.date(from: DateComponents(year: year, month: month)) {
            selectedDate = newDate
        }
    }
}

extension HomePage {
    
    private func formatYear(_ year: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none // 🚫 no decimals, no grouping
        return formatter.string(from: NSNumber(value: year)) ?? "\(year)"
    }
    
    private func updateSelectedDate(month: Int, year: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(from: DateComponents(year: year, month: month)) {
            if let index = monthYearOptions.firstIndex(where: {
                calendar.component(.year, from: $0) == calendar.component(.year, from: newDate) &&
                calendar.component(.month, from: $0) == calendar.component(.month, from: newDate)
            }) {
                selectedIndex = index
            }
        }
    }
    
    private func setDefaultToCurrentMonth() {
        let now = Date()
        let calendar = Calendar.current
        if let index = monthYearOptions.firstIndex(where: {
            calendar.component(.year, from: $0) == calendar.component(.year, from: now) &&
            calendar.component(.month, from: $0) == calendar.component(.month, from: now)
        }) {
            selectedIndex = index
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private var formattedSelectedDate: String {
        formattedDate(monthYearOptions[selectedIndex])
    }
}

#Preview {
    HomePage()
        .preferredColorScheme(.dark)
}
