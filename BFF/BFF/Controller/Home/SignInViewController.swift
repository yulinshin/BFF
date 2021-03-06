//
//  SignInViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/3.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import SafariServices

class SignInViewController: UIViewController {

    fileprivate var timer: Timer!
    fileprivate var currentPos: Int = 0
    fileprivate var images: [UIImage] = [UIImage]()
    fileprivate var imageSliderView: ImageSliderView!
    fileprivate var termLabel = UILabel()

    let termText = "註冊等同於接受隱私權政策與Apple標準許可協議"
    let policy = "隱私權政策"
    let eula = "Apple標準許可協議"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackGround()
        setupAppleSignInButton()
        setupPrivacyLabel()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if Auth.auth().currentUser != nil {

            let viewController = TabBarController()
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)

        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        timer.invalidate()
        timer = nil

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(SignInViewController.scaleImageEvent), userInfo: nil, repeats: true)
    }

    deinit {
        print("SigInViewController DIE")
    }

    private func setupBackGround() {

        images.append(UIImage(named: "WellcomePic-1")!)
        images.append(UIImage(named: "WellcomePic-2")!)

        let screen = UIScreen.main.bounds
        let image = images[0]
        let imageWidth =  screen.width
        let imageHeight = screen.height
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
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

    private func setupPrivacyLabel() {

        let formattedText = String.format(strings: [policy, eula],
                                          boldFont: UIFont.boldSystemFont(ofSize: 12),
                                          boldColor: UIColor.blue,
                                          inString: termText,
                                          font: UIFont.systemFont(ofSize: 12),
                                          color: UIColor.white)

        termLabel.attributedText = formattedText
        termLabel.numberOfLines = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermTapped))
        termLabel.addGestureRecognizer(tap)
        termLabel.isUserInteractionEnabled = true
        termLabel.textAlignment = .center

    }

    @objc func handleTermTapped(gesture: UITapGestureRecognizer) {
        let termString = termText as NSString
        let policyRange = termString.range(of: policy)
        let eulaRange = termString.range(of: eula)

        let tapLocation = gesture.location(in: termLabel)
        let index = termLabel.indexOfAttributedTextCharacterAtPoint(point: tapLocation)

        if checkRange(policyRange, contain: index) {
            handleViewPrivacy()
            return
        }
        if checkRange(eulaRange, contain: index) {
            handleViewEula()
            return
        }
    }

    private func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }

    // swiftlint:disable:next function_body_length
    private func setupAppleSignInButton() {

        let titleLabel = UILabel()
        let subTitleLAbel = UILabel()
        let textLabel = UILabel()
        let button = ASAuthorizationAppleIDButton.init(type: .signIn, style: .white)

        view.addSubview(button)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLAbel)
        view.addSubview(textLabel)
        view.addSubview(termLabel)

        button.cornerRadius = 20
        button.addTarget(self, action: #selector(handleSignInWithAppleTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLAbel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        termLabel.translatesAutoresizingMaskIntoConstraints = false

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

        textLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36).isActive = true

        termLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10).isActive = true
        termLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36).isActive = true
        termLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36).isActive = true
        termLabel.textAlignment = .center

        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        let title = "BFF PetsDiary"
        let titleAttributes: NSDictionary = [
            NSAttributedString.Key.font: UIFont.titleBold36,
            NSAttributedString.Key.kern: CGFloat(2)
        ]

        let titleAttributed = NSAttributedString(string: title, attributes: titleAttributes as? [NSAttributedString.Key: Any])
        titleLabel.attributedText = titleAttributed

        subTitleLAbel.textColor = .white
        subTitleLAbel.textAlignment = .center

        let subTitle = "- 開始紀錄毛小孩們的大小事 -"
        let subTitleAttributes: NSDictionary = [
            NSAttributedString.Key.font: UIFont.titleMedium16,
            NSAttributedString.Key.kern: CGFloat(4)
        ]

        let subTitleAttributed = NSAttributedString(string: subTitle, attributes: subTitleAttributes as? [NSAttributedString.Key: Any])
        subTitleLAbel.attributedText = subTitleAttributed

        textLabel.textColor = .white
        textLabel.textAlignment = .center

        let text = "Best Friend Forever"
        let attributes: NSDictionary = [
            NSAttributedString.Key.font: UIFont.textMedium10,
            NSAttributedString.Key.kern: CGFloat(10)
        ]

        let attributedTitle = NSAttributedString(string: text, attributes: attributes as? [NSAttributedString.Key: Any])
        textLabel.attributedText = attributedTitle

        view.backgroundColor = .white

    }

    @objc func handleSignInWithAppleTapped() {
        performAppleSignin()
    }

    private func performAppleSignin() {

        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()

    }

    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let nonce = randomNonceString()
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

                if (authResult?.user) != nil {

                    if let fullName = appleIDCredential.fullName,
                       let givenName = fullName.givenName,
                       let familyName = fullName.familyName {

                        let displayName = givenName + familyName
                        self.updateDisplayName(displayName: displayName) { result in

                            switch result {

                            case.success(let name):
                                print("Success \(name)")
                                FirebaseManager.shared.createUser()

                            case .failure(let error):
                                print(error)
                            }
                        }
                    }

                    let viewController = TabBarController()
                    viewController.modalPresentationStyle = .fullScreen
                    self.view.window?.rootViewController = viewController
                    self.view.window?.makeKeyAndVisible()
                } else {

                    print("Fail To Signed in")

                }
                return
            }
        }
    }

    private  func updateDisplayName(displayName: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Set userName to DB Failed")
                    completion(.failure(error))
                } else {
                    completion(.success(Auth.auth().currentUser?.displayName ?? ""))
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
private var currentNonce: String?

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    return hashString
}

extension SignInViewController: SFSafariViewControllerDelegate {

    private func  handleViewPrivacy() {

        guard let url = URL(string: "https://www.privacypolicies.com/live/401e5c9d-df2d-42b9-b5e2-33f1f04f6dea") else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredBarTintColor = .black
        safariVC.preferredControlTintColor = .white
        safariVC.dismissButtonStyle = .close
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)

    }

    private func  handleViewEula() {

        guard let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredBarTintColor = .black
        safariVC.preferredControlTintColor = .white
        safariVC.dismissButtonStyle = .close
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)

    }
}
