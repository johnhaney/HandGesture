//
//  HandGesture.swift
//  
//
//  Created by John Haney on 11/27/24.
//

import ARUnderstanding
import SwiftUI
#if canImport(RealityKit)
import RealityKit
#endif
#if canImport(ARKit)
import ARKit
#endif

public protocol HandGesture: AnyObject {
    associatedtype Value : Equatable, Sendable
    func update(with: HandTrackingModel.HandsUpdates) -> Value?
}

public class HandTrackingModel: ARUnderstandingOutput {
    @MainActor static let shared: HandTrackingModel = HandTrackingModel()
    var latestHandTracking: HandsUpdates
    @MainActor private var gestures: [UUID: any HandGesture] = [:]
    @MainActor private var trackingSession: UUID? = nil {
        didSet {
            if let oldValue {
                Self.stopTracking(session: oldValue)
            }
        }
    }
    @MainActor private var liveInputName: String? = nil {
        didSet {
            if let oldValue {
                ARUnderstanding.session.remove(inputNamed: oldValue)
            }
        }
    }
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
    
    deinit {
        if let liveInputName {
            Task {
                await MainActor.run {
                    ARUnderstanding.session.remove(inputNamed: liveInputName)
                }
            }
        }
        if let trackingSession {
            Task {
                await MainActor.run {
                    HandTrackingModel.stopTracking(session: trackingSession)
                }
            }
        }
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
    
    @MainActor static func stopTracking(session trackingSession: UUID) {
        #if os(visionOS)
        ARUnderstanding.session.remove(outputNamed: "com.appsyoucanmake.HandGesture.\(trackingSession)")
        #endif
    }
    
    @MainActor func doTracking(_ trackingSession: UUID) async {
        #if os(visionOS)
        ARUnderstanding.session.add(output: self, name: "com.appsyoucanmake.HandGesture.\(trackingSession)")
        if !ARUnderstanding.session.isRunning {
            self.liveInputName = ARUnderstanding.session.add(input: ARUnderstandingLiveInput(providers: [.hands]))
            ARUnderstanding.session.start()
        }
        #endif
    }
    
    public func handle(_ message: ARUnderstandingSession.Message) async {
        switch message {
        case .newSession:
            break
        case .anchor(let capturedAnchor):
            switch capturedAnchor {
            case .hand(let hand):
                guard trackingSession == self.trackingSession else { return }
                guard capturedAnchor.event != .removed else { return }
                switch hand.anchor.chirality {
                case .left:
                    latestHandTracking.left = hand.anchor
                case .right:
                    latestHandTracking.right = hand.anchor
                }
                update()
            default:
                break
            }
        case .authorizationDenied(let string):
            stopTracking()
        case .trackingError(let string):
            stopTracking()
        case .unknown:
            break
        }
    }
}

