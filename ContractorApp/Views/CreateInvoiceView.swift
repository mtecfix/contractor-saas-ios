import SwiftUI

struct CreateInvoiceView: View {
    @ObservedObject var vm: InvoicesViewModel
    let job: Job
    @Environment(\.dismiss) private var dismiss
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var notes = ""
    @State private var loading = false
    @State private var created: Invoice? = nil
    @State private var error: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Invoice Details") {
                    LabeledContent("Client", value: job.clientName)
                    LabeledContent("Amount", value: String(format: "$%.2f", job.totalAmount))
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                Section("Notes") {
                    TextField("Payment terms, notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                if let inv = created {
                    Section("Invoice Created") {
                        Label("Invoice \(inv.invoiceNumber) created!", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        if let url = inv.downloadUrl {
                            Link(destination: URL(string: url)!) {
                                Label("Download Invoice JSON", systemImage: "arrow.down.circle")
                            }
                        }
                        Button {
                            let text = "Invoice \(inv.invoiceNumber) for $\(String(format: "%.2f", inv.amount)) — Due \(inv.dueDate)"
                            let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let vc = scene.windows.first?.rootViewController {
                                vc.present(av, animated: true)
                            }
                        } label: {
                            Label("Share Invoice", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                if let e = error { Section { Text(e).foregroundColor(.red).font(.caption) } }
            }
            .navigationTitle("Create Invoice").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    if created == nil {
                        Button(action: create) {
                            if loading { ProgressView() } else { Text("Create") }
                        }.disabled(loading)
                    }
                }
            }
        }
    }

    func create() {
        loading = true; error = nil
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        let req = CreateInvoiceRequest(jobId: job.id, clientName: job.clientName,
            clientEmail: job.clientEmail, amount: job.totalAmount,
            dueDate: df.string(from: dueDate), notes: notes,
            lineItems: [["description": job.description, "amount": job.totalAmount]])
        Task {
            do { created = try await APIService.shared.createInvoice(req) }
            catch { self.error = error.localizedDescription }
            loading = false
        }
    }
}
