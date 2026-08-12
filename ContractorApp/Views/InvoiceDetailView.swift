import SwiftUI

struct InvoiceDetailView: View {
    let invoice: Invoice
    @ObservedObject var vm: InvoicesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var marking = false

    var body: some View {
        List {
            Section("Invoice") {
                LabeledContent("Invoice #", value: invoice.invoiceNumber)
                LabeledContent("Client", value: invoice.clientName)
                if !invoice.clientEmail.isEmpty {
                    LabeledContent("Email", value: invoice.clientEmail)
                }
            }

            Section("Amount") {
                LabeledContent("Total", value: String(format: "$%.2f", invoice.amount))
                    .font(.headline)
                LabeledContent("Due Date", value: invoice.dueDate)
                HStack {
                    Text("Status")
                    Spacer()
                    Text(invoice.status.capitalized)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(invoice.status == "paid" ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                        .foregroundColor(invoice.status == "paid" ? .green : .orange)
                        .cornerRadius(6)
                }
            }

            if !invoice.notes.isEmpty {
                Section("Notes") { Text(invoice.notes).font(.body) }
            }

            Section("Actions") {
                if invoice.status == "unpaid" {
                    Button(action: markPaid) {
                        if marking { ProgressView() }
                        else { Label("Mark as Paid", systemImage: "checkmark.circle.fill").foregroundColor(.green) }
                    }
                } else {
                    Button(action: markUnpaid) {
                        Label("Mark as Unpaid", systemImage: "arrow.uturn.left").foregroundColor(.orange)
                    }
                }

                if let url = invoice.downloadUrl, let downloadURL = URL(string: url) {
                    Link(destination: downloadURL) {
                        Label("Download Invoice", systemImage: "arrow.down.circle")
                    }
                }

                Button {
                    let text = "Invoice \(invoice.invoiceNumber)\nClient: \(invoice.clientName)\nAmount: $\(String(format: "%.2f", invoice.amount))\nDue: \(invoice.dueDate)"
                    let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let vc = scene.windows.first?.rootViewController {
                        vc.present(av, animated: true)
                    }
                } label: {
                    Label("Share Invoice", systemImage: "square.and.arrow.up")
                }

                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Label("Delete Invoice", systemImage: "trash")
                }
            }

            Section {
                Text("Created: \(invoice.createdAt.prefix(10))").font(.caption).foregroundColor(.secondary)
            }
        }
        .navigationTitle("Invoice Detail")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete invoice?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task { await vm.deleteInvoice(invoiceId: invoice.id); dismiss() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    func markPaid() {
        marking = true
        Task { await vm.updateStatus(invoiceId: invoice.id, status: "paid"); marking = false }
    }

    func markUnpaid() {
        marking = true
        Task { await vm.updateStatus(invoiceId: invoice.id, status: "unpaid"); marking = false }
    }
}
