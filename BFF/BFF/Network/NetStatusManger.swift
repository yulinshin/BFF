//
//  NetStatusManger.swift
//  BFF
//
//  Created by yulin on 2021/11/19.
//

import Network
import NotificationBannerSwift
import UIKit

class CustomBannerColors: BannerColorsProtocol {

    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .warning:
            return UIColor.mainColor
        case .danger:
            return  UIColor.mainColor
        case .info:
            return  UIColor.mainColor
        case .customView:
            return  UIColor.mainColor
        case .success:
            return  UIColor.mainColor
        }
    }

}

class NetStatusManger {

    static var share = NetStatusManger()

    var monitor: NWPathMonitor?
    var isMonitoring = false

    var didStartMonitoringHandler: (() -> Void)?
    var didStopMonitoringHandler: (() -> Void)?
    var netStatusChangeHandler: (() -> Void)?

    // Get connected Status
    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    // Get interFarce type
    var interfaceType: NWInterface.InterfaceType? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.filter {
            monitor.currentPath.usesInterfaceType($0.type) }.first?.type
    }

    // Get availableInterfaces
    var availableInterfacesTypes: [NWInterface.InterfaceType]? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map { $0.type }
    }

    // check if isExpensive Network ( Mobile network)
    var isExpensive: Bool {
        return monitor?.currentPath.isExpensive ?? false
    }

    //    var netWorkBanner = NotificationBanner(title: "無網路連線", subtitle: "請確認您的網路連線" , style: .warning)
    var netWorkBanner = StatusBarNotificationBanner(title: "無網路連線", style: .warning, colors: CustomBannerColors() )

    private init() {

    }

    deinit {
        stopMonitoring() // Make sure Monitor cancel when NetStatusManger DIE
    }

    func startMonitoring() {

        guard !isMonitoring else { return }
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetStatus_Monitor") // Monitor in background thread
        monitor?.start(queue: queue)

        monitor?.pathUpdateHandler = {  [weak self] _ in // Network status change

            self?.netStatusChangeHandler?()
            self?.checkContentStatus()

        }

        isMonitoring = true
        didStartMonitoringHandler?()

    }

    func stopMonitoring() {

        guard isMonitoring, let monitor = monitor else { return }

        monitor.cancel()

        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
        self.netWorkBanner.dismiss()
    }

    func checkContentStatus() {
        DispatchQueue.main.async {
            if !self.isConnected {
                self.netWorkBanner.haptic = .heavy
                self.netWorkBanner.show()
                self.netWorkBanner.autoDismiss = false
            } else {
                self.netWorkBanner.dismiss()
            }
        }
    }
}
