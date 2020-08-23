//
//  NoContentErrorView.swift
//  Cactus Local
//
//  Created by Neil Poulin on 8/22/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct NoContentErrorView: View {
    
    var detailMessage: String {
        if #available(iOS 14, *) {
            return "No content can be shown here. This is likely due to an issue with iOS the 14 Beta."
        } else {
            return "No content can be shown here."
        }
    }
    
    var body: some View {
        VStack {
            Text("Whoops!").font(CactusFont.bold(FontSize.normal))
                .multilineTextAlignment(.center)
            Text(self.detailMessage)
                .multilineTextAlignment(.center)
            Image(CactusImage.errorBlob.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
        }.padding(Spacing.large)
    }
}

struct NoContentErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NoContentErrorView()
    }
}
