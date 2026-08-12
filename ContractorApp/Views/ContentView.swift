import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthService.shared
    var body: some View {
        if auth.isAuthenticated {
            TabView {
                JobsView().tabItem { Label("Jobs", systemImage: "wrench.and.screwdriver.fill") }
                InvoicesView().tabItem { Label("Invoices", systemImage: "doc.text.fill") }
            }
        } else {
            LoginView()
        }
    }
}
