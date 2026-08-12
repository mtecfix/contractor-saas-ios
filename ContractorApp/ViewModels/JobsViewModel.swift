import Foundation

@MainActor class JobsViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var isLoading = false
    @Published var error: String? = nil

    func load() async {
        isLoading = true; error = nil
        do { jobs = try await APIService.shared.getJobs() }
        catch { self.error = error.localizedDescription }
        isLoading = false
    }

    func create(clientName: String, clientEmail: String, address: String, desc: String,
                hours: Double, rate: Double, markup: Double, taxRate: Double, materials: [Material] = []) async {
        let r = CreateJobRequest(clientName: clientName, clientEmail: clientEmail, address: address,
            description: desc, laborHours: hours, laborRate: rate,
            materials: materials, markup: markup, taxRate: taxRate)
        do { let j = try await APIService.shared.createJob(r); jobs.insert(j, at: 0) }
        catch { self.error = error.localizedDescription }
    }

    func updateJob(jobId: String, clientName: String, clientEmail: String, address: String,
                   description: String, laborHours: Double, laborRate: Double,
                   markup: Double, taxRate: Double, materials: [Material], status: String) async throws {
        let newTotal = try await APIService.shared.updateJob(jobId: jobId, clientName: clientName,
            clientEmail: clientEmail, address: address, description: description,
            laborHours: laborHours, laborRate: laborRate, markup: markup,
            taxRate: taxRate, materials: materials, status: status)
        if let idx = jobs.firstIndex(where: { $0.id == jobId }) {
            jobs[idx].clientName = clientName; jobs[idx].clientEmail = clientEmail
            jobs[idx].address = address; jobs[idx].description = description
            jobs[idx].laborHours = laborHours; jobs[idx].laborRate = laborRate
            jobs[idx].markup = markup; jobs[idx].taxRate = taxRate
            jobs[idx].totalAmount = newTotal; jobs[idx].status = status
        }
    }

    func deleteJob(jobId: String) async {
        do { try await APIService.shared.deleteJob(jobId: jobId); jobs.removeAll { $0.id == jobId } }
        catch { self.error = error.localizedDescription }
    }
}
