//
//  Environment+Animating.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-15.
//

import SwiftUI

extension EnvironmentValues {
    
    @Entry var isAnimating: Bool = false
}

extension View {
    
    func isAnimating(_ value: Bool) -> some View {
        environment(\.isAnimating, value)
    }
}
