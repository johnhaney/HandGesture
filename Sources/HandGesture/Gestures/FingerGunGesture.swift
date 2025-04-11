//
//  FingerGunGesture.swift
//  HandGesture
//
//  Created by John Haney on 12/2/24.
//

import Foundation
#if canImport(ARKit)
import ARKit
#endif
import RealityKit
import Spatial
import ARUnderstanding

public class FingerGunGesture: HandGesture {
    public struct Value: Equatable, Sendable {
        public let vector: Transform
        public let thumbDown: Bool
    }
    
    var hand: HandAnchor.Chirality

    public init(hand: HandAnchor.Chirality) {
        self.hand = hand
    }

    public func update(with handUpdates: HandTrackingModel.HandsUpdates) -> Value? {
        switch hand {
        case .right:
            guard let rightHand = handUpdates.right,
                let (position, direction) = rightHand.indexFingerTipVector(),
                  let (_, thumbDirection) = rightHand.thumbVector()
            else {
                return nil
            }
            let a = Vector3D.init(direction)
            let r = Rotation3D(forward: a)
            let b = Vector3D.init(thumbDirection)
            return Value(vector: Transform(rotation: simd_quatf(r), translation: position), thumbDown: a.dot(b) > 0.7)
        case .left:
            guard let leftHand = handUpdates.left,
                let (position, direction) = leftHand.indexFingerTipVector(),
                  let (_, thumbDirection) = leftHand.thumbVector()
            else {
                return nil
            }
            let a = Vector3D.init(direction)
            let r = Rotation3D(forward: a)
            let b = Vector3D.init(thumbDirection)
            return Value(vector: Transform(rotation: simd_quatf(r), translation: position), thumbDown: a.dot(b) > 0.7)

        }
    }
}
