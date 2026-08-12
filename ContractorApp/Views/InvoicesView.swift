import SwiftUI
struct InvoicesView: View {
    @StateObject private var vm = InvoicesViewModel()
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading { ProgressView("Loading...") }
                else if vm.invoices.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text").font(.system(size: 48)).foregroundColor(.secondary)
                        Text("No invoices yet").font(.headline)
                    }
                } else {
                    List(vm.invoices) { inv in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(inv.clientName).font(.headline)
                                Spacer()
                                Text("$\(inv.amount, specifier: "%.2f")").font(.headline).foregroundColor(.blue)
                            }
                            HStack {
                                Text("Due: \(inv.dueDate)").font(.caption).foregroundColor(.secondary)
                                Spacer()
                                Text(inv.status.capitalized).font(.caption2).padding(4)
                                    .background(inv.status == "unpaid" ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Invoices")
            .task { await vm.load() }
        }
    }
}
