//
//  SubscriptionDetailsView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/6/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import Purchases

struct SubscriptionDetailsViewModel {
//    var store: BillingPl
}

struct SubscriptionDetailsView: View {
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Details")
        }
        .font(CactusFont.normal.font)
        .background(Color.blue)
    }
}

struct SubscriptionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionDetailsView()
    }
}
