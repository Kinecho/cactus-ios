//
//  IconImage.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import NoveFeatherIcons
struct IconImage: View {
    var featherName: Feather.IconName?
    var name: String?
    init(_ feather: Feather.IconName?) {
        self.featherName = feather
    }
    
    init(name: String?) {
        self.name = name
        if let name = name {
            self.featherName = Feather.IconName(rawValue: name)
        }
    }
    
    var uiImage: UIImage? {
        guard let icon = self.featherName else {
            return Icon.getImage(self.name)
        }
        return Feather.getIcon(icon) ?? Icon.getImage(self.featherName?.rawValue)
    }
    
    var body: some View {
        Group {
            if self.uiImage != nil {
                Image(uiImage: self.uiImage!)
            } else {
                EmptyView()
            }
        }
    }
}

struct IconImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            IconImage(.home).previewDisplayName("Home Icon")
                .padding()
            .previewLayout(.sizeThatFits)
            
            IconImage(name: nil).previewDisplayName("No Icon")
                .padding()
            .previewLayout(.sizeThatFits)
            
            IconImage(name: "pie").previewDisplayName("Pie String Icon")
                .padding()
                .previewLayout(.sizeThatFits)
        }
        
    }
}
