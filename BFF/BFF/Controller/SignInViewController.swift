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

    fileprivate var timer: Timer!
    fileprivate var currentPos:Int = 0
    fileprivate var images:[UIImage] = [UIImage]()
    fileprivate var imageSliderView: ImageSliderView!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackGround()
        setupAppleSignInButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    private func setupBackGround() {

        images.append(UIImage(named: "WellcomPic-1")!)
        images.append(UIImage(named: "WellcomPic-2")!)

        let screen = UIScreen.main.bounds
        let image = images[0]
        let imageWidth =  screen.width
        let imageHeight = screen.height
        let gradientView = UIView(frame:CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        imageSliderView = ImageSliderView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        imageSliderView.setImage(image, animated: false)
        imageSliderView.contentMode = .scaleAspectFill
        view.addSubview(imageSliderView)
        view.addSubview(gradientView)


        let gradient = CAGradientLayer()
        gradient.frame = UIScreen.main.bounds
        gradient.colors = [UIColor.clear, UIColor(named: "main-O")!.cgColor]
        gradient.locations = [0.3, 0.8]
        gradientView.layer.addSublayer(gradient)

        

        // setup timer

        Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(SignInViewController.scaleImageEvent), userInfo: nil, repeats: true)

//        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(SignInViewController.changeImageEvent), userInfo: nil, repeats: true)
//        scaleImageEvent()

    }

    @objc func scaleImageEvent() {
        self.imageSliderView.transform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.animate(withDuration: 3.0, animations: {() -> Void in
            self.imageSliderView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.changeImageEvent()
        })
    }

    @objc func changeImageEvent() {

        // take next image
        if currentPos == 0 {
            imageSliderView.setImage(images[1], animated: true)
            currentPos += 1
            print(currentPos)
        } else {
            imageSliderView.setImage(images[0], animated: true)
            currentPos -= 1
            print(currentPos)
        }
    }

    func setupAppleSignInButton(){

        let titleLabel = UILabel()
        let subTitleLAbel = UILabel()
        let textLable = UILabel()
        let button = ASAuthorizationAppleIDButton.init(type: .signIn, style: .white)
        button.cornerRadius = 20

        button.addTarget(self, action: #selector(handleSignInWithAppleTapped), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLAbel.translatesAutoresizingMaskIntoConstraints = false
        textLable.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLAbel)
        view.addSubview(textLable)

        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36).isActive = true

        titleLabel.bottomAnchor.constraint(equalTo: subTitleLAbel.topAnchor, constant: -10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36).isActive = true

        subTitleLAbel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -80).isActive = true
        subTitleLAbel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36).isActive = true
        subTitleLAbel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36).isActive = true

        textLable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        textLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36).isActive = true
        textLable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36).isActive = true


        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        let title = "BFF PetsDiary"
        let titleAttributes: NSDictionary = [
            NSAttributedString.Key.font:UIFont(name: "GenJyuuGothic-Bold", size: 36),
            NSAttributedString.Key.kern:CGFloat(2)
        ]

        let titleAttributed = NSAttributedString(string: title, attributes:titleAttributes as? [NSAttributedString.Key : Any])
        titleLabel.attributedText = titleAttributed




        subTitleLAbel.textColor = .white
        subTitleLAbel.textAlignment = .center

        let subTitle = "- 開始紀錄毛小孩們的大小事 -"
        let subTitleAttributes: NSDictionary = [
            NSAttributedString.Key.font:UIFont(name: "GenJyuuGothic-Medium", size: 16),
            NSAttributedString.Key.kern:CGFloat(4)
        ]

        let subTitleAttributed = NSAttributedString(string: subTitle, attributes:subTitleAttributes as? [NSAttributedString.Key : Any])
        subTitleLAbel.attributedText = subTitleAttributed

        textLable.textColor = .white
        textLable.textAlignment = .center

        let text = "Best Friend Forver"
        let attributes: NSDictionary = [
            NSAttributedString.Key.font:UIFont(name: "GenJyuuGothic-Medium", size: 10),
            NSAttributedString.Key.kern:CGFloat(10)
        ]

        let attributedTitle = NSAttributedString(string: text, attributes:attributes as? [NSAttributedString.Key : Any])

        textLable.attributedText = attributedTitle


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


