import SwiftUI

struct EditJobView: View {
    @ObservedObject var vm: JobsViewModel
    let job: Job
    @Environment(\.dismiss) private var dismiss
    @State private var clientName: String
    @State private var clientEmail: String
    @State private var address: String
    @State private var description: String
    @State private var laborHours: String
    @State private var laborRate: String
    @State private var markup: String
    @State private var taxRate: String
    @State private var status: String
    @State private var loading = false
    @State private var error: String? = nil

    let statuses = ["estimate", "accepted", "in_progress", "invoiced", "completed", "cancelled"]

    init(vm: JobsViewModel, job: Job) {
        self.vm = vm; self.job = job
        _clientName  = State(initialValue: job.clientName)
        _clientEmail = State(initialValue: job.clientEmail)
        _address     = State(initialValue: job.address)
        _description = State(initialValue: job.description)
        _laborHours  = State(initialValue: String(job.laborHours))
        _laborRate   = State(initialValue: String(job.laborRate))
        _markup      = State(initialValue: String(Int(job.markup * 100)))
        _taxRate     = State(initialValue: String(Int(job.taxRate * 100)))
        _status      = State(initialValue: job.status)
    }

    var estimatedTotal: Double {
        let l = (Double(laborHours) ?? 0) * (Double(laborRate) ?? 0)
        let mk = (Double(markup) ?? 20) / 100.0
        let tx = (Double(taxRate) ?? 0) / 100.0
        return l * (1 + mk) * (1 + tx)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Client Name", text: $clientName)
                    TextField("Client Email", text: $clientEmail).keyboardType(.emailAddress).autocapitalization(.none)
                    TextField("Address", text: $address)
                }
                Section("Work") {
                    TextField("Description", text: $description)
                    HStack { TextField("Labor Hours", text: $laborHours).keyboardType(.decimalPad); Text("hrs") }
                    HStack { Text("$"); TextField("Hourly Rate", text: $laborRate).keyboardType(.decimalPad) }
                    HStack { TextField("Markup", text: $markup).keyboardType(.decimalPad); Text("%") }
                    HStack { TextField("Tax Rate", text: $taxRate).keyboardType(.decimalPad); Text("%") }
                }
                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { Text($0.replacingOccurrences(of: "_", with: " ").capitalized) }
                    }
                }
                Section("Estimated Total") {
                    Text(String(format: "$%.2f", estimatedTotal)).font(.headline).foregroundColor(.green)
                }
                if let e = error { Section { Text(e).foregroundColor(.red).font(.caption) } }
            }
            .navigationTitle("Edit Job").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(clientName.isEmpty || address.isEmpty || loading)
                }
            }
        }
    }

    func save() {
        loading = true; error = nil
        Task {
            do {
                try await vm.updateJob(jobId: job.id, clientName: clientName, clientEmail: clientEmail,
                    address: address, description: description,
                    laborHours: Double(laborHours) ?? 0, laborRate: Double(laborRate) ?? 0,
                    markup: (Double(markup) ?? 20) / 100.0, taxRate: (Double(taxRate) ?? 0) / 100.0,
                    materials: job.materials, status: status)
                dismiss()
            } catch { self.error = error.localizedDescription }
            loading = false
        }
    }
}
