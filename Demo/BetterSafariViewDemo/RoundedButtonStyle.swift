//
//  RoundedButtonStyle.swift
//  BetterSafariViewDemo
//
//  Created by 김동규 on 2020/05/15.
//  Copyright © 2020 Stleam. All rights reserved.
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    
    enum Level {
        case primary
        case secondary
    }
    
    var level: Level
    
    private var fontWeight: Font.Weight {
        switch level {
        case .primary: return .semibold
        case .secondary: return .medium
        }
    }
    
    private var foregroundColor: Color {
        switch level {
        case .primary: return .white
        case .secondary: return .accentColor
        }
    }
    
    private var fillColor: Color {
        switch level {
        case .primary: return .accentColor
        case .secondary: return Color.accentColor.opacity(0.1)
        }
    }
    
    init(_ level: Level) {
        self.level = level
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
            Spacer()
        }
        .font(Font.body.weight(fontWeight))
        .foregroundColor(foregroundColor)
        .frame(height: 44)
        .background(fillColor)
        .overlay(Color.black.opacity(configuration.isPressed ? 0.1 : 0))
        .cornerRadius(8)
    }
}
