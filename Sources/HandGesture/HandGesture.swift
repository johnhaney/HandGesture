//
//  HandGesture.swift
//  
//
//  Created by John Haney on 11/27/24.
//

import ARUnderstanding
import SwiftUI
import RealityKit
#if canImport(ARKit)
import ARKit
#endif

public protocol HandGesture: AnyObject {
    associatedtype Value : Equatable, Sendable
    func update(with: HandTrackingModel.HandsUpdates) -> Value?
}

public class HandTrackingModel {
    @MainActor static let shared: HandTrackingModel = HandTrackingModel()
    var latestHandTracking: HandsUpdates
    @MainActor private var gestures: [UUID: any HandGesture] = [:]
    private var trackingSession: UUID? = nil
    public struct HandsUpdates {
        public var left: (any HandAnchorRepresentable)?
        public var right: (any HandAnchorRepresentable)?
        
        subscript(key: HandAnchor.Chirality) -> (any HandAnchorRepresentable)? {
            switch key {
            case .left: left
            case .right: right
            }
        }
    }
    
    init() {
        latestHandTracking = HandsUpdates()
    }
    
    @MainActor func update() {
        for gesture in gestures.values {
            _ = gesture.update(with: latestHandTracking)
        }
    }
    
    @MainActor func add<Gesture: HandGesture>(_ gesture: Gesture) -> UUID {
        let needsStart = gestures.isEmpty
        defer {
            if needsStart {
                startTracking()
            }
        }
        let id = UUID()
        gestures[id] = gesture
        return id
    }
    
    @MainActor func remove(_ id: UUID) {
        gestures.removeValue(forKey: id)
        if gestures.isEmpty {
            stopTracking()
        }
    }
    
    @MainActor func startTracking() {
        Task {
            let trackingSession = UUID()
            self.trackingSession = trackingSession
            await doTracking(trackingSession)
        }
    }
    
    @MainActor func stopTracking() {
        trackingSession = nil
        latestHandTracking.left = nil
        latestHandTracking.right = nil
    }
    
    @MainActor func doTracking(_ trackingSession: UUID) async {
        #if os(visionOS)
        for await hand in ARUnderstanding.handUpdates {
            guard trackingSession == self.trackingSession else { return }
            guard hand.event != .removed else { continue }
            switch hand.anchor.chirality {
            case .left:
                latestHandTracking.left = hand.anchor
            case .right:
                latestHandTracking.right = hand.anchor
            }
            update()
        }
        #endif
    }
}

