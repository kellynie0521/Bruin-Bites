//
//  ColorTheme.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI

extension Color {
    static let uclaBlue = Color(red: 0.325, green: 0.541, blue: 0.765)
    static let uclaGold = Color(red: 1.0, green: 0.847, blue: 0.4)
    static let uclaDarkBlue = Color(red: 0.0, green: 0.259, blue: 0.533)
    static let uclaLightBlue = Color(red: 0.518, green: 0.749, blue: 0.941)
    static let uclaLightGold = Color(red: 1.0, green: 0.922, blue: 0.678)
}

extension Font {
    static func roboto(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
}
