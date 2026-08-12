import Foundation

class AuthService: ObservableObject {
    static let shared = AuthService()
    @Published var isAuthenticated = false
    @Published var currentUserId: String? = nil

    private let clientId = Config.cognitoClient
    private let region   = Config.awsRegion
    var authEndpoint: String { "https://cognito-idp.\(region).amazonaws.com/" }

    func signIn(email: String, password: String) async throws {
        let body: [String: Any] = ["AuthFlow": "USER_PASSWORD_AUTH", "ClientId": clientId,
            "AuthParameters": ["USERNAME": email, "PASSWORD": password]]
        let data = try await cognitoReq(target: "AWSCognitoIdentityProviderService.InitiateAuth", body: body)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let result = json?["AuthenticationResult"] as? [String: Any],
              let token = result["IdToken"] as? String else {
            throw AuthError.cognitoError((json?["message"] as? String) ?? "Sign in failed")
        }
        parseToken(token)
        APIService.shared.setToken(token)
    }

    func signUp(email: String, password: String) async throws {
        let body: [String: Any] = ["ClientId": clientId, "Username": email, "Password": password,
            "UserAttributes": [["Name": "email", "Value": email]]]
        let data = try await cognitoReq(target: "AWSCognitoIdentityProviderService.SignUp", body: body)
        if let err = try? (JSONSerialization.jsonObject(with: data) as? [String: Any])?["__type"] as? String {
            throw AuthError.cognitoError(err)
        }
    }

    func confirmSignUp(email: String, code: String) async throws {
        let body: [String: Any] = ["ClientId": clientId, "Username": email, "ConfirmationCode": code]
        let _ = try await cognitoReq(target: "AWSCognitoIdentityProviderService.ConfirmSignUp", body: body)
    }

    func forgotPassword(email: String) async throws {
        let body: [String: Any] = ["ClientId": clientId, "Username": email]
        let _ = try await cognitoReq(target: "AWSCognitoIdentityProviderService.ForgotPassword", body: body)
    }

    func confirmForgotPassword(email: String, code: String, newPassword: String) async throws {
        let body: [String: Any] = ["ClientId": clientId, "Username": email,
            "ConfirmationCode": code, "Password": newPassword]
        let _ = try await cognitoReq(target: "AWSCognitoIdentityProviderService.ConfirmForgotPassword", body: body)
    }

    func signOut() { isAuthenticated = false; currentUserId = nil; APIService.shared.setToken("") }

    private func cognitoReq(target: String, body: [String: Any]) async throws -> Data {
        guard let url = URL(string: authEndpoint) else { throw AuthError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
        req.setValue(target, forHTTPHeaderField: "X-Amz-Target")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: req)
        return data
    }

    private func parseToken(_ token: String) {
        let parts = token.components(separatedBy: ".")
        guard parts.count > 1 else { return }
        var b64 = parts[1]; let r = b64.count % 4; if r > 0 { b64 += String(repeating: "=", count: 4-r) }
        guard let d = Data(base64Encoded: b64),
              let p = try? JSONSerialization.jsonObject(with: d) as? [String: Any] else { return }
        DispatchQueue.main.async { self.currentUserId = p["sub"] as? String; self.isAuthenticated = true }
    }
}

enum AuthError: Error, LocalizedError {
    case invalidURL, cognitoError(String)
    var errorDescription: String? {
        switch self { case .invalidURL: return "Invalid URL"; case .cognitoError(let m): return m }
    }
}
