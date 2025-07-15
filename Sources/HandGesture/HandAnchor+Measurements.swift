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
import Spatial
import SwiftUI
import simd

// Finger guns (thumb triggers)

// clapping (single clap, double-clap, continued clapping)

// punch (fist, stop after movement)

// karate (need to understand hand movements and develop gestures)

// Spider-Man gesture

public enum SyntheticHandPosition: CaseIterable {
    case insidePalm
}

public extension HandAnchorRepresentable {
    public var palmDirection: SIMD3<Float> { [0,0,0] }
    
    public var wristLeftRight: Angle {
        computeAngles().leftRight
    }

    public var wristInOut: Angle {
        computeAngles().inOut
    }

    private func computeAngles() -> (leftRight: Angle, inOut: Angle) {
        guard let forearm = position(joint: .forearmWrist),
              let wrist = position(joint: .wrist),
              let index = position(joint: .indexFingerKnuckle),
              let little = position(joint: .littleFingerKnuckle)
        else {
            return (.zero, .zero)
        }

        // Palm plane and normal
        let palmRight = normalize(index - wrist)
        let palmLeft = normalize(little - wrist)

        // Normal direction from wrist to palm plane
        let normalToPalm: SIMD3<Float>
        switch chirality {
        case .left:
            normalToPalm = normalize(cross(palmLeft, palmRight))
        case .right:
            normalToPalm = normalize(cross(palmRight, palmLeft))
        }

        // Wrist direction vector
        let forearmDirection = normalize(wrist - forearm)

        // Project forearm vector onto palm's axes
        let leftRightAmount = dot(forearmDirection, normalize(index - little)) // sideways across palm
        let inOutAmount = dot(forearmDirection, normalToPalm) // in/out of palm

        // Convert to angles in degrees
        let leftRightAngle = Angle(radians: Double(asinf(leftRightAmount)))
        let inOutAngle = Angle(radians: Double(asinf(inOutAmount)))

        return (leftRight: leftRightAngle, inOut: inOutAngle)
    }
    
    public func thumbCurl() -> Angle {
        guard let thumbTip = position(joint: .thumbTip),
              let thumbIntermediateTip = position(joint: .thumbIntermediateTip),
              let thumbIntermediateBase = position(joint: .thumbIntermediateBase),
              let thumbKnuckle = position(joint: .thumbKnuckle)
        else { return .zero }
        
        let vector1 = normalize(thumbTip - thumbIntermediateTip)
        let vector2 = normalize(thumbIntermediateTip - thumbIntermediateBase)
        let vector3 = normalize(thumbIntermediateBase - thumbKnuckle)
        
        let angle1 = acos(dot(vector1, vector2))
        let angle2 = acos(dot(vector2, vector3))
        
        return Angle.radians(Double(angle1 + angle2)/2)
    }
    
    public func thumbTipBend() -> Angle {
        guard let thumbTip = position(joint: .thumbTip),
              let thumbIntermediateTip = position(joint: .thumbIntermediateTip),
              let thumbIntermediateBase = position(joint: .thumbIntermediateBase)
        else { return .zero }

        let vector1 = normalize(thumbTip - thumbIntermediateTip)
        let vector2 = normalize(thumbIntermediateTip - thumbIntermediateBase)
        
        let angle1 = acos(dot(vector1, vector2))
        return Angle.radians(Double(angle1))
    }
    
    public func thumbIntermediateBend() -> Angle {
        guard let thumbIntermediateTip = position(joint: .thumbIntermediateTip),
              let thumbIntermediateBase = position(joint: .thumbIntermediateBase),
                let thumbKnuckle = position(joint: .thumbKnuckle)
        else { return .zero }

        let vector2 = normalize(thumbIntermediateTip - thumbIntermediateBase)
        let vector3 = normalize(thumbIntermediateBase - thumbKnuckle)

        let angle2 = acos(dot(vector2, vector3))

        return Angle.radians(Double(angle2))
    }
    
    public func thumbBaseBend() -> Angle {
        guard let thumbIntermediateBase = position(joint: .thumbIntermediateBase),
              let thumbKnuckle = position(joint: .thumbKnuckle),
              let wrist = position(joint: .forearmWrist),
              let arm = position(joint: .forearmArm)
        else { return .zero }

        let vector3 = normalize(thumbIntermediateBase - thumbKnuckle)
        let vector4 = normalize(wrist - arm)

        let angle3 = acos(dot(vector3, vector4))

        return Angle.radians(Double(angle3))
    }
    
