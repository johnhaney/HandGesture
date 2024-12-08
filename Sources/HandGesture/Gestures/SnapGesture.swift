//
//  SnapGesture.swift
//  HandGesture
//
//  Created by John Haney on 12/2/24.
//

import Foundation
import ARUnderstanding
import ARKit

public class SnapGesture: HandGesture {
    public struct Value : Equatable, Sendable {
        public let pose: SnapPose
        public let chirality: HandAnchor.Chirality
    }
    
    public let id: UUID = UUID()
    var hand: HandAnchor.Chirality
    var maximumSnapTime: TimeInterval = 0.5
    var lastPreSnap: Date? = nil
    
    public enum SnapPose: Equatable, Sendable {
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
                case .preSnap:
                    print("pre")
                    lastPreSnap = Date()
                    if lastPreSnap != nil {
                        value = nil
                    } else {
                        value = .init(pose: .preSnap, chirality: .right)
                    }
                case .postSnap:
                    print("post")
                    if let preSnap = lastPreSnap,
                       -preSnap.timeIntervalSinceNow <= maximumSnapTime {
                        lastPreSnap = nil
                        value = .init(pose: .postSnap, chirality: .right)
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
                case .preSnap:
                    print("pre")
                    lastPreSnap = Date()
                    if lastPreSnap != nil {
                        value = nil
                    } else {
                        value = .init(pose: .preSnap, chirality: .left)
                    }
                case .postSnap:
                    print("post")
                    if let preSnap = lastPreSnap,
                       -preSnap.timeIntervalSinceNow <= maximumSnapTime {
                        lastPreSnap = nil
                        value = .init(pose: .postSnap, chirality: .left)
                    } else {
                        value = nil
                    }
                }
                return value
            }
        }
        return nil
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
