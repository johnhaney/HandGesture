//
//  HoldingSphereGesture.swift
//  HandGesture
//
//  Created by John Haney on 12/2/24.
//

import Foundation
#if canImport(ARKit)
import ARKit
#endif
import ARUnderstanding

public class HoldingSphereGesture: HandGesture {
    // The attributes of a holding sphere gesture
    public struct Value : Equatable, Sendable {
        public let sphere: Sphere
        public let chirality: HandAnchor.Chirality
    }
    
    var minimumRadius: Float
    var maximumRadius: Float
    var hand: HandAnchor.Chirality
    
    public init(hand: HandAnchor.Chirality, minimumRadius: Float = .zero, maximumRadius: Float = .greatestFiniteMagnitude) {
        self.minimumRadius = minimumRadius
        self.maximumRadius = maximumRadius
        self.hand = hand
    }
    
    public func update(with handUpdates: HandTrackingModel.HandsUpdates) -> Value? {
        switch hand {
        case .right:
            if let rightHand = handUpdates.right,
               let right = rightHand.insideSphere() {
                return Value(sphere: right, chirality: .right)
            }
        case .left:
            if let leftHand = handUpdates.left,
               let left = leftHand.insideSphere() {
                return Value(sphere: left, chirality: .left)
            }
        }
        
        return nil
    }
    
    public typealias Body = Never
}
