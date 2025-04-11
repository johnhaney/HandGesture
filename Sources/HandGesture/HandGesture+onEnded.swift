//
//  File.swift
//  HandGesture
//
//  Created by John Haney on 4/10/25.
//

import SwiftUI

public extension HandGesture {
    public func onEnded(perform action: @escaping (Value) -> Void) -> EndGesture<Self> {
        EndGesture(self, perform: action)
    }
}

public class EndGesture<Gesture: HandGesture>: HandGesture {
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