    public func indexCurl() -> Angle {
        guard let indexTip = position(joint: .indexFingerTip),
              let indexIntermediateTip = position(joint: .indexFingerIntermediateTip),
              let indexIntermediateBase = position(joint: .indexFingerIntermediateBase),
              let indexKnuckle = position(joint: .indexFingerKnuckle),
              let indexMetacarpal = position(joint: .indexFingerMetacarpal)
        else { return .zero }
        
        let vector1 = normalize(indexTip - indexIntermediateTip)
        let vector2 = normalize(indexIntermediateTip - indexIntermediateBase)
        let vector3 = normalize(indexIntermediateBase - indexKnuckle)
        let vector4 = normalize(indexKnuckle - indexMetacarpal)
        
        let angle1 = acos(dot(vector1, vector2))
        let angle2 = acos(dot(vector2, vector3))
        let angle3 = acos(dot(vector3, vector4))
        
        return Angle.radians(Double(angle1 + angle2 + angle3)/3)
    }

    public func indexTipBend() -> Angle {
        guard let indexTip = position(joint: .indexFingerTip),
              let indexIntermediateTip = position(joint: .indexFingerIntermediateTip),
              let indexIntermediateBase = position(joint: .indexFingerIntermediateBase)
        else { return .zero }

        let vector1 = normalize(indexTip - indexIntermediateTip)
        let vector2 = normalize(indexIntermediateTip - indexIntermediateBase)

        let angle1 = acos(dot(vector1, vector2))
        return Angle.radians(Double(angle1))
    }
    
    public func indexIntermediateBend() -> Angle {
        guard let indexIntermediateTip = position(joint: .indexFingerIntermediateTip),
              let indexIntermediateBase = position(joint: .indexFingerIntermediateBase),
              let indexKnuckle = position(joint: .indexFingerKnuckle)
        else { return .zero }

        let vector2 = normalize(indexIntermediateTip - indexIntermediateBase)
        let vector3 = normalize(indexIntermediateBase - indexKnuckle)

        let angle2 = acos(dot(vector2, vector3))

        return Angle.radians(Double(angle2))
    }
    
    public func indexBaseBend() -> Angle {
        guard let indexIntermediateBase = position(joint: .indexFingerIntermediateBase),
              let indexKnuckle = position(joint: .indexFingerKnuckle),
              let indexMetacarpal = position(joint: .indexFingerMetacarpal)
        else { return .zero }

        let vector3 = normalize(indexIntermediateBase - indexKnuckle)
        let vector4 = normalize(indexKnuckle - indexMetacarpal)

        let angle3 = acos(dot(vector3, vector4))

        return Angle.radians(Double(angle3))
    }
    
    public func indexMetacarpalBend() -> Angle {
        guard let indexKnuckle = position(joint: .indexFingerKnuckle),
              let indexMetacarpal = position(joint: .indexFingerMetacarpal),
              let wrist = position(joint: .forearmWrist),
              let arm = position(joint: .forearmArm)
        else { return .zero }

        let vector4 = normalize(indexKnuckle - indexMetacarpal)
        let vector5 = normalize(wrist - arm)

        let angle4 = acos(dot(vector4, vector5))

        return Angle.radians(Double(angle4))
    }
    
    public func middleCurl() -> Angle {
        guard let middleTip = position(joint: .middleFingerTip),
              let middleIntermediateTip = position(joint: .middleFingerIntermediateTip),
              let middleIntermediateBase = position(joint: .middleFingerIntermediateBase),
              let middleKnuckle = position(joint: .middleFingerKnuckle),
              let middleMetacarpal = position(joint: .middleFingerMetacarpal)
        else { return .zero }
        
        let vector1 = normalize(middleTip - middleIntermediateTip)
        let vector2 = normalize(middleIntermediateTip - middleIntermediateBase)
        let vector3 = normalize(middleIntermediateBase - middleKnuckle)
        let vector4 = normalize(middleKnuckle - middleMetacarpal)
        
        let angle1 = acos(dot(vector1, vector2))
        let angle2 = acos(dot(vector2, vector3))
        let angle3 = acos(dot(vector3, vector4))
        
        return Angle.radians(Double(angle1 + angle2 + angle3)/3)
    }
    
