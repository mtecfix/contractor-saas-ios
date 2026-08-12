import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL, requestFailed(Int, String), decodingFailed(String)
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .requestFailed(let c, let m): return "Error (\(c)): \(m)"
        case .decodingFailed(let m): return "Decode error: \(m)"
        }
    }
}

class APIService {
    static let shared = APIService()
    private let base = Config.apiEndpoint
    private var token: String? = nil
    func setToken(_ t: String) { token = t }

    private func req<T: Decodable>(_ path: String, method: String = "GET", body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: "\(base)\(path)") else { throw APIError.invalidURL }
        var r = URLRequest(url: url)
        r.httpMethod = method
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let t = token { r.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        if let b = body { r.httpBody = try JSONEncoder().encode(b) }
        let (data, resp) = try await URLSession.shared.data(for: r)
        let code = (resp as! HTTPURLResponse).statusCode
        guard (200...299).contains(code) else { throw APIError.requestFailed(code, String(data: data, encoding: .utf8) ?? "") }
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { throw APIError.decodingFailed(error.localizedDescription) }
    }

    // MARK: - Jobs
    func getJobs() async throws -> [Job] {
        struct R: Decodable { let jobs: [Job] }; return try await (req("/jobs") as R).jobs
    }
    func getJob(jobId: String) async throws -> Job {
        struct R: Decodable { let job: Job }
        let enc = jobId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? jobId
        return try await (req("/jobs/\(enc)") as R).job
    }
    func createJob(_ j: CreateJobRequest) async throws -> Job {
        struct R: Decodable { let job: Job }; return try await (req("/jobs", method: "POST", body: j) as R).job
    }
    func updateJob(jobId: String, clientName: String, clientEmail: String, address: String,
                   description: String, laborHours: Double, laborRate: Double,
                   markup: Double, taxRate: Double, materials: [Material], status: String) async throws -> Double {
        struct Body: Encodable {
            let clientName: String; let clientEmail: String; let address: String
            let description: String; let laborHours: Double; let laborRate: Double
            let markup: Double; let taxRate: Double; let materials: [Material]; let status: String
        }
        struct R: Decodable { let updated: Bool; let totalAmount: Double }
        let enc = jobId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? jobId
        let r: R = try await req("/jobs/\(enc)", method: "PUT",
            body: Body(clientName: clientName, clientEmail: clientEmail, address: address,
                       description: description, laborHours: laborHours, laborRate: laborRate,
                       markup: markup, taxRate: taxRate, materials: materials, status: status))
        return r.totalAmount
    }
    func deleteJob(jobId: String) async throws {
        struct R: Decodable { let deleted: Bool }
        let enc = jobId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? jobId
        let _: R = try await req("/jobs/\(enc)", method: "DELETE")
    }

    // MARK: - Invoices
    func getInvoices() async throws -> [Invoice] {
        struct R: Decodable { let invoices: [Invoice] }; return try await (req("/invoices") as R).invoices
    }
    func createInvoice(_ i: CreateInvoiceRequest) async throws -> Invoice {
        struct R: Decodable { let invoice: Invoice; let downloadUrl: String? }
        let r: R = try await req("/invoices", method: "POST", body: i)
        var inv = r.invoice; inv.downloadUrl = r.downloadUrl; return inv
    }
    func updateInvoiceStatus(invoiceId: String, status: String) async throws {
        struct Body: Encodable { let status: String }
        struct R: Decodable { let updated: Bool }
        let enc = invoiceId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? invoiceId
        let _: R = try await req("/invoices/\(enc)/status", method: "PUT", body: Body(status: status))
    }
    func deleteInvoice(invoiceId: String) async throws {
        struct R: Decodable { let deleted: Bool }
        let enc = invoiceId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? invoiceId
        let _: R = try await req("/invoices/\(enc)", method: "DELETE")
    }
}
