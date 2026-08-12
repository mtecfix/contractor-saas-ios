import SwiftUI

struct AddJobView: View {
    @ObservedObject var vm: JobsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var clientName = ""; @State private var clientEmail = ""
    @State private var address = ""; @State private var desc = ""
    @State private var hours = ""; @State private var rate = ""
    @State private var markup = "20"; @State private var taxRate = "0"
    @State private var loading = false

    var estimatedTotal: Double {
        let l = (Double(hours) ?? 0) * (Double(rate) ?? 0)
        let mk = (Double(markup) ?? 20) / 100.0
        let tx = (Double(taxRate) ?? 0) / 100.0
        return l * (1 + mk) * (1 + tx)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Client Name", text: $clientName)
                    TextField("Client Email (optional)", text: $clientEmail).keyboardType(.emailAddress).autocapitalization(.none)
                    TextField("Job Address", text: $address)
                }
                Section("Work") {
                    TextField("Description", text: $desc)
                    HStack { TextField("Labor Hours", text: $hours).keyboardType(.decimalPad); Text("hrs") }
                    HStack { Text("$"); TextField("Hourly Rate", text: $rate).keyboardType(.decimalPad) }
                    HStack { TextField("Markup", text: $markup).keyboardType(.decimalPad); Text("%") }
                    HStack { TextField("Tax Rate", text: $taxRate).keyboardType(.decimalPad); Text("%") }
                }
                Section("Estimate Total") {
                    Text(String(format: "$%.2f", estimatedTotal)).font(.title2.bold()).foregroundColor(.green)
                }
            }
            .navigationTitle("New Estimate").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await vm.create(clientName: clientName, clientEmail: clientEmail,
                                address: address, desc: desc,
                                hours: Double(hours) ?? 0, rate: Double(rate) ?? 0,
                                markup: (Double(markup) ?? 20) / 100.0,
                                taxRate: (Double(taxRate) ?? 0) / 100.0)
                            dismiss()
                        }
                    }
                    .disabled(clientName.isEmpty || address.isEmpty || loading)
                }
            }
        }
    }
}