    public func middleTipBend() -> Angle {
        guard let middleTip = position(joint: .middleFingerTip),
              let middleIntermediateTip = position(joint: .middleFingerIntermediateTip),
              let middleIntermediateBase = position(joint: .middleFingerIntermediateBase)
        else { return .zero }

        let vector1 = normalize(middleTip - middleIntermediateTip)
        let vector2 = normalize(middleIntermediateTip - middleIntermediateBase)

        let angle1 = acos(dot(vector1, vector2))
        return Angle.radians(Double(angle1))
    }
    
    public func middleIntermediateBend() -> Angle {
        guard let middleIntermediateTip = position(joint: .middleFingerIntermediateTip),
              let middleIntermediateBase = position(joint: .middleFingerIntermediateBase),
              let middleKnuckle = position(joint: .middleFingerKnuckle)
        else { return .zero }

        let vector2 = normalize(middleIntermediateTip - middleIntermediateBase)
        let vector3 = normalize(middleIntermediateBase - middleKnuckle)

        let angle2 = acos(dot(vector2, vector3))

        return Angle.radians(Double(angle2))
    }
    
    public func middleBaseBend() -> Angle {
        guard let middleIntermediateBase = position(joint: .middleFingerIntermediateBase),
              let middleKnuckle = position(joint: .middleFingerKnuckle),
              let middleMetacarpal = position(joint: .middleFingerMetacarpal)
        else { return .zero }

        let vector3 = normalize(middleIntermediateBase - middleKnuckle)
        let vector4 = normalize(middleKnuckle - middleMetacarpal)

        let angle3 = acos(dot(vector3, vector4))

        return Angle.radians(Double(angle3))
    }
    
    public func middleMetacarpalBend() -> Angle {
        guard let middleKnuckle = position(joint: .middleFingerKnuckle),
              let middleMetacarpal = position(joint: .middleFingerMetacarpal),
              let wrist = position(joint: .forearmWrist),
              let arm = position(joint: .forearmArm)
        else { return .zero }

        let vector4 = normalize(middleKnuckle - middleMetacarpal)
        let vector5 = normalize(wrist - arm)

        let angle4 = acos(dot(vector4, vector5))

        return Angle.radians(Double(angle4))
    }

    public func ringCurl() -> Angle {
        guard let ringTip = position(joint: .ringFingerTip),
              let ringIntermediateTip = position(joint: .ringFingerIntermediateTip),
              let ringIntermediateBase = position(joint: .ringFingerIntermediateBase),
              let ringKnuckle = position(joint: .ringFingerKnuckle),
              let ringMetacarpal = position(joint: .ringFingerMetacarpal)
        else { return .zero }
        
        let vector1 = normalize(ringTip - ringIntermediateTip)
        let vector2 = normalize(ringIntermediateTip - ringIntermediateBase)
        let vector3 = normalize(ringIntermediateBase - ringKnuckle)
        let vector4 = normalize(ringKnuckle - ringMetacarpal)
        
        let angle1 = acos(dot(vector1, vector2))
        let angle2 = acos(dot(vector2, vector3))
        let angle3 = acos(dot(vector3, vector4))
        
        return Angle.radians(Double(angle1 + angle2 + angle3)/3)
    }

    public func ringTipBend() -> Angle {
        guard let ringTip = position(joint: .ringFingerTip),
              let ringIntermediateTip = position(joint: .ringFingerIntermediateTip),
              let ringIntermediateBase = position(joint: .ringFingerIntermediateBase)
        else { return .zero }

        let vector1 = normalize(ringTip - ringIntermediateTip)
        let vector2 = normalize(ringIntermediateTip - ringIntermediateBase)

        let angle1 = acos(dot(vector1, vector2))
        return Angle.radians(Double(angle1))
    }
    
    public func ringIntermediateBend() -> Angle {
        guard let ringIntermediateTip = position(joint: .ringFingerIntermediateTip),
              let ringIntermediateBase = position(joint: .ringFingerIntermediateBase),
              let ringKnuckle = position(joint: .ringFingerKnuckle)
        else { return .zero }

        let vector2 = normalize(ringIntermediateTip - ringIntermediateBase)
        let vector3 = normalize(ringIntermediateBase - ringKnuckle)

        let angle2 = acos(dot(vector2, vector3))

        return Angle.radians(Double(angle2))
    }
    
