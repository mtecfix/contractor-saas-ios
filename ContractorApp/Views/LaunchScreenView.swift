import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.10, blue: 0.12),
                         Color(red: 0.18, green: 0.18, blue: 0.22)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(red: 0.96, green: 0.62, blue: 0.12))
                        .frame(width: 120, height: 120)
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 6) {
                    Text("Contractor")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Estimates & Invoices on the go")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.70))
                }
            }
        }
    }
}
