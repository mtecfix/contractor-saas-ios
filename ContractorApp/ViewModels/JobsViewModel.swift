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
    func create(clientName: String, address: String, desc: String, hours: Double, rate: Double) async {
        let r = CreateJobRequest(clientName: clientName, address: address, description: desc, laborHours: hours, laborRate: rate, materials: [], markup: 0.2, taxRate: 0)
        do { let j = try await APIService.shared.createJob(r); jobs.insert(j, at: 0) }
        catch { self.error = error.localizedDescription }
    }
}