    public func ringBaseBend() -> Angle {
        guard let ringIntermediateBase = position(joint: .ringFingerIntermediateBase),
              let ringKnuckle = position(joint: .ringFingerKnuckle),
              let ringMetacarpal = position(joint: .ringFingerMetacarpal)
        else { return .zero }

        let vector3 = normalize(ringIntermediateBase - ringKnuckle)
        let vector4 = normalize(ringKnuckle - ringMetacarpal)

        let angle3 = acos(dot(vector3, vector4))

        return Angle.radians(Double(angle3))
    }
    
    public func ringMetacarpalBend() -> Angle {
        guard let ringKnuckle = position(joint: .ringFingerKnuckle),
              let ringMetacarpal = position(joint: .ringFingerMetacarpal),
              let wrist = position(joint: .forearmWrist),
              let arm = position(joint: .forearmArm)
        else { return .zero }

        let vector4 = normalize(ringKnuckle - ringMetacarpal)
        let vector5 = normalize(wrist - arm)

        let angle4 = acos(dot(vector4, vector5))

        return Angle.radians(Double(angle4))
    }
    
    public func littleCurl() -> Angle {
        guard let littleTip = position(joint: .littleFingerTip),
              let littleIntermediateTip = position(joint: .littleFingerIntermediateTip),
              let littleIntermediateBase = position(joint: .littleFingerIntermediateBase),
              let littleKnuckle = position(joint: .littleFingerKnuckle),
              let littleMetacarpal = position(joint: .littleFingerMetacarpal)
        else { return .zero }
        
        let vector1 = normalize(littleTip - littleIntermediateTip)
        let vector2 = normalize(littleIntermediateTip - littleIntermediateBase)
        let vector3 = normalize(littleIntermediateBase - littleKnuckle)
        let vector4 = normalize(littleKnuckle - littleMetacarpal)
        
        let angle1 = acos(dot(vector1, vector2))
        let angle2 = acos(dot(vector2, vector3))
        let angle3 = acos(dot(vector3, vector4))
        
        return Angle.radians(Double(angle1 + angle2 + angle3)/3)
    }

    public func littleTipBend() -> Angle {
        guard let littleTip = position(joint: .littleFingerTip),
              let littleIntermediateTip = position(joint: .littleFingerIntermediateTip),
              let littleIntermediateBase = position(joint: .littleFingerIntermediateBase)
        else { return .zero }

        let vector1 = normalize(littleTip - littleIntermediateTip)
        let vector2 = normalize(littleIntermediateTip - littleIntermediateBase)

        let angle1 = acos(dot(vector1, vector2))
        return Angle.radians(Double(angle1))
    }
    
    public func littleIntermediateBend() -> Angle {
        guard let littleIntermediateTip = position(joint: .littleFingerIntermediateTip),
              let littleIntermediateBase = position(joint: .littleFingerIntermediateBase),
              let littleKnuckle = position(joint: .littleFingerKnuckle)
        else { return .zero }

        let vector2 = normalize(littleIntermediateTip - littleIntermediateBase)
        let vector3 = normalize(littleIntermediateBase - littleKnuckle)

        let angle2 = acos(dot(vector2, vector3))

        return Angle.radians(Double(angle2))
    }
    
    public func littleBaseBend() -> Angle {
        guard let littleIntermediateBase = position(joint: .littleFingerIntermediateBase),
              let littleKnuckle = position(joint: .littleFingerKnuckle),
              let littleMetacarpal = position(joint: .littleFingerMetacarpal)
        else { return .zero }

        let vector3 = normalize(littleIntermediateBase - littleKnuckle)
        let vector4 = normalize(littleKnuckle - littleMetacarpal)

        let angle3 = acos(dot(vector3, vector4))

        return Angle.radians(Double(angle3))
    }
    
    public func littleMetacarpalBend() -> Angle {
        guard let littleKnuckle = position(joint: .littleFingerKnuckle),
              let littleMetacarpal = position(joint: .littleFingerMetacarpal),
              let wrist = position(joint: .forearmWrist),
              let arm = position(joint: .forearmArm)
        else { return .zero }

        let vector4 = normalize(littleKnuckle - littleMetacarpal)
        let vector5 = normalize(wrist - arm)

        let angle4 = acos(dot(vector4, vector5))

        return Angle.radians(Double(angle4))
    }

