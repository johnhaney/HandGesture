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
    
    public let id: UUID = UUID()
    var hand: HandAnchor.Chirality
    var previous: Fist?

    public init(hand: HandAnchor.Chirality) {
        self.hand = hand
    }

    public func update(with handUpdates: HandTrackingModel.HandsUpdates) -> Value? {
        let value: Value
        switch hand {
        case .right:
            guard let rightHand = handUpdates.right,
                  let fist = rightHand.fistPose() else {
                previous = nil
                return nil
            }
            if let previous {
                value = Value(velocity: (fist.transform.translation - previous.transform.translation) * 60, fist: fist)
            } else {
                value = Value(velocity: .zero, fist: fist)
            }
            previous = fist
        case .left:
            guard let leftHand = handUpdates.left,
                  let fist = leftHand.fistPose() else {
                previous = nil
                return nil
            }
            if let previous {
                value = Value(velocity: (fist.transform.translation - previous.transform.translation) * 60, fist: fist)
            } else {
                value = Value(velocity: .zero, fist: fist)
            }
            previous = fist
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
//            let base = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.indexFingerKnuckle).anchorFromJointTransform).translation
//            let knuckle = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.indexFingerIntermediateBase).anchorFromJointTransform).translation
            let fingerDirection = normalize(lhs3 - lhs2)
            let linear = dot(palmDirection, fingerDirection)
            if linear > 0.3 { return nil }
        }
        
        do {
//            let base = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.ringFingerKnuckle).anchorFromJointTransform).translation
//            let knuckle = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.ringFingerIntermediateBase).anchorFromJointTransform).translation
            let fingerDirection = normalize(lhs3 - lhs2)
            let linear = dot(palmDirection, fingerDirection)
            if linear > 0.3 { return nil }
        }
        
        do {
//            let base = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.littleFingerKnuckle).anchorFromJointTransform).translation
//            let knuckle = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.littleFingerIntermediateBase).anchorFromJointTransform).translation
            let fingerDirection = normalize(lhs3 - lhs2)
            let linear = dot(palmDirection, fingerDirection)
            if linear > 0.3 { return nil }
        }
        
        return Fist(transform: Transform(
            rotation: simd_quatf(Rotation3D(forward: Vector3D(palmDirection))),
            translation: lhs2))
    }
}
