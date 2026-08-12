import SwiftUI

struct InvoiceReminderView: View {
    let invoice: Invoice
    @StateObject private var notif = NotificationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var daysBeforeDue = 3
    @State private var scheduled = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Invoice") {
                    LabeledContent("Client",  value: invoice.clientName)
                    LabeledContent("Amount",  value: String(format: "$%.2f", invoice.amount))
                    LabeledContent("Due",     value: invoice.dueDate)
                }
                Section("Reminder") {
                    Stepper("\(daysBeforeDue) days before due", value: $daysBeforeDue, in: 1...14)
                    Button(action: schedule) {
                        Label("Set Reminder", systemImage: "bell.badge.fill")
                    }
                    if scheduled {
                        Label("Reminder set!", systemImage: "checkmark.circle.fill").foregroundColor(.green)
                    }
                }
                Section {
                    HStack {
                        Image(systemName: notif.permissionGranted ? "bell.fill" : "bell.slash.fill")
                            .foregroundColor(notif.permissionGranted ? .green : .orange)
                        Text(notif.permissionGranted ? "Notifications enabled" : "Tap to enable")
                        if !notif.permissionGranted {
                            Spacer()
                            Button("Enable") { Task { await notif.requestPermission() } }
                                .buttonStyle(.borderedProminent).controlSize(.small)
                        }
                    }
                }
            }
            .navigationTitle("Payment Reminder").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }

    func schedule() {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        guard let dueDate = df.date(from: invoice.dueDate) else { return }
        let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBeforeDue, to: dueDate) ?? dueDate
        let interval = reminderDate.timeIntervalSinceNow
        if interval > 0 {
            notif.scheduleLocal(
                id: "invoice-\(invoice.id)",
                title: "Invoice Due Soon",
                body: "Invoice for \(invoice.clientName) ($\(String(format: "%.2f", invoice.amount))) due in \(daysBeforeDue) days",
                in: interval
            )
            scheduled = true
        }
    }
}
