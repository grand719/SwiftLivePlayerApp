//
//  PlayerView.swift
//  LivePlayerAppliaction
//
//  Created by Łukasz Pawłowski on 30/11/2024.
//

import Foundation
import UIKit
import AVKit

class PlayerView: UIView {
    override class var layerClass: AnyClass{AVPlayerLayer.self}
    
    public var playerViewId: Int = 0;
    
    public var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
        
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
}
