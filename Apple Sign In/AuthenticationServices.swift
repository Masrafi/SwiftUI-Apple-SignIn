//import Foundation
//import SwiftUI
//import AuthenticationServices
//import CommonCrypto
//
//struct SignInWithAppleView: View {
//    @State private var currentNonce: String?
//
//    var body: some View {
//        VStack {
//            SignInWithAppleButton(.signIn, onRequest: configure, onCompletion: handle)
//                .signInWithAppleButtonStyle(.black)
//                .frame(width: 280, height: 45)
//                .padding()
//        }
//    }
//
//    func configure(_ request: ASAuthorizationAppleIDRequest) {
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = sha256(nonce)
//    }
//
//    func handle(_ result: Result<ASAuthorization, Error>) {
//        switch result {
//        case .success(let authorization):
//            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//                let userIdentifier = appleIDCredential.user
//                let fullName = appleIDCredential.fullName
//                let email = appleIDCredential.email
//
//                // Handle the response here
//                print("User Identifier: \(userIdentifier)")
//                print("User Email: \(String(describing: email))")
//                print("User Full Name: \(String(describing: fullName))")
//            }
//        case .failure(let error):
//            print("Error occurred during Sign in with Apple: \(error.localizedDescription)")
//        }
//    }
//
//    // Generate a random string for the nonce
//    func randomNonceString(length: Int = 32) -> String {
//        let charset: Array<Character> =
//            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//        var result = ""
//        var remainingLength = length
//
//        while remainingLength > 0 {
//            let randoms: [UInt8] = (0 ..< 16).map { _ in
//                var random: UInt8 = 0
//                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
//                if errorCode != errSecSuccess {
//                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
//                }
//                return random
//            }
//
//            randoms.forEach { random in
//                if remainingLength == 0 {
//                    return
//                }
//
//                if random < charset.count {
//                    result.append(charset[Int(random)])
//                    remainingLength -= 1
//                }
//            }
//        }
//
//        return result
//    }
//
//    // Hash the nonce using SHA256 (now using CommonCrypto)
//    func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//        inputData.withUnsafeBytes {
//            _ = CC_SHA256($0.baseAddress, CC_LONG(inputData.count), &hash)
//        }
//        return hash.map { String(format: "%02x", $0) }.joined()
//    }
//}
//
