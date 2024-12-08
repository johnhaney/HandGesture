//
//  FingerGunGesture.swift
//  HandGesture
//
//  Created by John Haney on 12/2/24.
//

import Foundation
import ARKit
import RealityKit
import Spatial

public class FingerGunGesture: HandGesture {
    public struct Value: Equatable, Sendable {
        public let vector: Transform
        public let thumbDown: Bool
    }
    
    public let id: UUID = UUID()
    var hand: HandAnchor.Chirality

    public init(hand: HandAnchor.Chirality) {
        self.hand = hand
    }

    public func update(with handUpdates: HandTrackingModel.HandsUpdates) -> Value? {
        switch hand {
        case .right:
            guard let rightHand = handUpdates.right,
                let (position, direction) = rightHand.indexFingerTipVector(),
                  let (thumbPosition, thumbDirection) = rightHand.thumbVector()
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
                  let (thumbPosition, thumbDirection) = leftHand.thumbVector()
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