import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var auth = AuthService.shared
    @State private var email = ""; @State private var code = ""; @State private var newPass = ""
    @State private var step = 1; @State private var error: String? = nil; @State private var loading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "lock.rotation").font(.system(size: 56)).foregroundColor(.orange).padding(.top, 32)
                if step == 1 {
                    Text("Reset Password").font(.largeTitle.bold())
                    TextField("Email", text: $email).keyboardType(.emailAddress).autocapitalization(.none).textFieldStyle(.roundedBorder).padding(.horizontal)
                    Button(action: send) {
                        if loading { ProgressView().frame(maxWidth: .infinity) }
                        else { Text("Send Reset Code").frame(maxWidth: .infinity) }
                    }.buttonStyle(.borderedProminent).disabled(email.isEmpty || loading).padding(.horizontal)
                } else {
                    Text("Enter Reset Code").font(.largeTitle.bold())
                    VStack(spacing: 12) {
                        TextField("6-digit code", text: $code).textFieldStyle(.roundedBorder).keyboardType(.numberPad).multilineTextAlignment(.center)
                        SecureField("New Password", text: $newPass).textFieldStyle(.roundedBorder)
                    }.padding(.horizontal)
                    Button(action: reset) {
                        if loading { ProgressView().frame(maxWidth: .infinity) }
                        else { Text("Reset Password").frame(maxWidth: .infinity) }
                    }.buttonStyle(.borderedProminent).disabled(code.count < 6 || newPass.count < 8 || loading).padding(.horizontal)
                }
                if let e = error { Text(e).font(.caption).foregroundColor(.red) }
                Spacer()
            }
            .navigationTitle("Forgot Password").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }

    func send() {
        loading = true; error = nil
        Task { do { try await auth.forgotPassword(email: email); step = 2 } catch { self.error = error.localizedDescription }; loading = false }
    }
    func reset() {
        loading = true; error = nil
        Task { do { try await auth.confirmForgotPassword(email: email, code: code, newPassword: newPass); dismiss() } catch { self.error = error.localizedDescription }; loading = false }
    }
}
