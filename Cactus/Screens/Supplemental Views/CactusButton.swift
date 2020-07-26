//
//  CactusButton.swift
//  Cactus
//
//  Created by Neil Poulin on 7/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct CactusButton: View {
    var label: String?
    var style: LinkStyle
    init(_ label: String?, _ style: LinkStyle = .buttonPrimary) {
        self.label = label
        self.style = style
    }
    
    var backgroundColor: Color {
        switch self.style {
        case .buttonPrimary:
            return CactusColor.green.color
        case .buttonSecondary:
            return CactusColor.white.color
        default:
            return .clear
        }
    }
    
    var textColor: Color {
        switch self.style {
        case .buttonPrimary:
            return CactusColor.white.color
        case .buttonSecondary:
            return CactusColor.textDefault.color
        default:
            return CactusColor.textDefault.color
        }
    }
    
    var padding: CGFloat {
        switch self.style {
        case .buttonPrimary:
            return 10
        case .buttonSecondary:
            return 10
        default:
            return 0
        }
    }
    
    
    var borderColor: Color {
        switch self.style {
        case .buttonPrimary:
            return CactusColor.darkGreen.color
        case .buttonSecondary:
            return CactusColor.secondaryBorder.color
        default:
            return Color.clear
        }
    }
    
    
    var borderThickness: CGFloat {
        switch self.style {
        case .buttonPrimary:
            return 4
        case .buttonSecondary:
            return 1
        default:
            return 0
        }
    }
    
    var paddingAmount: EdgeInsets {
        switch self.style {
        case .buttonPrimary:
            return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        default:
            return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        }
    }
    
    
    var body: some View {
        Text(self.label ?? "")
            .font(Font(CactusFont.normal))
            .padding(self.paddingAmount)
            .background(self.backgroundColor)
            .foregroundColor(self.textColor)
            .ifMatches(self.style == .buttonPrimary) { content in
                content.overlay(
                    GeometryReader { geometry in
                        PrimaryBorderShape(radius: geometry.size.height / 2, width: self.borderThickness)
                            .stroke(self.borderColor, lineWidth: self.borderThickness)
                        
                    }
                )
                .clipShape(Capsule())
            }
            .ifMatches(self.style == LinkStyle.buttonSecondary) { content in
                content.overlay(Capsule().stroke(self.borderColor, lineWidth: self.borderThickness))
                .clipShape(Capsule())
            }
    }
}

struct PrimaryBorderShape: Shape {
    var radius: CGFloat
    var width: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let offest: CGFloat = self.width / 2
        let x = -1 * offest
        let y = -1 * offest
        let w = rect.width + (x * -2)
        let rr = CGRect(x, y, w, rect.height)
        let bezier = UIBezierPath(roundedRect: rr, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
        let path = Path(bezier.cgPath)
        
        return path
    }
}

struct CactusButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CactusButton("Custom Button").previewDisplayName("Primary Button")
            CactusButton("Secondary Button", .buttonSecondary).previewDisplayName("Secondary Button")
        }
        .padding()
        .background(Color.gray.opacity(0.3))
        .previewLayout(.sizeThatFits)
    }
}


extension View {
   func ifMatches<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            return AnyView(content(self))
        } else {
            return AnyView(self)
        }
    }
}
