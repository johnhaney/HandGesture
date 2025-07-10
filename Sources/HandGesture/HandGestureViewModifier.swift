//
//  SwiftUIView.swift
//  HandGesture
//
//  Created by John Haney on 4/10/25.
//

import SwiftUI

public extension View {
    func handGesture<Gesture: HandGesture>(_ gesture: Gesture?) -> some View {
        modifier(HandGestureModifier(gesture: gesture))
    }
}

public struct HandGestureModifier<Gesture: HandGesture>: ViewModifier {
    var handTrackingModel: HandTrackingModel = HandTrackingModel.shared
    var gesture: Gesture?
    @State var gestureID: UUID?
    public func body(content: Content) -> some View {
        content
            .onAppear {
                if let gesture {
                    gestureID = handTrackingModel.add(gesture)
                }
            }
            .onDisappear {
                if let gestureID {
                    handTrackingModel.remove(gestureID)
                }
            }
    }
}

