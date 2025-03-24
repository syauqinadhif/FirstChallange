import SwiftUI
import CoreData

struct HomePage: View {
    @State private var showNewTransaction = false
    @State private var showHistory = false
    @State private var transactions: [FinancialTransaction] = []
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private let staticCategories = ["Foods", "Transports", "Bills", "Shops", "Other"]
    
    private var totalBalance: Double {
        transactions.reduce(0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) }
    }
    
    private var totalIncome: Double {
        transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    // Menghitung total pengeluaran berdasarkan kategori
    private var categoryExpenses: [String: Double] {
        var categoryTotals: [String: Double] = [:]
        for category in staticCategories {
            categoryTotals[category] = 0 // Pastikan semua kategori tetap ada
        }
        
        for transaction in transactions where transaction.isExpense {
            let category = transaction.category ?? "Other"
            categoryTotals[category, default: 0] += transaction.amount
        }
        
        return categoryTotals
    }
    
    private func fetchTransactions() {
        transactions = PersistenceController.shared.getTransactionsForCurrentMonth()
    }
    
    var body: some View {
        VStack{
            HStack{
                Text(FormattedDate.getCurrentMonthYear())
                    .font(.title3)
                    .bold()
                Spacer()
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
            
            HStack{
                IncomeCard(amount: totalIncome)
                ExpenseCard(amount: totalExpense)
            }
            
            Text("Total Spending")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                
            
            VStack(spacing: 20){
                ForEach(staticCategories, id: \.self) { category in
                    SpendingRow(
                        category: category,
                        amount: categoryExpenses[category] ?? 0,
                        icon: getCategoryIcon(category))
                }
            }
            .blur(radius: showNewTransaction ? 3 : 0) // Blur saat modal muncul
            
            // Overlay saat modal tampil
            if showNewTransaction {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
        
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

//how to short content in text
struct BalanceCard: View {
    var title: String
    var amount: Double
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "plusminus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.pBlue)
                    Spacer()
                    Text("Rp \(amount, specifier: "%.2f")")
                        .font(.largeTitle)
                        .bold()
                }
                Text(title)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.greyText)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 15)
    }
}

struct IncomeCard: View {
    var amount: Double
    
    var body: some View {
        VStack{
            Text("Rp \(amount, specifier: "%.2f")")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .trailing)
                
            HStack{
                Image(systemName: "arrow.down.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.pGreen)
                Spacer()
                Text("Income")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.greyText)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
        .padding(.leading, 15)
    }
}

struct ExpenseCard: View {
    var amount: Double
    
    var body: some View {
        VStack{
            Text("Rp \(amount, specifier: "%.2f")")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .trailing)
                
            HStack{
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.pRed)
                Spacer()
                Text("Expense")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.greyText)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
        .padding(.trailing, 15)
    }
}

struct SpendingRow: View {
    var category: String
    var amount: Double
    var icon: String
    
    var body: some View {
        HStack{
            Image(systemName: icon)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(getCategoryColor(category))

            Text(category)
                .font(.title3)
                .bold()
                .padding(.horizontal, 5)
                .foregroundStyle(Color.greyText)
            Spacer()
            Text("Rp \(amount.formatted())")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Color.white)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 15)
    }
}

struct FormattedDate {
    static func getCurrentMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
}

func getCategoryIcon(_ category: String) -> String {
    let icons = [
        "Foods": "fork.knife.circle.fill",
        "Transports": "car.circle.fill",
        "Bills": "creditcard.circle.fill",
        "Shops": "cart.circle.fill",
        "Others": "list.bullet.circle.fill"
    ]
    return icons[category] ?? "list.bullet.circle.fill"
}

func getCategoryColor(_ category: String) -> Color {
    let colors: [String: Color] = [
        "Foods": .pOrange,
        "Transports": .pLBlue,
        "Bills": .pPurple,
        "Shops": .pYellow,
        "Others": .white
    ]
    return colors[category] ?? .white
}


#Preview {
    HomePage()
        .preferredColorScheme(.dark)
}
