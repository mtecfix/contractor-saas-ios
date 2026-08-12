import Foundation
struct Material: Codable {
    var name: String
    var cost: Double
    var quantity: Int
}
struct Job: Codable, Identifiable {
    let id: String
    let userId: String
    var clientName: String
    var address: String
    var description: String
    var laborHours: Double
    var laborRate: Double
    var materials: [Material]
    var markup: Double
    var taxRate: Double
    var totalAmount: Double
    var status: String
    let createdAt: String
    enum CodingKeys: String, CodingKey {
        case id = "ItemId", userId = "UserId"
        case clientName, address, description, laborHours, laborRate
        case materials, markup, taxRate, totalAmount, status, createdAt
    }
}
struct CreateJobRequest: Codable {
    let clientName: String
    let address: String
    let description: String
    let laborHours: Double
    let laborRate: Double
    let materials: [Material]
    let markup: Double
    let taxRate: Double
}
