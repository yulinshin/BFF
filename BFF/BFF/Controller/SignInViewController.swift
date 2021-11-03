//
//  SignInViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/3.
//

import UIKit
import AuthenticationServices
import FirebaseAuth

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       setupAppleSignInButton()
    }

    func setupAppleSignInButton(){

        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleSignInWithAppleTapped), for: .touchUpInside)
        button.center = view.center
        view.addSubview(button)
        view.backgroundColor = .white

    }

    @objc func handleSignInWithAppleTapped(){
        performAppleSigin()
    }

    func performAppleSigin() {

        let request = creatAppleIDRequest()
        let authorizationContoller = ASAuthorizationController(authorizationRequests: [request])

        authorizationContoller.delegate = self
        authorizationContoller.presentationContextProvider = self
        authorizationContoller.performRequests()

    }

    func creatAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] // Only Get once at first sign in

        let nonce = randomNonceString() // noumber used once
        request.nonce = sha256(nonce)
        currentNonce = nonce

        return request

    }

}

@available(iOS 13.0, *)
extension SignInViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetch identity token")
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase

        Auth.auth().signIn(with: credential) { (authResult, error) in

            if let user = authResult?.user {

                if let fullName = appleIDCredential.fullName,
                let givenName = fullName.givenName,
                   let familyName = fullName.familyName {

                    let displayName = givenName + familyName
                    self.updateDisplayName(displayName: displayName)
                    print ("Suceess signed in as \(user.uid), email:\(user.email), name:\(displayName)")

                }


                let viewController = TabBarController()
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)

            } else {
                print ("Fail To Signed in")
            }
            return
          }
        }
      }


    func updateDisplayName(displayName: String) {
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Set userName to DB Failed")
                }
                else {
                    print("Set userName to DB Success")
                }
            }
        }
    }



    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
      print("Sign in with Apple errored: \(error)")
    }

}


extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

}


// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce

   private func randomNonceString(length: Int = 32) -> String {
     precondition(length > 0)
     let charset: [Character] =
       Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
     var result = ""
     var remainingLength = length

     while remainingLength > 0 {
       let randoms: [UInt8] = (0 ..< 16).map { _ in
         var random: UInt8 = 0
         let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
         if errorCode != errSecSuccess {
           fatalError(
             "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
           )
         }
         return random
       }

       randoms.forEach { random in
         if remainingLength == 0 {
           return
         }

         if random < charset.count {
           result.append(charset[Int(random)])
           remainingLength -= 1
         }
       }
     }

     return result
   }

import CryptoKit
// Unhashed nonce.
fileprivate var currentNonce: String?

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }


