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
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        /// Start Stats HScroll View
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: Spacing.normal) {
                                ForEach(self.stats) { stat in
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
                            CoreValuesWidget()
                            
                            /// Start Gap Assessment - not showing for now.
                            //                   GapAnalysisWidget()
                            
                        }.padding()
                        /// End Padded Content Group
                    }
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
