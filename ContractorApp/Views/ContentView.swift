import SwiftUI
struct ContentView: View {
    var body: some View {
        TabView {
            JobsView().tabItem { Label("Jobs", systemImage: "wrench.and.screwdriver.fill") }
            InvoicesView().tabItem { Label("Invoices", systemImage: "doc.text.fill") }
        }
    }
}
