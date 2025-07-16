//
//  Sphere.swift
//  HandGesture
//
//  Created by John Haney on 11/30/24.
//

#if canImport(RealityKit)
import Foundation
import RealityKit
import simd

public struct Sphere: Equatable, Sendable {
    public let center: SIMD3<Float>
    public let radius: Float
}

@available(tvOS 26.0, *)
public extension Sphere {
    static var zero: Self { .init(center: .zero, radius: .zero) }
    var originFromAnchorTransform: simd_float4x4 {
        Transform(scale: SIMD3<Float>(repeating: radius), translation: center).matrix
    }
    
    var radiusScale: SIMD3<Float> {
        .init(repeating: radius)
    }
}
#endif
