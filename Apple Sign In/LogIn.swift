import SwiftUI
import AuthenticationServices
import CommonCrypto
import Firebase
import CryptoKit
import FirebaseAuth

struct LogIn: View {
    @State private var currentNonce: String?
    // View properties
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var nonce: String?
    @Environment(\.colorScheme) private var scheme
    //User login state
    @AppStorage("log_status") private var logStatus: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader {
                let size = $0.size
                
                Image(.bg4)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .offset(y: -60)
                    .frame(width: size.width, height: size.height)
            }.ignoresSafeArea()
            // Gradient masking at bottom
                .mask{
                    Rectangle().fill(.linearGradient(
                        colors: [
                            .white,
                            .white,
                            .white,
                            .white,
                            .white.opacity(0.9),
                            .white.opacity(0.6),
                            .white.opacity(0.2),
                            .clear,
                            .clear
                        ], startPoint: .top, endPoint: .bottom
                    ))
                }
            
            // Sign In Button
            VStack(alignment: .leading){
                Text("Sign in to start your \nleading experiance")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/.bold())
                
                SignInWithAppleButton(.signIn) { request in
                    let nonce = randomNonceString()
                    self.nonce = nonce
                    // your preferences
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = sha256(nonce)
                }onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        loginWithFirebase(authorization)
                    case .failure(let error):
                        showError(error.localizedDescription)
                    }
                }
                .signInWithAppleButtonStyle(scheme == .dark ? .white : .black)
                .frame(height: 45)
                .clipShape(.capsule)
                .padding(.top, 10)
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        }.alert(errorMessage, isPresented: $showAlert) {}
            .overlay {
                if isLoading {
                    LoadingScreen()
                }
            }
    }
    
    //Loading screen
    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack{
            Rectangle()
                .fill(.ultraThinMaterial)
            
            ProgressView()
                .frame(width: 45, height: 100)
                .background(.background, in: .rect(cornerRadius: 5))
        }
    }
    ///Presentation Error's
    func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    ///LOGIN with Firebase
    func loginWithFirebase(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            //Showing loading screen until login complete with firebase
            isLoading = true
            
            guard let nonce  else {
                showError("Can not process your request")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                showError("Can not process your request")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showError("Can not process your request")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    showError("Can not process your request")
                }
                
                //Pushing user to Home View
                logStatus = true
                isLoading = false
            }
        }
        
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
