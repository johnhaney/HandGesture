//
//  ClapGesture.swift
//  HandGesture
//
//  Created by John Haney on 12/5/24.
//

import Foundation
import ARUnderstanding
import ARKit
import RealityKit
import Spatial

public class ClapGesture: HandGesture {
    public struct Value : Equatable, Sendable {
        public let transform: Transform
        public let intensity: Float
    }
    
    public init() {}
    
    public let id: UUID = UUID()
    
    public func update(with handUpdates: HandTrackingModel.HandsUpdates) -> Value? {
        if let leftHand = handUpdates.left,
           let rightHand = handUpdates.right,
           leftHand.isClapping(rightHand),
           let left1 = leftHand.position(joint: .middleFingerKnuckle),
           let left2 = leftHand.position(joint: .middleFingerMetacarpal),
           let right1 = rightHand.position(joint: .middleFingerKnuckle),
           let right2 = rightHand.position(joint: .middleFingerMetacarpal) {
            return Value(transform: Transform(rotation: simd_quatf(Rotation3D(forward: Vector3D((left1 - left2) + (right1 - right2)))), translation: (left1 + right1) / 2), intensity: 1)
        }
        return nil
    }
}

extension HandAnchorRepresentable {
    func isClapping(_ otherHand: any HandAnchorRepresentable) -> Bool {
        guard let leftPalm = self.position(at: .insidePalm),
              let rightPalm = otherHand.position(at: .insidePalm)
        else {
            return false
        }
        
        print("distance: \(distance(leftPalm, rightPalm))")
        return distance(leftPalm, rightPalm) <= 0.03
    }
}