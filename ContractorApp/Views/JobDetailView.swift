import SwiftUI

struct JobDetailView: View {
    let job: Job
    @ObservedObject var jobsVM: JobsViewModel
    @ObservedObject var invoicesVM: InvoicesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit        = false
    @State private var showCreateInvoice = false
    @State private var showDeleteConfirm = false
    @State private var statusMessage: String? = nil

    var laborTotal: Double { job.laborHours * job.laborRate }
    var materialsTotal: Double { job.materials.reduce(0) { $0 + ($1.cost * Double($1.quantity)) } }
    var subtotal: Double { (laborTotal + materialsTotal) * (1 + job.markup) }
    var tax: Double { subtotal * job.taxRate }

    var body: some View {
        List {
            Section("Client") {
                LabeledContent("Name", value: job.clientName)
                LabeledContent("Address", value: job.address)
                if !job.clientEmail.isEmpty {
                    LabeledContent("Email", value: job.clientEmail)
                }
            }

            Section("Description") {
                Text(job.description).font(.body)
            }

            Section("Labor") {
                LabeledContent("Hours", value: String(format: "%.1f hrs", job.laborHours))
                LabeledContent("Rate", value: String(format: "$%.2f/hr", job.laborRate))
                LabeledContent("Labor Total", value: String(format: "$%.2f", laborTotal))
            }

            if !job.materials.isEmpty {
                Section("Materials") {
                    ForEach(job.materials, id: \.name) { mat in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(mat.name).font(.subheadline)
                                Text("Qty: \(mat.quantity)").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(String(format: "$%.2f", mat.cost * Double(mat.quantity))).font(.subheadline)
                        }
                    }
                    LabeledContent("Materials Total", value: String(format: "$%.2f", materialsTotal))
                }
            }

            Section("Totals") {
                LabeledContent("Markup (\(Int(job.markup * 100))%)", value: String(format: "$%.2f", (laborTotal + materialsTotal) * job.markup))
                if job.taxRate > 0 {
                    LabeledContent("Tax (\(Int(job.taxRate * 100))%)", value: String(format: "$%.2f", tax))
                }
                LabeledContent("Total", value: String(format: "$%.2f", job.totalAmount))
                    .font(.headline)
            }

            Section("Status") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(job.status.capitalized)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(statusColor(job.status).opacity(0.15))
                        .cornerRadius(6)
                        .foregroundColor(statusColor(job.status))
                }
                Text("Created: \(job.createdAt.prefix(10))").font(.caption).foregroundColor(.secondary)
            }

            if let msg = statusMessage {
                Section { Text(msg).foregroundColor(.green).font(.caption) }
            }
        }
        .navigationTitle("Job Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button { showCreateInvoice = true } label: {
                    Label("Invoice", systemImage: "doc.text.fill")
                }
                Menu {
                    Button { showEdit = true } label: { Label("Edit Job", systemImage: "pencil") }
                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        Label("Delete Job", systemImage: "trash")
                    }
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .sheet(isPresented: $showEdit) { EditJobView(vm: jobsVM, job: job) }
        .sheet(isPresented: $showCreateInvoice) { CreateInvoiceView(vm: invoicesVM, job: job) }
        .confirmationDialog("Delete job for \(job.clientName)?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task { await jobsVM.deleteJob(jobId: job.id); dismiss() }
            }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This will permanently delete the job estimate.") }
    }

    func statusColor(_ status: String) -> Color {
        switch status {
        case "paid", "completed": return .green
        case "invoiced": return .blue
        case "estimate": return .orange
        default: return .secondary
        }
    }
}
