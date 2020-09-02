//
//  BuyableItem.swift
//  Cactus
//
//  Created by Neil Poulin on 8/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import StoreKit

struct BuyableItemViewModel {
    var formattedPrice: String
    var appleProductId: String
    var billingPeriod: BillingPeriod
    
    
    static func fromProduct(_ product: SKProduct) -> BuyableItemViewModel {
        let formattedPrice = formatApplePrice(product.price, locale: product.priceLocale) ?? ""
        let model = BuyableItemViewModel(formattedPrice: formattedPrice,
                                         appleProductId: product.productIdentifier,
                                         billingPeriod: product.subscriptionPeriod?.billingPeriod ?? .unknown )
        return model
    }
}

struct BuyableItemView: View {
    var model: BuyableItemViewModel
    var selected: Bool = false
    
    
    var borderWidth: CGFloat {
        self.selected ? 0 : 4
    }
    
    var borderColor: NamedColor {
        self.selected ? NamedColor.SelectedBuyable : NamedColor.BorderLight
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: Spacing.small) {
            Text((model.billingPeriod.productTitle ?? "").uppercased())
                .kerning(Kerning.title)
                .font(CactusFont.normal.font)
            
            VStack(alignment: .center, spacing: 0) {
                Text(model.formattedPrice)
                    .font(weight: .bold, size: .normal)
                
                Text("per \(model.billingPeriod.displayName ?? "")")
            }
        }
        .padding()
        .ifMatches(self.selected) { $0.background(named: .SelectedBuyable) }
        .border(self.borderColor.color, width: 4, cornerRadius: 10)
        
    }
}

struct BuyableItemView_Previews: PreviewProvider {
    
    static var items: [(id: UUID, model: BuyableItemViewModel)] = [
        BuyableItemViewModel(formattedPrice: "$9.99", appleProductId: "testId", billingPeriod: .monthly),
        BuyableItemViewModel(formattedPrice: "$59.99", appleProductId: "testId1", billingPeriod: .yearly),
    ].map { (id: UUID(), model: $0) }
    
    static var colors: [ColorScheme] = [.light, .dark]
    static var previews: some View {
        Group {
            ForEach(colors, id: \.hashValue) { color in
                ForEach(items, id: \.id) { item in
                    Group {
                        BuyableItemView(model: item.model, selected: false)
                            .padding()
                            .background(named: .Background)
                            .previewLayout(.sizeThatFits)
                            .previewDisplayName("\(item.model.billingPeriod.displayName ?? "n/a") (\(String(describing: color)))")
                            .colorScheme(color)
                        
                        BuyableItemView(model: item.model, selected: true)
                            .padding()
                            .background(named: .Background)
                            .previewLayout(.sizeThatFits)
                            .previewDisplayName("\(item.model.billingPeriod.displayName ?? "n/a") - selected - (\(String(describing: color)))")
                            .colorScheme(color)
                    }
                }
                
            }
            
        }
    }
}
