//
//  HandGesture.swift
//  
//
//  Created by John Haney on 11/27/24.
//

import ARUnderstanding
import SwiftUI
import RealityKit
import ARKit

public extension View {
    func handGesture<Gesture: HandGesture>(_ gesture: Gesture) -> some View {
        modifier(HandGestureModifier(gesture: gesture))
    }
}

public struct HandGestureModifier<Gesture: HandGesture>: ViewModifier {
    var handTrackingModel: HandTrackingModel = HandTrackingModel.shared
    var gesture: Gesture
    public func body(content: Content) -> some View {
        content
            .onAppear {
                handTrackingModel.add(gesture)
            }
            .onDisappear {
                handTrackingModel.remove(gesture)
            }
    }
}

public protocol HandGesture: AnyObject, Equatable {
    var id: UUID { get }
    associatedtype Value : Equatable, Sendable
    func update(with: HandTrackingModel.HandsUpdates) -> Value?
}

public protocol HandGestureAnchoring: HandGesture {
    associatedtype Anchor: ARKit.Anchor
    func anchor(from: Value) -> Anchor
}

public extension HandGesture {
    static func ==(lhs: any HandGesture, rhs: any HandGesture) -> Bool {
        lhs.id == rhs.id
    }
    
    static func ==(lhs: Self, rhs: any HandGesture) -> Bool {
        lhs.id == rhs.id
    }
    
    static func ==(lhs: any HandGesture, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func onChanged(perform action: @escaping (Value) -> Void) -> ChangeGesture<Self> {
        ChangeGesture(self, perform: action)
    }
    
    func onEnded(perform action: @escaping (Value) -> Void) -> EndGesture<Self> {
        EndGesture(self, perform: action)
    }
}

public class ChangeGesture<Gesture: HandGesture>: HandGesture {
    public let id: UUID = UUID()
    private var gesture: Gesture
    private var action: (Gesture.Value) -> Void
    var lastValue: Gesture.Value? = nil
    
    public func update(with updates: HandTrackingModel.HandsUpdates) -> Gesture.Value? {
        let value = gesture.update(with: updates)
        if let value,
           value != lastValue {
            action(value)
            lastValue = value
        }
        return value
    }
    
    init(_ gesture: Gesture, perform action: @escaping (Gesture.Value) -> Void) {
        self.gesture = gesture
        self.action = action
    }
}

public class EndGesture<Gesture: HandGesture>: HandGesture {
    public let id: UUID = UUID()
    private var gesture: Gesture
    private var action: (Gesture.Value) -> Void
    var lastValue: Gesture.Value? = nil

    public func update(with updates: HandTrackingModel.HandsUpdates) -> Gesture.Value? {
        let value = gesture.update(with: updates)
        if value == nil,
           let lastValue {
            action(lastValue)
        }
        lastValue = value
        return value
    }
    
    init(_ gesture: Gesture, perform action: @escaping (Gesture.Value) -> Void) {
        self.gesture = gesture
        self.action = action
    }
}

public class HandTrackingModel {
    @MainActor static let shared: HandTrackingModel = HandTrackingModel()
    var latestHandTracking: HandsUpdates
    private var gestures: [any HandGesture] = []
    private var trackingSession: UUID? = nil
    public struct HandsUpdates {
        public var left: (any HandAnchorRepresentable)?
        public var right: (any HandAnchorRepresentable)?
    }
    
    init() {
        latestHandTracking = HandsUpdates()
    }
    
    func update() {
        for gesture in gestures {
            _ = gesture.update(with: latestHandTracking)
        }
    }
    
    @MainActor func add<Gesture: HandGesture>(_ gesture: Gesture) {
        let needsStart = gestures.isEmpty
        defer {
            if needsStart {
                startTracking()
            }
        }
        gestures.append(gesture)
    }
    
    @MainActor func remove<Gesture: HandGesture>(_ gesture: Gesture) {
        gestures.removeAll(where: { gesture == $0 })
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
        for await hand in ARUnderstanding.handUpdates {
            guard trackingSession == self.trackingSession else { return }
            switch hand.anchor.chirality {
            case .left:
                latestHandTracking.left = hand.anchor
            case .right:
                latestHandTracking.right = hand.anchor
            }
            update()
        }
    }
}

