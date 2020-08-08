//
//  CactusButton.swift
//  Cactus
//
//  Created by Neil Poulin on 7/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

enum ButtonState {
    case normal
    case disabled
    case loading
}

struct CactusButton: View {
    var label: String?
    var style: LinkStyle
    var state: ButtonState
    var disableBorder: Bool = false
    var fontSize: CGFloat = FontSize.normal.rawValue
    
    init(_ label: String?,
         _ style: LinkStyle = .buttonPrimary,
         state: ButtonState = .normal,
         disableBorder: Bool=false,
         fontSize: CGFloat=FontSize.normal.rawValue) {
        self.label = label
        self.style = style
        self.state = state
        self.fontSize = fontSize
        self.disableBorder = disableBorder
    }
    
    var backgroundColor: Color {
        if self.state == .loading || self.state == .disabled {
            return NamedColor.GrayLight.color
        }
        
        switch self.style {
        case .buttonPrimary:
            return CactusColor.green.color
        case .buttonSecondary:
            return NamedColor.SecondaryButtonBackground.color
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
            if self.state == .loading || self.state == .disabled {
                return NamedColor.GrayLight.color
            }
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
            return self.disableBorder ? 0 : 4
        case .buttonSecondary:
            return 1
        default:
            return 0
        }
    }
    
    var font: Font {
        switch self.style {
        case .buttonPrimary:
            return CactusFont.bold(self.fontSize).font
        case .buttonSecondary:
            return CactusFont.bold(self.fontSize).font
        default:
            return CactusFont.normal(self.fontSize).font
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
            .font(self.font)
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
            Group {
                CactusButton("Primary Button", state: .disabled).previewDisplayName("Primary Button (Disabled)")
                CactusButton("Primary Button").previewDisplayName("Primary Button")
                CactusButton("Primary Button No Border", disableBorder: true).previewDisplayName("Primary Button No Border")
                CactusButton("Secondary Button", .buttonSecondary).previewDisplayName("Secondary Button")
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .background(NamedColor.Background.color)
            
            Group {
                CactusButton("Primary Button").previewDisplayName("Primary Button (Dark)").colorScheme(.dark)
                CactusButton("Primary Button No Border", disableBorder: true).previewDisplayName("Primary Button No Border (Dark)").colorScheme(.dark)
                CactusButton("Secondary Button", .buttonSecondary).previewDisplayName("Secondary Button (Dark)")
            }
            .padding()
            .background(NamedColor.Background.color)
            
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)
            
            
        }
        
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
