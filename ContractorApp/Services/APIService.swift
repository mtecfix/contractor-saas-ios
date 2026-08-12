import Foundation
enum APIError: Error, LocalizedError {
    case invalidURL, noToken, requestFailed(Int, String), decodingFailed(String)
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noToken: return "Not authenticated"
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
        let http = resp as! HTTPURLResponse
        guard (200...299).contains(http.statusCode) else {
            throw APIError.requestFailed(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { throw APIError.decodingFailed(error.localizedDescription) }
    }
    func getJobs() async throws -> [Job] {
        struct R: Decodable { let jobs: [Job] }
        return try await (req("/jobs") as R).jobs
    }
    func createJob(_ j: CreateJobRequest) async throws -> Job {
        struct R: Decodable { let job: Job }
        return try await (req("/jobs", method: "POST", body: j) as R).job
    }
    func getInvoices() async throws -> [Invoice] {
        struct R: Decodable { let invoices: [Invoice] }
        return try await (req("/invoices") as R).invoices
    }
    func createInvoice(_ i: CreateInvoiceRequest) async throws -> Invoice {
        struct R: Decodable { let invoice: Invoice; let downloadUrl: String? }
        let r: R = try await req("/invoices", method: "POST", body: i)
        var inv = r.invoice
        inv.downloadUrl = r.downloadUrl
        return inv
    }
}
