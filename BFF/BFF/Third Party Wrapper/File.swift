//
//  JGProgressHUD.swift
//  BFF
//
//  Created by yulin on 2021/10/23.
//

import JGProgressHUD

extension UIViewController {
static func getLastPresentedViewController() -> UIViewController? {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        let window = sceneDelegate?.window
        var presentedViewController = window?.rootViewController
        while presentedViewController?.presentedViewController != nil {
            presentedViewController = presentedViewController?.presentedViewController
        }
        return presentedViewController
    }
}

enum HUDType {

    case success(String)

    case failure(String)
}

class ProgressHUD {

    static let shared = ProgressHUD()

    private init() { }

    let hud = JGProgressHUD(style: .dark)

    var view: UIView {

        guard let view = UIViewController.getLastPresentedViewController()?.view else { return UIView() }

        return view
    }

    static func show(type: HUDType) {

        switch type {

        case .success(let text):

            showSuccess(text: text)

        case .failure(let text):

            showFailure(text: text)
        }
    }

    static func showSuccess(text: String = "success") {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                showSuccess(text: text)
            }

            return
        }

        shared.hud.textLabel.text = text

        shared.hud.indicatorView = JGProgressHUDSuccessIndicatorView()

        shared.hud.show(in: shared.view)

        shared.hud.dismiss(afterDelay: 1.5)
    }

    static func showFailure(text: String = "Failure") {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                showFailure(text: text)
            }

            return
        }

        shared.hud.textLabel.text = text

        shared.hud.indicatorView = JGProgressHUDErrorIndicatorView()

        shared.hud.show(in: shared.view)

        shared.hud.dismiss(afterDelay: 1.5)
    }

    static func show() {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                show()
            }

            return
        }

        shared.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()

        shared.hud.textLabel.text = "Loading"

        shared.hud.show(in: shared.view)
    }

    static func dismiss() {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                dismiss()
            }

            return
        }

        shared.hud.dismiss(afterDelay: 2)
    }
}
