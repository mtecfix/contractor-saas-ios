import SwiftUI

struct LoginView: View {
    @StateObject private var auth = AuthService.shared
    @State private var email = ""; @State private var password = ""
    @State private var error: String? = nil; @State private var loading = false
    @State private var showSignUp = false; @State private var showForgot = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 64)).foregroundColor(.blue)
                Text("Contractor").font(.largeTitle.bold())
                Text("Estimates & Invoices on the go").font(.subheadline).foregroundColor(.secondary)

                VStack(spacing: 12) {
                    TextField("Email", text: $email).keyboardType(.emailAddress).autocapitalization(.none).textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
                }.padding(.horizontal)

                if let e = error { Text(e).foregroundColor(.red).font(.caption).padding(.horizontal) }

                Button(action: signIn) {
                    if loading { ProgressView().frame(maxWidth: .infinity) }
                    else { Text("Sign In").frame(maxWidth: .infinity) }
                }
                .buttonStyle(.borderedProminent).disabled(email.isEmpty || password.isEmpty || loading).padding(.horizontal)

                Button("Forgot Password?") { showForgot = true }.font(.caption).foregroundColor(.blue)
                Divider().padding(.horizontal)
                HStack {
                    Text("No account?").foregroundColor(.secondary)
                    Button("Sign Up") { showSignUp = true }.fontWeight(.semibold)
                }.font(.subheadline)
                Spacer()
            }
            .sheet(isPresented: $showSignUp) { SignUpView() }
            .sheet(isPresented: $showForgot) { ForgotPasswordView() }
        }
    }

    func signIn() {
        loading = true; error = nil
        Task {
            do { try await auth.signIn(email: email, password: password) }
            catch { self.error = error.localizedDescription }
            loading = false
        }
    }
}
