//
//  InsightsHome.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import NoveFeatherIcons
struct InsightsHome: View {
    @EnvironmentObject var session: SessionStore
    var todayEntry: JournalEntry? {
        self.session.journalEntries.first
    }
    
    var stats: [Stat] = [
        Stat(type: .streak, value: 52, unit: UnitFormatter.day),
        Stat(type: .reflectionCount, value: 128),
        Stat(type: .reflectionDuration, value: 1, unit: UnitFormatter.minute),
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                /// Start Stats HScroll View
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: Spacing.normal) {
                        ForEach(stats) { stat in
                            StatView(stat: stat)
                                .background(named: .CardBackground)
                                .cornerRadius(CornerRadius.normal)
                        }
                    }.padding()
                }
                /// End Stats HScroll View
                
                /// Start padded content group
                Group {
                    /// Start Today Entry
                    if self.todayEntry != nil {
                        JournalEntryRow(entry: self.todayEntry!)
                    }
                    /// End Today Entry
                    
                    
                    /// Start Core Values
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Image(uiImage: Icon.getImage(Feather.IconName.lock)!)
                                .resizable()
                                .frame(width: 16, height: 16)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(named: .White)
                                .offset(x: 0, y: 4)
                            
                            VStack(alignment: .leading) {
                                Text("What are your core values?")
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(NamedColor.White.color)
                                    .font(CactusFont.bold(.title).font)
                                Text("Discover what drives your life decisions and deepest needs")
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(NamedColor.White.color)
                            }
                        }
                    }
                    .maxWidth(.infinity)
                    .padding(Spacing.normal)
                        .background(NamedColor.Dolphin.color)
                    .cornerRadius(CornerRadius.normal)
                    /// End Core Values
                    
                    /// Start Gap Assessment
                   VStack(alignment: .leading) {
                       HStack(alignment: .top) {
                           Image(uiImage: Icon.getImage(Feather.IconName.lock)!)
                               .resizable()
                               .frame(width: 16, height: 16)
                               .aspectRatio(contentMode: .fit)
                               .foregroundColor(named: .White)
                               .offset(x: 0, y: 4)
                           
                           VStack(alignment: .leading) {
                               Text("What Makes You Happy?")
                                   .multilineTextAlignment(.leading)
                                   .foregroundColor(NamedColor.White.color)
                                   .font(CactusFont.bold(.title).font)
                               Text("Understand what contributes to (and detracts from) your satisfaction.")
                                   .multilineTextAlignment(.leading)
                                   .foregroundColor(NamedColor.White.color)
                           }
                       }
                   }
                   .maxWidth(.infinity)
                   .padding(Spacing.normal)
                       .background(NamedColor.Indigo.color)
                   .cornerRadius(CornerRadius.normal)
                   /// End Gap Assessment
                    
                }.padding()
                /// End Padded Content Group
            }
            .backgroundFill(NamedColor.Background.color)
        }
        
    }
}

struct InsightsHome_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.hashValue) { color in
                Group {
                    InsightsHome().previewDisplayName("No Nav Wrapper (\(String(describing: color)))")
                    .background(named: .Background)
                        .environmentObject(SessionStore.mockLoggedIn().setEntries(MockData.getDefaultJournalEntries()))
                    .colorScheme(color)
                    
                }
                Group {
                    NavigationView {
                        InsightsHome().navigationBarTitle("Home")
                    }
                        .previewDisplayName("Insights Home (\(String(describing: color)))")
                    .background(named: .Background)
                    .environmentObject(SessionStore.mockLoggedIn().setEntries(MockData.getDefaultJournalEntries()))
                    .colorScheme(color)
                    
                }
            }
        }
        
        
    }
}
