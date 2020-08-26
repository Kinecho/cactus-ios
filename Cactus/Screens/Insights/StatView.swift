//
//  StatView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import NoveFeatherIcons

struct StatView: View {
    var stat: Stat
    
    
    var valueText: String {
        return "\(self.stat.value)"
    }
    
    var title: String {
        self.stat.type.displayName
    }
    
    var unit: String? {
        guard let formatter = self.stat.unit else {
            return nil
        }
        return LocalizedUnit(formatter, self.stat.value).unitsOnly.localizedCapitalized
    }
    
    var icon: UIImage? {
        return Icon.getImage(self.stat.type.iconName)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: Spacing.normal) {
            if self.icon != nil {
                Image(uiImage: self.icon!)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(Spacing.normal)
                    .background(named: NamedColor.StatIconBackground)
                    .foregroundColor(named: .Green)
                    .clipShape(Circle())
                    
            }
            VStack(alignment: .leading) {
                Text(self.title)
                HStack(alignment: .bottom) {
                    Text(self.valueText).font(CactusFont.bold(FontSize.statLarge).font)
                    if self.unit != nil {
                        Text(self.unit!).offset(x: 0, y: -5)
                    }
                }
            }
            
        }
        .padding()
        .font(CactusFont.normal.font)
        .foregroundColor(named: .Heading3Text)
        .border(CactusColor.borderLight.color, width: 1, cornerRadius: CornerRadius.normal, style: .continuous)
        
    }
}

struct StatView_Previews: PreviewProvider {
    static let stats: [Stat] = [
        Stat(type: .streak, value: 52, unit: UnitFormatter.day),
        Stat(type: .reflectionCount, value: 128),
        Stat(type: .reflectionDuration, value: 1, unit: UnitFormatter.minute),
    ]
    
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.hashValue) { color in
            ForEach(stats) { stat in
                StatView(stat: stat)
                .padding()
                .background(named: .Background)
                .colorScheme(color)
                    .previewDisplayName("\(stat.type.displayName)\(stat.unit != nil ? " \(LocalizedUnit(stat.unit!, stat.value).unitsOnly)" : "") (\(String(describing: color)))")
                .previewLayout(.sizeThatFits)
            }
        }
    }
}
