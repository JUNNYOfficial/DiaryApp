import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.theme) var theme
    @StateObject private var authService = AppleSignInService.shared
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            theme.backgroundWhite
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                ZStack {
                    Circle()
                        .fill(theme.lightBlue)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(theme.primaryBlue)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6), value: isAnimating)
                
                VStack(spacing: 12) {
                    Text("心情日记")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(theme.textPrimary)
                    
                    Text("记录每一天的美好时光")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                
                Spacer()
                
                VStack(spacing: 16) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                handleAppleSignIn(credential)
                            }
                        case .failure(let error):
                            print("Sign in failed: \(error)")
                        }
                    }
                    .frame(height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text("使用 Apple ID 登录以同步您的日记到 iCloud")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func handleAppleSignIn(_ credential: ASAuthorizationAppleIDCredential) {
        let userID = credential.user
        UserDefaults.standard.set(userID, forKey: "userIdentifier")
        
        if let givenName = credential.fullName?.givenName,
           let familyName = credential.fullName?.familyName {
            UserDefaults.standard.set("\(givenName) \(familyName)", forKey: "userFullName")
        }
        if let email = credential.email {
            UserDefaults.standard.set(email, forKey: "userEmail")
        }
        
        authService.isLoggedIn = true
        authService.userIdentifier = userID
    }
}
