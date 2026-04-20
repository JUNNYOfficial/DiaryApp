import AuthenticationServices
import CryptoKit

class AppleSignInService: NSObject, ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userIdentifier: String = ""
    @Published var fullName: String = ""
    @Published var email: String = ""
    
    static let shared = AppleSignInService()
    private var currentNonce: String?
    
    private override init() {
        super.init()
        checkCredentialState()
    }
    
    func checkCredentialState() {
        guard let userID = UserDefaults.standard.string(forKey: "userIdentifier"), !userID.isEmpty else {
            isLoggedIn = false
            return
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userID) { [weak self] credentialState, error in
            DispatchQueue.main.async {
                switch credentialState {
                case .authorized:
                    self?.isLoggedIn = true
                    self?.userIdentifier = userID
                    self?.fullName = UserDefaults.standard.string(forKey: "userFullName") ?? ""
                    self?.email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
                case .revoked, .notFound:
                    self?.isLoggedIn = false
                    self?.logout()
                default:
                    break
                }
            }
        }
    }
    
    func signIn(with window: UIWindow?) {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "userIdentifier")
        UserDefaults.standard.removeObject(forKey: "userFullName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        isLoggedIn = false
        userIdentifier = ""
        fullName = ""
        email = ""
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var nonce = ""
        for byte in randomBytes {
            nonce.append(charset[Int(byte) % charset.count])
        }
        return nonce
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            DispatchQueue.main.async { [weak self] in
                self?.userIdentifier = userIdentifier
                self?.isLoggedIn = true
                
                UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
                
                if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                    let name = "\(givenName) \(familyName)"
                    self?.fullName = name
                    UserDefaults.standard.set(name, forKey: "userFullName")
                }
                
                if let email = email {
                    self?.email = email
                    UserDefaults.standard.set(email, forKey: "userEmail")
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple failed: \(error.localizedDescription)")
    }
}

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
