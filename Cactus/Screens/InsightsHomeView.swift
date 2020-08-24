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
    enum CurrentSheet: Identifiable {
        case promptDetails
        case coreValuesAssessment
        
        var id: Int {
            self.hashValue
        }
    }
    
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
        
    @State var currentSheet: CurrentSheet?
    @State var selectedEntry: JournalEntry?
    @State var showCoreValuesAssessment: Bool = false
    
    var stats: [Stat] {
        guard let reflectionStats = self.session.member?.stats?.reflections else {
            return []
        }
        
        return Stat.fromReflectionStats(stats: reflectionStats)
    }
    
    func onPromptDismiss(_ promptContent: PromptContent) {        
        self.currentSheet = nil
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
                        VStack(alignment: .leading, spacing: Spacing.normal) {
                            TodayWidgetView(onTapped: { entry in
                                self.selectedEntry = entry
                                self.currentSheet = .promptDetails
                            }).fixedSize(horizontal: false, vertical:  true)
                        
                            if self.session.member?.wordCloud?.isEmpty == false {
                                WordBubbleWidget()
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            }
                            
                            CoreValuesWidget(showAssessment: {
                                self.currentSheet = .coreValuesAssessment
                            })
                              
                            // GapAnalysisWidget()
                        
                        }.padding([.leading, .trailing, .bottom])
                        /// End Padded Content Group
                    }
                }
            .sheet(item: self.$currentSheet) { item in
                if item == .promptDetails && self.selectedEntry != nil {
                    PromptContentView(entry: self.selectedEntry!,
                                      onPromptDismiss: self.onPromptDismiss)
                        .environmentObject(self.session)
                        .environmentObject(self.checkout)
                        .eraseToAnyView()
                } else if item == .coreValuesAssessment {
                    CoreValuesAssessmentWebView(onClose: {
                        self.currentSheet = nil
                    }).environmentObject(self.session)
                        .environmentObject(self.checkout)
                    .eraseToAnyView()
                } else {
                    NoContentErrorView()
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
