import Foundation
struct Invoice: Codable, Identifiable {
    let id: String
    let userId: String
    var jobRef: String
    var clientName: String
    var amount: Double
    var status: String
    var dueDate: String
    let createdAt: String
    var downloadUrl: String?
    enum CodingKeys: String, CodingKey {
        case id = "RecordId", userId = "UserId"
        case jobRef, clientName, amount, status, dueDate, createdAt, downloadUrl
    }
}
struct CreateInvoiceRequest: Codable {
    let jobId: String
    let clientName: String
    let amount: Double
    let dueDate: String
}
