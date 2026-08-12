import SwiftUI

struct ConfirmEmailView: View {
    let email: String; let onConfirmed: () -> Void
    @StateObject private var auth = AuthService.shared
    @State private var code = ""; @State private var error: String? = nil; @State private var loading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "envelope.badge.fill").font(.system(size: 56)).foregroundColor(.blue).padding(.top, 32)
                Text("Check Your Email").font(.largeTitle.bold())
                Text("Enter the 6-digit code sent to\n**\(email)**").multilineTextAlignment(.center).foregroundColor(.secondary)
                TextField("6-digit code", text: $code).textFieldStyle(.roundedBorder).keyboardType(.numberPad).multilineTextAlignment(.center).font(.title2.monospacedDigit()).padding(.horizontal)
                if let e = error { Text(e).font(.caption).foregroundColor(.red) }
                Button(action: confirm) {
                    if loading { ProgressView().frame(maxWidth: .infinity) }
                    else { Text("Verify Email").frame(maxWidth: .infinity) }
                }
                .buttonStyle(.borderedProminent).disabled(code.count < 6 || loading).padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Verify Email").navigationBarTitleDisplayMode(.inline)
        }
    }

    func confirm() {
        loading = true; error = nil
        Task {
            do { try await auth.confirmSignUp(email: email, code: code); onConfirmed() }
            catch { self.error = error.localizedDescription }
            loading = false
        }
    }
}
