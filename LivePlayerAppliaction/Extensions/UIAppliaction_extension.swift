//
//  UIAppliaction_extension.swift
//  LivePlayerAppliaction
//
//  Created by Łukasz Pawłowski on 14/12/2024.
//

import UIKit

extension UIApplication {
    var isLandscape: Bool {
        if UIDevice.current.orientation == .unknown {
            if let orientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.windowScene?.interfaceOrientation {
                if orientation == .landscapeLeft || orientation == .landscapeRight {
                    return true
                }
            }
        }
        return UIDevice.current.orientation.isLandscape
    }
}
