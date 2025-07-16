//
//  SnapGesture.swift
//  HandGesture
//
//  Created by John Haney on 12/2/24.
//

#if canImport(RealityKit)
import Foundation
#if canImport(ARKit)
import ARKit
#endif
import ARUnderstanding

@available(tvOS 26.0, *)
public class SnapGesture: HandGesture {
    public struct Value : Equatable, Sendable {
        public let pose: SnapPose
        public let chirality: HandAnchor.Chirality
        
        public static func noSnap(_ chirality: HandAnchor.Chirality) -> Value {
            .init(pose: .noSnap, chirality: chirality)
        }
        
        public static func preSnap(_ chirality: HandAnchor.Chirality) -> Value {
            .init(pose: .preSnap, chirality: chirality)
        }
        
        public static func postSnap(_ chirality: HandAnchor.Chirality) -> Value {
            .init(pose: .postSnap, chirality: chirality)
        }
    }
    
    var hand: HandAnchor.Chirality
    var maximumSnapTime: TimeInterval = 0.5
    var lastValue: Value? = nil
    var lastPreSnap: Date? = nil
    
    public enum SnapPose: Equatable, Sendable {
        case noSnap
        case preSnap
        case postSnap
    }
    
    public init(hand: HandAnchor.Chirality, maximumSnapTime: TimeInterval = 0.25) {
        self.hand = hand
        self.maximumSnapTime = maximumSnapTime
    }
    
    /// update(with:) returns some value as long as the gesture is being recognized, and nil when it is not recognized
    /// in this case, we return values during preSnap and once on postSnap (if it was fast enough), and nil otherwise
    public func update(with handUpdates: HandTrackingModel.HandsUpdates) -> Value? {
        if let handUpdate = handUpdates[hand] {
            let value: Value?
            if lastValue == .postSnap(hand) {
                lastPreSnap = nil
                value = nil
            } else if let snapPose = handUpdate.snapPose() {
                switch snapPose {
                case .noSnap:
                    value = lastValue
                case .preSnap:
                    lastPreSnap = Date()
                    value = .preSnap(hand)
                case .postSnap:
                    if let preSnap = lastPreSnap {
                        if -preSnap.timeIntervalSinceNow <= maximumSnapTime {
                            value = .postSnap(hand)
                        } else {
                            value = .noSnap(hand)
                        }
                    } else {
                        value = .noSnap(hand)
                    }
                    // If we are at post snap, either it was fast enough or it wasn't, either way, we reset lastPreSnap
                    lastPreSnap = nil
                }
            } else {
                value = .noSnap(hand)
            }
            lastValue = value
            return value
        } else {
            return lastValue
        }
    }
}

@available(tvOS 26.0, *)
extension HandAnchorRepresentable {
    func snapPose() -> SnapGesture.SnapPose? {
        var isPreSnap: Bool = false
        var isPostSnap: Bool = false
        guard let distanceOne = distanceBetween(.thumbTip, .thumbIntermediateTip),
              let distanceTwo = distanceBetween(.middleFingerTip, .middleFingerIntermediateTip)
        else { return nil }
        if let distance = distanceBetween(.thumbTip, .middleFingerTip),
           distance < distanceTwo {
            isPreSnap = true
        }
        if let distance = distanceBetween(.thumbIntermediateTip, .middleFingerIntermediateTip),
           distance < distanceTwo {
            isPreSnap = true
        }
        if let distance = distanceBetween(.middleFingerTip, .indexFingerMetacarpal),
           distance < distanceOne+distanceTwo {
            isPostSnap = true
        }
        if let distance = distanceBetween(.middleFingerTip, .thumbKnuckle),
           distance/2 < max(distanceOne,distanceTwo) {
            isPostSnap = true
        }
        
        switch (isPreSnap, isPostSnap) {
        case (false, false):
            return nil
        case (true, true):
            return nil
        case (true, false):
            return .preSnap
        case (false, true):
            return .postSnap
        }
    }
}
#endif
