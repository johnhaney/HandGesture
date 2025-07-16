//
//  HandGesture+onChanged.swift
//  HandGesture
//
//  Created by John Haney on 4/10/25.
//

import Foundation

public extension HandGesture {
    func onChanged(perform action: @escaping (Value) -> Void) -> ChangeGesture<Self> {
        ChangeGesture(self, perform: action)
    }
}

public class ChangeGesture<Gesture: HandGesture>: HandGesture {
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
