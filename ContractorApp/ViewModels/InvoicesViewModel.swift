import Foundation
@MainActor class InvoicesViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    func load() async {
        isLoading = true; error = nil
        do { invoices = try await APIService.shared.getInvoices() }
        catch { self.error = error.localizedDescription }
        isLoading = false
    }
    func create(jobId: String, clientName: String, amount: Double, dueDate: String) async {
        let r = CreateInvoiceRequest(jobId: jobId, clientName: clientName, amount: amount, dueDate: dueDate)
        do { let inv = try await APIService.shared.createInvoice(r); invoices.insert(inv, at: 0) }
        catch { self.error = error.localizedDescription }
    }
}
