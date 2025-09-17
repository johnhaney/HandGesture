//
//  ContentView.swift
//  HandGestureCheck
//
//  Created by John Haney on 9/16/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Hello, world!")

            #if os(visionOS)
            ToggleImmersiveSpaceButton()
            #endif
        }
        .padding()
    }
}
