import SwiftUI
struct AddJobView: View {
    @ObservedObject var vm: JobsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var clientName = ""
    @State private var address = ""
    @State private var desc = ""
    @State private var hours = ""
    @State private var rate = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Client Name", text: $clientName)
                    TextField("Address", text: $address)
                }
                Section("Work") {
                    TextField("Description", text: $desc)
                    HStack { TextField("Labor Hours", text: $hours).keyboardType(.decimalPad); Text("hrs") }
                    HStack { Text("$"); TextField("Hourly Rate", text: $rate).keyboardType(.decimalPad) }
                }
                Section("Estimate") {
                    let h = Double(hours) ?? 0, r = Double(rate) ?? 0
                    let subtotal = h * r * 1.2
                    LabeledContent("Subtotal (20% markup)", value: "$\(String(format: "%.2f", subtotal))")
                }
            }
            .navigationTitle("New Estimate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await vm.create(clientName: clientName, address: address, desc: desc, hours: Double(hours) ?? 0, rate: Double(rate) ?? 0); dismiss() }
                    }
                    .disabled(clientName.isEmpty || address.isEmpty)
                }
            }
        }
    }
}
