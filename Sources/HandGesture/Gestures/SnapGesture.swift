//
//  SnapGesture.swift
//  HandGesture
//
//  Created by John Haney on 12/2/24.
//

import Foundation
#if canImport(ARKit)
import ARKit
#endif
import ARUnderstanding

public class SnapGesture: HandGesture {
    public struct Value : Equatable, Sendable {
        public let pose: SnapPose
        public let chirality: HandAnchor.Chirality
    }
    
    var hand: HandAnchor.Chirality
    var maximumSnapTime: TimeInterval = 0.5
    var lastPreSnap: Date? = nil
    
    public enum SnapPose: Equatable, Sendable {
        case noSnap
        case preSnap
        case postSnap
    }
    
    public init(hand: HandAnchor.Chirality) {
        self.hand = hand
    }
    
    public func update(with handUpdates: HandTrackingModel.HandsUpdates) -> Value? {
        switch hand {
        case .right:
            if let rightHand = handUpdates.right,
               let snapPose = rightHand.snapPose() {
                let value: Value?
                switch snapPose {
                case .noSnap:
                    value = .init(pose: .noSnap, chirality: hand)
                case .preSnap:
                    lastPreSnap = Date()
                    value = .init(pose: .preSnap, chirality: hand)
                case .postSnap:
                    if let preSnap = lastPreSnap,
                       -preSnap.timeIntervalSinceNow <= maximumSnapTime {
                        lastPreSnap = nil
                        value = .init(pose: .postSnap, chirality: hand)
                    } else {
                        value = nil
                    }
                }
                return value
            }
        case .left:
            if let leftHand = handUpdates.left,
               let snapPose = leftHand.snapPose() {
                let value: Value?
                switch snapPose {
                case .noSnap:
                    value = .init(pose: .noSnap, chirality: hand)
                case .preSnap:
                    lastPreSnap = Date()
                    value = .init(pose: .preSnap, chirality: hand)
                case .postSnap:
                    if let preSnap = lastPreSnap,
                       -preSnap.timeIntervalSinceNow <= maximumSnapTime {
                        lastPreSnap = nil
                        value = .init(pose: .postSnap, chirality: hand)
                    } else {
                        value = nil
                    }
                }
                return value
            }
        }
        return .init(pose: .noSnap, chirality: hand)
    }
}

extension HandAnchorRepresentable {
    func snapPose() -> SnapGesture.SnapPose? {
        guard let distanceOne = distanceBetween(.thumbTip, .thumbIntermediateTip),
              let distanceTwo = distanceBetween(.middleFingerTip, .middleFingerIntermediateTip)
        else { return nil }
        if let distance = distanceBetween(.thumbTip, .middleFingerTip),
           distance < distanceTwo {
            return .preSnap
        }
        if let distance = distanceBetween(.thumbIntermediateTip, .middleFingerIntermediateTip),
           distance < distanceTwo {
            return .preSnap
        }
        if let distance = distanceBetween(.middleFingerTip, .indexFingerMetacarpal),
           distance < distanceOne+distanceTwo {
            return .postSnap
        }
        if let distance = distanceBetween(.middleFingerTip, .thumbKnuckle),
           distance/2 < max(distanceOne,distanceTwo) {
            return .postSnap
        }
        return nil
    }
}
