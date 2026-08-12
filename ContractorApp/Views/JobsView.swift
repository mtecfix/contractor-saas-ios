import SwiftUI
struct JobsView: View {
    @StateObject private var vm = JobsViewModel()
    @State private var showAdd = false
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading { ProgressView("Loading...") }
                else if vm.jobs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "hammer.fill").font(.system(size: 48)).foregroundColor(.secondary)
                        Text("No jobs yet").font(.headline)
                        Text("Tap + to create an estimate").font(.caption).foregroundColor(.secondary)
                    }
                } else {
                    List(vm.jobs) { job in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(job.clientName).font(.headline)
                                Spacer()
                                Text("$\(job.totalAmount, specifier: "%.2f")").font(.headline).foregroundColor(.green)
                            }
                            Text(job.address).font(.caption).foregroundColor(.secondary)
                            Text(job.status.capitalized).font(.caption2).padding(4).background(Color.blue.opacity(0.1)).cornerRadius(4)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Jobs & Estimates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button { showAdd = true } label: { Image(systemName: "plus") } }
            }
            .sheet(isPresented: $showAdd) { AddJobView(vm: vm) }
            .task { await vm.load() }
        }
    }
}
