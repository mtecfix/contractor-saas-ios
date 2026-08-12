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
                        Text("Create an invoice from a job").font(.caption).foregroundColor(.secondary)
                    }
                } else {
                    List {
                        Section {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Outstanding").font(.caption).foregroundColor(.secondary)
                                    Text(String(format: "$%.2f", vm.totalOutstanding)).font(.title2.bold()).foregroundColor(.orange)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Collected").font(.caption).foregroundColor(.secondary)
                                    Text(String(format: "$%.2f", vm.totalPaid)).font(.title2.bold()).foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        Section("All Invoices") {
                            ForEach(vm.invoices) { inv in
                                NavigationLink(destination: InvoiceDetailView(invoice: inv, vm: vm)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(inv.clientName).font(.headline)
                                            Spacer()
                                            Text(String(format: "$%.2f", inv.amount)).font(.headline)
                                        }
                                        HStack {
                                            Text("Due: \(inv.dueDate)").font(.caption).foregroundColor(.secondary)
                                            Spacer()
                                            Text(inv.status.capitalized).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                                                .background(inv.status == "paid" ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                                                .foregroundColor(inv.status == "paid" ? .green : .orange)
                                                .cornerRadius(4)
                                        }
                                        Text(inv.invoiceNumber).font(.caption2).foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Invoices")
            .task { await vm.load() }
        }
    }
}
