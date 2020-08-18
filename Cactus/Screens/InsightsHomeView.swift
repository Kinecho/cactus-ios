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
    enum CurrentSheet {
        case promptDetails
    }

    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    
    @State var showSheet: Bool = false
    @State var currentSheet: CurrentSheet = .promptDetails
    @State var selectedEntry: JournalEntry?
  
    var stats: [Stat] {
        guard let reflectionStats = self.session.member?.stats?.reflections else {
            return []
        }
        
        return Stat.fromReflectionStats(stats: reflectionStats)
    }
    
    func onPromptDismiss(_ promptContent: PromptContent) {
        // no op
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                /// Start Stats HScroll View
                ScrollView(.horizontal, showsIndicators: false) {
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
                    TodayWidgetView(onTapped: { entry in
                        self.currentSheet = .promptDetails
                        self.showSheet = true
                        self.selectedEntry = entry
                    })
                
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
        .sheet(isPresented: self.$showSheet) {
            if self.currentSheet == .promptDetails && self.selectedEntry != nil {
                PromptContentView(entry: self.selectedEntry!, onPromptDismiss: self.onPromptDismiss)
                                .environmentObject(self.session)
                                .environmentObject(self.checkout)
            } else {
                EmptyView()
            }
            
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
