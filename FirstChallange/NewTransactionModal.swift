import SwiftUI
import CoreData

struct NewTransactionModal: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var amount: String = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory = "Other"
    @State private var isExpense = true
    
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

                Form {
                    // Input Nominal
                    HStack {
                        Text("Rp")
                            .fontWeight(.bold)
                        TextField("Nominal", text: $amount)
                            .keyboardType(.numberPad)
                    }
                    
                    // Date Picker
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    
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
        .presentationDetents([.medium, .large])
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        PersistenceController.shared.saveTransaction(
            amount: amountValue,
            date: selectedDate,
            category: isExpense ? selectedCategory : "Income",
            isExpense: isExpense
        )

        presentationMode.wrappedValue.dismiss()
    }

}

#Preview {
    NewTransactionModal()
        .preferredColorScheme(.dark)
}
