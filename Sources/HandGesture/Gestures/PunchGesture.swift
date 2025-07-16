//
//  PunchGesture.swift
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

public class PunchGesture: HandGesture {
    public struct Value: Equatable, Sendable {
        public var velocity: SIMD3<Float>
        public var fist: Fist
    }
    
    var hand: HandAnchor.Chirality
    var previous: Value?

    public init(hand: HandAnchor.Chirality) {
        self.hand = hand
    }

    public func update(with handUpdates: HandTrackingModel.HandsUpdates) -> Value? {
        let value: Value
        switch hand {
        case .right:
            guard let rightHand = handUpdates.right else {
                return previous
            }
            if #available(visionOS 26.0, *) {
                guard rightHand.fidelity == .high else {
                    return previous
                }
            }
            guard let fist = rightHand.fistPose() else {
                previous = nil
                return nil
            }
            if let previous {
                value = Value(velocity: (fist.transform.translation - previous.fist.transform.translation) * 60, fist: fist)
            } else {
                value = Value(velocity: .zero, fist: fist)
            }
            previous = value
        case .left:
            guard let leftHand = handUpdates.left else {
                return previous
            }
            if #available(visionOS 26.0, *) {
                guard leftHand.fidelity == .high else {
                    return previous
                }
            }
            guard let fist = leftHand.fistPose() else {
                previous = nil
                return nil
            }
            if let previous {
                value = Value(velocity: (fist.transform.translation - previous.fist.transform.translation) * 60, fist: fist)
            } else {
                value = Value(velocity: .zero, fist: fist)
            }
            previous = value
        }
        return value
    }
}

public struct Fist: Equatable, Sendable {
    public let transform: Transform
}

extension HandAnchorRepresentable {
    func fistPose() -> Fist? {
        guard let skeleton = self.handSkeleton else { return nil }
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.middleFingerMetacarpal).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.middleFingerKnuckle).anchorFromJointTransform).translation
        let lhs3 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.middleFingerIntermediateBase).anchorFromJointTransform).translation

        let palmDirection = normalize(lhs2 - lhs1)
        
        do {
            let fingerDirection = normalize(lhs3 - lhs2)
            let linear = dot(palmDirection, fingerDirection)
            if linear > 0.3 { return nil }
        }
        
        do {
            let fingerDirection = normalize(lhs3 - lhs2)
            let linear = dot(palmDirection, fingerDirection)
            if linear > 0.3 { return nil }
        }
        
        do {
            let fingerDirection = normalize(lhs3 - lhs2)
            let linear = dot(palmDirection, fingerDirection)
            if linear > 0.3 { return nil }
        }
        
        do {
            let fingerDirection = normalize(lhs3 - lhs2)
            let linear = dot(palmDirection, fingerDirection)
            if linear > 0.3 { return nil }
        }
        
        return Fist(transform: Transform(
            rotation: simd_quatf(Rotation3D(forward: Vector3D(palmDirection))),
            translation: lhs2))
    }
}