    public func thumbIndexAngle() -> Angle {
        guard let thumbTip = position(joint: .thumbTip),
              let thumbKnuckle = position(joint: .thumbKnuckle),
              let indexTip = position(joint: .indexFingerTip),
              let indexKnuckle = position(joint: .indexFingerKnuckle)
        else { return .zero }
        
        let vector1 = normalize(thumbTip - thumbKnuckle)
        let vector2 = normalize(indexTip - indexKnuckle)
        
        return Angle.radians(Double(acos(dot(vector1, vector2))))
    }

    public func indexMiddleAngle() -> Angle {
        guard let indexTip = position(joint: .indexFingerTip),
              let indexKnuckle = position(joint: .indexFingerKnuckle),
              let middleTip = position(joint: .middleFingerTip),
              let middleKnuckle = position(joint: .middleFingerKnuckle)
        else { return .zero }
        
        let vector1 = normalize(indexTip - indexKnuckle)
        let vector2 = normalize(middleTip - middleKnuckle)
        
        return Angle.radians(Double(acos(dot(vector1, vector2))))
    }

    public func middleRingAngle() -> Angle {
        guard let middleTip = position(joint: .middleFingerTip),
              let middleKnuckle = position(joint: .middleFingerKnuckle),
              let ringTip = position(joint: .ringFingerTip),
              let ringKnuckle = position(joint: .ringFingerKnuckle)
        else { return .zero }
        
        let vector1 = normalize(middleTip - middleKnuckle)
        let vector2 = normalize(ringTip - ringKnuckle)
        
        return Angle.radians(Double(acos(dot(vector1, vector2))))
    }

    public func ringLittleAngle() -> Angle {
        guard let ringTip = position(joint: .ringFingerTip),
              let ringKnuckle = position(joint: .ringFingerKnuckle),
              let littleTip = position(joint: .littleFingerTip),
              let littleKnuckle = position(joint: .littleFingerKnuckle)
        else { return .zero }
        
        let vector1 = normalize(ringTip - ringKnuckle)
        let vector2 = normalize(littleTip - littleKnuckle)
        
        return Angle.radians(Double(acos(dot(vector1, vector2))))
    }

    public func thumbVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.thumbTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.thumbIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    public func indexFingerTipVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.indexFingerTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.indexFingerIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    public func middleFingerTipVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.middleFingerTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.middleFingerIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    public func ringFingerTipVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.ringFingerTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.ringFingerIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    public func littleFingerTipVector() -> (SIMD3<Float>, SIMD3<Float>)? {
        guard let skeleton = self.handSkeleton else { return nil }
        
        let lhs1 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.littleFingerTip).anchorFromJointTransform).translation
        let lhs2 = Transform(matrix: originFromAnchorTransform * skeleton.joint(HandSkeleton.JointName.littleFingerIntermediateTip).anchorFromJointTransform).translation
        
        let direction = normalize(lhs1 - lhs2)
        let origin = lhs1 + 0.005 * direction
        
        return (origin, direction)
    }
    
    public func position(joint: HandSkeleton.JointName) -> SIMD3<Float>? {
        guard let skeleton = self.handSkeleton else { return nil }
        return Transform(matrix: originFromAnchorTransform * skeleton.joint(joint).anchorFromJointTransform).translation
    }
    
    public func position(at position: SyntheticHandPosition) -> SIMD3<Float>? {
        switch position {
        case .insidePalm:
            return insidePalmPosition()
        }
    }
    
    public func insidePalmPosition() -> SIMD3<Float>? {
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
    
    public func distanceBetween(_ joint1: HandSkeleton.JointName, _ joint2: HandSkeleton.JointName) -> Float? {
        guard let lhs1 = position(joint: joint1),
              let lhs2 = position(joint: joint2)
        else { return nil }
        return max(0, distance(lhs1, lhs2) - 0.01) // subtract a bit from the distance to try to account for actual thickness of hand/fingers from the joint center
    }
    
    public func insideSphere() -> Sphere? {
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

public func distance(_ lhs: SIMD3<Float>, _ rhs: SIMD3<Float>) -> Float {
    sqrt((lhs.x - rhs.x) * (lhs.x - rhs.x) + (lhs.y - rhs.y) * (lhs.y - rhs.y) + (lhs.z - rhs.z) * (lhs.z - rhs.z))
}

public func length_squared(_ lhs: SIMD3<Float>) -> Float {
    lhs.x * lhs.x + lhs.y * lhs.y + lhs.z * lhs.z
}
