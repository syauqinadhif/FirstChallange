import SwiftUI

struct TransactionDetailRow: View {
    let detail: TransactionDetail

    var body: some View {
        VStack {
            HStack {
                Image(systemName: detail.icon)
                    .foregroundColor(getIconColor(for: detail.category))
                    .font(.system(size: 20))
                Text(detail.category)
                    .font(.system(size: 18))
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

    private func getIconColor(for category: String) -> Color {
        switch category {
        case "Food": return .blue
        case "Transport": return .yellow
        case "Bill": return .orange
        case "Shopping": return .purple
        default: return .primary
        }
    }
}
