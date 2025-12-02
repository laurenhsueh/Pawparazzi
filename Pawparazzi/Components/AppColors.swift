//
//  AppColors.swift
//  Pawparazzi
//
//  Centralizes semantic colors so we can support light/dark mode without
//  scattering raw color literals. Add new roles here instead of hard-coding
//  RGB/opacity values in individual views.
//

import SwiftUI

enum AppColors {
    // MARK: - Brand accents
    static let accent = Color("Secondary")
    static let primaryAction = Color("PrimaryAction")
    static let accentSoftBackground = Color("AccentSoftBackground")
    
    // MARK: - Surfaces
    static let background = Color("SurfaceBackground")
    static let cardBackground = Color("CardBackground")
    static let cardShadow = Color("CardShadow")
    
    // MARK: - Controls
    static let fieldBorder = Color("FieldBorder")
    static let divider = Color("Divider")
    
    // MARK: - Text
    static let mutedText = Color("MutedText")
    
    // MARK: - System Helpers
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let separator = Color(UIColor.separator)
}

