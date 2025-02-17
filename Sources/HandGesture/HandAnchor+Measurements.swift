//
//  HandAnchor+Measurements.swift
//  HandGesture
//
//  Created by John Haney on 11/29/24.
//

import ARUnderstanding
import RealityKit
#if canImport(ARKit)
import ARKit
#endif

// Finger guns (thumb triggers)

// clapping (single clap, double-clap, continued clapping)

// punch (fist, stop after movement)

// karate (need to understand hand movements and develop gestures)

// Spider-Man gesture

public enum SyntheticHandPosition: CaseIterable {
    case insidePalm
}

public extension HandAnchorRepresentable {
    func thumbVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.thumbTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.thumbIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    func indexFingerTipVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.indexFingerTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.indexFingerIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    func middleFingerTipVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.middleFingerTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.middleFingerIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    func ringFingerTipVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.ringFingerTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.ringFingerIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    func littleFingerTipVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.littleFingerTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.littleFingerIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    func position(joint: HandSkeleton.JointName) -> SIMD3<Float>? {
        guard let skeleton = self.handSkeleton else { return nil }
        return Transform(matrix: originFromAnchorTransform * skeleton.joint(joint).anchorFromJointTransform).translation
    }
    
    func position(at position: SyntheticHandPosition) -> SIMD3<Float>? {
        switch position {
        case .insidePalm:
            return insidePalmPosition()
        }
    }
    
    func insidePalmPosition() -> SIMD3<Float>? {
        guard let a = position(joint: .indexFingerKnuckle),
              let b = position(joint: .littleFingerKnuckle),
              let c = position(joint: .indexFingerMetacarpal),
              let d = position(joint: .littleFingerMetacarpal)
        else { return nil }
        let handPalmPosition = (a + b + c + d) / 4.0
        let insideDirection: SIMD3<Float>
        switch chirality {
        case .left:
            insideDirection = normalize(cross(normalize(b - c), normalize(a - d)))
        case .right:
            insideDirection = normalize(cross(normalize(a - d), normalize(b - c)))
        }
        return handPalmPosition + 0.025 * insideDirection
    }
    
    func distanceBetween(_ joint1: HandSkeleton.JointName, _ joint2: HandSkeleton.JointName) -> Float? {
        guard let lhs1 = position(joint: joint1),
              let lhs2 = position(joint: joint2)
        else { return nil }
        return max(0, distance(lhs1, lhs2) - 0.01) // subtract a bit from the distance to try to account for actual thickness of hand/fingers from the joint center
    }
    
    func insideSphere() -> Sphere? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.middleFingerKnuckle).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.thumbTip).anchorFromJointTransform).translation
        let lhs3 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.indexFingerTip).anchorFromJointTransform).translation
        let lhs4 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.littleFingerTip).anchorFromJointTransform).translation
        
        let center: SIMD3<Float>
        let radius: Float
        
        let b = lhs2 - lhs1
        let c = lhs3 - lhs1
        let d = lhs4 - lhs1
        
        let shiftedCenter = (length_squared(b) * cross(c, d) + length_squared(c) * cross(d, b) + length_squared(d) * cross(b, c)) / dot(2 * b, cross(c, d))
        center = lhs1 + shiftedCenter
        radius = length(shiftedCenter)
        
        return Sphere(center: center, radius: radius - 0.01) // subtract from the radius a bit to try to account for the actual thickness of the hand/fingers from the joint center points
    }
}

func distance(_ lhs: SIMD3<Float>, _ rhs: SIMD3<Float>) -> Float {
    sqrt((lhs.x - rhs.x) * (lhs.x - rhs.x) + (lhs.y - rhs.y) * (lhs.y - rhs.y) + (lhs.z - rhs.z) * (lhs.z - rhs.z))
}

func length_squared(_ lhs: SIMD3<Float>) -> Float {
    lhs.x * lhs.x + lhs.y * lhs.y + lhs.z * lhs.z
}

func cross(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> SIMD3<Float> {
    [
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    ]
}
