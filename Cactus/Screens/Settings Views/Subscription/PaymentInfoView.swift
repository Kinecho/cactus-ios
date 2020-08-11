//
//  PaymentInfoView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct PaymentInfoView: View {
    
    var platform: BillingPlatform
    var manageUrl: URL?
    var cardBrand: CardBrand?
    var last4: String?
    
    
    var manageButtonText: String? {
        switch self.platform {
        case .APPLE:
            return "Manage on the App Store"
        case .GOOGLE:
            return "Manage on Google Play"
        case .STRIPE:
            return nil
        default:
            return nil
        }
    }
    
    var buttonUrl: URL? {
        if let url = self.manageUrl {
            return url
        }
        if self.platform == .APPLE {
            return URL(string: "https://apps.apple.com/account/subscriptions")
        }
        else if self.platform == .GOOGLE {
            return URL(string: "https://play.google.com/store/account/subscriptions")
        }
        return nil
    }
    
    var brandImage: Image? {
        return self.platform.cactusImage?.swiftImage
    }
    
    var text: String? {
        guard platform == .STRIPE else {
            return nil
        }
        
        if let brand = self.cardBrand, let last4 = self.last4 {
            return "\(brand.displayName) ending in \(last4)"
        }
        return nil
    }
    
    var isHidden: Bool {
        return self.text == nil && (self.manageButtonText == nil || self.buttonUrl == nil)
    }
    
    var body: some View {
        HStack {
            if self.brandImage != nil {
                self.brandImage!.resizable()
                    .aspectRatio(contentMode: .fit)
                    .ifMatches(self.platform == BillingPlatform.STRIPE) { $0.foregroundColor(NamedColor.Green.color)}
                    .height(25)
                    .width(25)
                    .padding(.trailing, Spacing.small)
                
            }
            if self.text != nil {
                Text(self.text!)
            }
            if self.manageButtonText != nil && self.buttonUrl != nil {
                Button(action: {
                    NavigationService.shared.openUrl(url: self.buttonUrl!)
                }) {
                    Text(self.manageButtonText!).foregroundColor(NamedColor.LinkColor.color)
                }
            }
        }
        .padding(.vertical, Spacing.small)
        .padding(.horizontal, Spacing.normal)
        .background(self.isHidden ? Color.clear : NamedColor.PaymentBackground.color)
        .cornerRadius(CornerRadius.normal)
    }
}

struct PaymentInfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                PaymentInfoView(platform: .PROMOTIONAL).previewDisplayName("Promotional (hidden)")
                PaymentInfoView(platform: .APPLE).previewDisplayName("Apple")
                PaymentInfoView(platform: .GOOGLE).previewDisplayName("Google")
                PaymentInfoView(platform: .STRIPE, cardBrand: CardBrand.visa, last4: "0333").previewDisplayName("Stripe Card")
            }
            .padding()
            .background(NamedColor.Background.color)
            .previewLayout(.sizeThatFits)
            
            Group {
                PaymentInfoView(platform: .APPLE).previewDisplayName("Apple")
                PaymentInfoView(platform: .GOOGLE, manageUrl: URL(string: "http://google.com")).previewDisplayName("Google")
                PaymentInfoView(platform: .STRIPE, cardBrand: CardBrand.visa, last4: "0333").previewDisplayName("Stripe Card")
            }
            .padding()
            .background(NamedColor.Background.color)
            .colorScheme(.dark)
            .previewLayout(.sizeThatFits)
        }
    }
}
