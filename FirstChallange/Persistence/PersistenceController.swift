import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "FirstChallangeModel") // Sesuai dengan nama .xcdatamodeld
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    

    func getTransactions(forMonth month: Int, year: Int) -> [FinancialTransaction] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<FinancialTransaction> = FinancialTransaction.fetchRequest()

        let calendar = Calendar.current
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            print("Invalid date calculation")
            return []
        }

        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialTransaction.date, ascending: false)]

        do {
            let results = try context.fetch(fetchRequest)
            print("Fetched \(results.count) transactions for \(month)-\(year).")
            return results
        } catch {
            print("Failed to fetch transactions: \(error.localizedDescription)")
            return []
        }
    }


    func getTransactionsForDay(date: Date) -> [FinancialTransaction] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<FinancialTransaction> = FinancialTransaction.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialTransaction.date, ascending: false)]

        do {
            let results = try context.fetch(fetchRequest)
            print("Fetched \(results.count) transactions for \(date).")
            return results
        } catch {
            print("Failed to fetch transactions for the day: \(error.localizedDescription)")
            return []
        }
    }

    func getTransactionsForLast7Days() -> [Date: [FinancialTransaction]] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<FinancialTransaction> = FinancialTransaction.fetchRequest()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // Awal hari ini (00:00:00)
        let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)! // Akhir hari ini
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)! // 7 hari terakhir termasuk hari ini
        
        // Filter transaksi dalam rentang 7 hari terakhir (termasuk hari ini)
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", sevenDaysAgo as NSDate, endOfToday as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialTransaction.date, ascending: false)]

        do {
            let transactions = try context.fetch(fetchRequest)
            
            // Kelompokkan transaksi berdasarkan tanggal
            var groupedTransactions: [Date: [FinancialTransaction]] = [:]
            for transaction in transactions {
                let transactionDate = calendar.startOfDay(for: transaction.date ?? today)
                groupedTransactions[transactionDate, default: []].append(transaction)
            }

            return groupedTransactions
        } catch {
            print("Failed to fetch transactions for last 7 days: \(error.localizedDescription)")
            return [:]
        }
    }



    /// Function untuk menyimpan transaksi baru ke Core Data
//    func saveTransaction(amount: Int64, date: Date, category: String, isExpense: Bool) {
//        let context = viewContext
//        let newTransaction = FinancialTransaction(context: context)
//        newTransaction.id = UUID()
//        newTransaction.amount = amount
//        newTransaction.date = date
//        newTransaction.category = category
//        newTransaction.isExpense = isExpense
//
//        do {
//            try context.save()
//            print("Transaction saved successfully: \(newTransaction)")
//        } catch {
//            print("Failed to save transaction: \(error.localizedDescription)")
//        }
//    }
    func saveTransaction(amount: Int64, date: Date, category: String, isExpense: Bool, notes: String?) {
        let context = viewContext
        let newTransaction = FinancialTransaction(context: context)
        
        newTransaction.id = UUID()
        newTransaction.amount = amount
        newTransaction.date = date
        newTransaction.category = category
        newTransaction.isExpense = isExpense
        newTransaction.notes = notes  // Menambahkan properti notes

        do {
            try context.save()
            print("Transaction saved successfully: \(newTransaction)")
        } catch {
            print("Failed to save transaction: \(error.localizedDescription)")
        }
    }

    
    func clearAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FinancialTransaction")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try container.viewContext.execute(deleteRequest)
            try container.viewContext.save()
        } catch {
            print("Error deleting data: \(error.localizedDescription)")
        }
    }
    
    func deleteTransaction(id: UUID) {
        let context = viewContext
        let fetchRequest: NSFetchRequest<FinancialTransaction> = FinancialTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let transactionToDelete = results.first {
                context.delete(transactionToDelete)
                try context.save()
                print("Transaction deleted successfully: \(id)")
            } else {
                print("Transaction not found: \(id)")
            }
        } catch {
            print("Failed to delete transaction: \(error.localizedDescription)")
        }
    }
    
    func updateTransaction(transaction: FinancialTransaction, newAmount: Int64, newDate: Date, newCategory: String, newIsExpense: Bool) {
        let context = viewContext
        transaction.amount = newAmount
        transaction.date = newDate
        transaction.category = newCategory
        transaction.isExpense = newIsExpense

        do {
            try context.save()
            print("Transaction updated successfully: \(transaction.id?.uuidString ?? "Unknown ID")")
        } catch {
            print("Failed to update transaction: \(error.localizedDescription)")
        }
    }

}
