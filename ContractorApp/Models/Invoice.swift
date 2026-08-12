import Foundation

struct Invoice: Codable, Identifiable {
    let id: String
    let userId: String
    var invoiceNumber: String
    var jobRef: String
    var clientName: String
    var clientEmail: String
    var amount: Double
    var status: String
    var dueDate: String
    var notes: String
    var downloadUrl: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "RecordId", userId = "UserId"
        case invoiceNumber, jobRef, clientName, clientEmail
        case amount, status, dueDate, notes, downloadUrl, createdAt
    }
}

struct CreateInvoiceRequest: Codable {
    let jobId: String
    let clientName: String
    let clientEmail: String
    let amount: Double
    let dueDate: String
    let notes: String
    let lineItems: [[String: Double]]
}
