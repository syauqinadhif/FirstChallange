import SwiftUI
import CoreData

struct NewTransactionModal: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var rawAmount: String = ""
    @State private var displayAmount: String = ""
    @State private var notes: String = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory = "Others"
    @State private var isExpense = true
    @State private var calendarId: Int = 0

    let categories = ["Foods", "Transports", "Bills", "Shops", "Others"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Segmented Control (Expense / Income)
                Picker("", selection: $isExpense) {
                    Text("Expense").tag(true)
                    Text("Income").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: isExpense) { _, _ in
                    rawAmount = ""
                    displayAmount = ""
                }
                
                Form {
                    // Input Nominal dengan format Rupiah real-time
                    HStack {
                        Text("Rp")
                        TextField("Nominal", text: $displayAmount)
                            .keyboardType(.numberPad)
                            .onChange(of: displayAmount) { newValue in
                                updateAmountInput(newValue)
                            }
                    }

                    HStack {
                        TextField("Notes", text: $notes)
                            .onChange(of: notes) { _, newValue in
                                if newValue.count > 15 {
                                    notes = String(newValue.prefix(15))
                                }
                            }
                    }
                    
                    // Date Picker
                    DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                        .id(calendarId)
                        .onChange(of: selectedDate) {
                            calendarId += 1
                        }
                    
                    // Category Picker (Hanya muncul jika Expense)
                    if isExpense {
                        Picker("Select Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)

                Spacer()
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                    .foregroundColor(.blue),
                trailing: Button("Add") {
                    saveTransaction()
                }
                .foregroundColor(.blue)
            )
        }
        .presentationDetents([.medium])
    }
    
    private func saveTransaction() {
        guard let amountValue = Int64(rawAmount) else { return }
        
        PersistenceController.shared.saveTransaction(
            amount: amountValue,
            date: selectedDate,
            category: isExpense ? selectedCategory : "Income",
            isExpense: isExpense,
            notes: notes
        )

        presentationMode.wrappedValue.dismiss()
    }

    // Fungsi untuk memperbarui input nominal
    private func updateAmountInput(_ newValue: String) {
        // Ambil hanya angka
        let numericValue = newValue.filter { $0.isNumber }
        rawAmount = numericValue
        
        // Format ulang sebagai Rupiah
        if let amount = Int(numericValue) {
            displayAmount = formatToRupiah(amount)
        } else {
            displayAmount = ""
        }
    }

    // Format angka menjadi format Rupiah dengan titik sebagai pemisah ribuan
    private func formatToRupiah(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

#Preview {
    NewTransactionModal()
        .preferredColorScheme(.dark)
}
