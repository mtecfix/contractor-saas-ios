import Foundation

@MainActor class InvoicesViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false
    @Published var error: String? = nil

    var totalOutstanding: Double { invoices.filter { $0.status == "unpaid" }.reduce(0) { $0 + $1.amount } }
    var totalPaid: Double { invoices.filter { $0.status == "paid" }.reduce(0) { $0 + $1.amount } }

    func load() async {
        isLoading = true; error = nil
        do { invoices = try await APIService.shared.getInvoices() }
        catch { self.error = error.localizedDescription }
        isLoading = false
    }

    func create(jobId: String, clientName: String, clientEmail: String, amount: Double, dueDate: String, notes: String, lineItems: [[String: Double]] = []) async throws -> Invoice {
        let r = CreateInvoiceRequest(jobId: jobId, clientName: clientName, clientEmail: clientEmail,
            amount: amount, dueDate: dueDate, notes: notes, lineItems: lineItems)
        let inv = try await APIService.shared.createInvoice(r)
        invoices.insert(inv, at: 0)
        return inv
    }

    func updateStatus(invoiceId: String, status: String) async {
        do {
            try await APIService.shared.updateInvoiceStatus(invoiceId: invoiceId, status: status)
            if let idx = invoices.firstIndex(where: { $0.id == invoiceId }) {
                invoices[idx].status = status
            }
        } catch { self.error = error.localizedDescription }
    }

    func deleteInvoice(invoiceId: String) async {
        do { try await APIService.shared.deleteInvoice(invoiceId: invoiceId); invoices.removeAll { $0.id == invoiceId } }
        catch { self.error = error.localizedDescription }
    }
}
