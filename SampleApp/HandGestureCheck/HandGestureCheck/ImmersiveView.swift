//
//  ImmersiveView.swift
//  HandGestureCheck
//
//  Created by John Haney on 9/16/25.
//

import SwiftUI
import RealityKit
import HandGesture
internal import ARUnderstanding

@available(tvOS 26.0, *)
struct ImmersiveView: View {
    @State var leftHandEntity = ModelEntity(mesh: .generateBox(width: 0.1, height: 0.1, depth: 0.1), materials: [SimpleMaterial(color: .purple, roughness: 1, isMetallic: false)])
    @State var rightHandEntity = ModelEntity(mesh: .generateBox(width: 0.1, height: 0.1, depth: 0.1), materials: [SimpleMaterial(color: .purple, roughness: 1, isMetallic: false)])

    var body: some View {
        RealityView { content in
            let base = Entity()
            base.position = [0,0,-0.5]
            content.add(base)
            base.addChild(leftHandEntity)
            base.addChild(rightHandEntity)
        }
        .handGesture(
            DummyGesture()
                .onChanged(perform: { hands in
                    Task {
                        await MainActor.run {
                            if let hand = hands.left {
                                leftHandEntity.transform = hand
                            }
                            if let hand = hands.right {
                                rightHandEntity.transform = hand
                            }
                        }
                    }
                })
                .onEnded { _ in
                    leftHandEntity.transform = .identity
                    rightHandEntity.transform = .identity
                }
        )
    }
}

@available(tvOS 26.0, *)
class DummyGesture: HandGesture {
    typealias Value = LeftRightHands
    nonisolated struct LeftRightHands: Equatable {
        let left: Transform?
        let right: Transform?
    }
    func update(with: HandTrackingModel.HandsUpdates) -> LeftRightHands? {
        let left: Transform?
        let right: Transform?
        if let leftMatrix = with.left?.originFromAnchorTransform {
            left = Transform(matrix: leftMatrix)
        } else {
            left = nil
        }
        if let rightMatrix = with.right?.originFromAnchorTransform {
            right = Transform(matrix: rightMatrix)
        } else {
            right = nil
        }
        return LeftRightHands(left: left, right: right)
    }
}
