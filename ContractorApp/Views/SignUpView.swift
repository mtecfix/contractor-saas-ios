import SwiftUI

struct SignUpView: View {
    @StateObject private var auth = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""; @State private var password = ""; @State private var confirm = ""
    @State private var error: String? = nil; @State private var loading = false; @State private var showConfirm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "wrench.and.screwdriver.fill").font(.system(size: 48)).foregroundColor(.blue).padding(.top, 32)
                Text("Create Account").font(.largeTitle.bold())
                VStack(spacing: 12) {
                    TextField("Email", text: $email).keyboardType(.emailAddress).autocapitalization(.none).textFieldStyle(.roundedBorder)
                    SecureField("Password (8+ chars)", text: $password).textFieldStyle(.roundedBorder)
                    SecureField("Confirm Password", text: $confirm).textFieldStyle(.roundedBorder)
                    if !confirm.isEmpty && password != confirm { Text("Passwords do not match").font(.caption).foregroundColor(.red) }
                }.padding(.horizontal)
                if let e = error { Text(e).font(.caption).foregroundColor(.red) }
                Button(action: signUp) {
                    if loading { ProgressView().frame(maxWidth: .infinity) }
                    else { Text("Create Account").frame(maxWidth: .infinity) }
                }
                .buttonStyle(.borderedProminent).disabled(email.isEmpty || password.count < 8 || password != confirm || loading).padding(.horizontal)
            }
            .navigationTitle("Sign Up").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
            .sheet(isPresented: $showConfirm) { ConfirmEmailView(email: email, onConfirmed: { dismiss() }) }
        }
    }

    func signUp() {
        loading = true; error = nil
        Task {
            do { try await auth.signUp(email: email, password: password); showConfirm = true }
            catch { self.error = error.localizedDescription }
            loading = false
        }
    }
}
