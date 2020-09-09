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
        case promptDetails(JournalEntry)
        case editNote(JournalEntry)
        case coreValuesAssessment
        
        var id: Int {
            switch self {
            case .promptDetails:
                return 1
            case .coreValuesAssessment:
                return 2
            case .editNote:
                return 3
            }
            
        }
    }
    
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
        
    @State var currentSheet: CurrentSheet?
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
    
    var statsView: some View {
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: Spacing.small) {
                ForEach(self.stats) { stat in
                    StatView(stat: stat)
                        .background(named: .CardBackground)
                        .cornerRadius(CornerRadius.normal)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }.padding([.leading, .trailing], Spacing.normal)
            .padding(.bottom, Spacing.normal)
            .padding(.top, Spacing.medium)
        }
    }
    
    func getSheetView(item: CurrentSheet) -> AnyView {
        switch item {
        case .promptDetails(let entry):
            return PromptContentView(entry: entry, onPromptDismiss: self.onPromptDismiss)
                .eraseToAnyView()
        case .coreValuesAssessment:
            return CoreValuesAssessmentWebView(onClose: {
                self.currentSheet = nil
            })
            .eraseToAnyView()
        
        case .editNote(let entry):
            return EditNoteView(entry: entry, onDone: {
                self.currentSheet = nil
            }, onCancel: {
                self.currentSheet = nil
            }).environmentObject(self.session)
            .eraseToAnyView()
        }
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        /// Start Stats HScroll View
                        self.statsView
                        /// End Stats HScroll View
                        
                        /// Start padded content group
                        VStack(alignment: .leading, spacing: Spacing.normal) {                            
                            TodayWidgetView(onTapped: { entry in
                                self.currentSheet = .promptDetails(entry)
                            }, onEditNote: { entry in
                                self.currentSheet = .editNote(entry)
                            }).fixedSize(horizontal: false, vertical: true)
                        
                            if self.session.member?.wordCloud?.isEmpty == false {
                                WordBubbleWidget()
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            }
                            
                            CoreValuesWidget(showAssessment: {
                                Vibration.selection.vibrate()
                                self.currentSheet = .coreValuesAssessment
                            })
                              
                            // GapAnalysisWidget()
                        
                        }.padding([.leading, .trailing, .bottom], Spacing.normal)
                        /// End Padded Content Group
                    }
                }
            .sheet(item: self.$currentSheet) { item in
                self.getSheetView(item: item)
                    .environmentObject(self.session)
                    .environmentObject(self.checkout)
            }
        }
    }
    
}

struct InsightsHome_Previews: PreviewProvider {
    static func addStats(_ member: CactusMember) {
        
        let acc = ElementAccumulation()
        let stats = ReflectionStats(currentStreakDays: 2,
                                    currentStreakWeeks: 7,
                                    currentStreakMonths: 12,
                                    totalDurationMs: 29438283,
                                    totalCount: 193,
                                    elementAccumulation: acc)
        let memberStats = MemberStats(reflections: stats)        
        member.stats = memberStats
    }
    
    static func addTodayEntry(_ session: SessionStore) {
        session.todayEntry = MockData.getUnansweredEntry(isToday: true, blob: 4)
        session.todayEntryLoaded = true
    }
    
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.hashValue) { color in
                Group {
                   NavigationView {
                       InsightsHome().navigationBarTitle("Home")
                   }
                   .previewDisplayName("Loading Today Entry (\(String(describing: color)))")
                   .background(named: .Background)
                   .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS, configMember: addStats, configStore: nil)
                       .setEntries(MockData.getDefaultJournalEntries()))
                   .colorScheme(color)
               }
                Group {
                    InsightsHome().previewDisplayName("No Today Entry (\(String(describing: color)))")
                        .background(named: .Background)
                        .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS, configMember: addStats, configStore: {store in
                            store.todayEntryLoaded = true
                        })
                            .setEntries(MockData.getDefaultJournalEntries()))
                        .colorScheme(color)
                }
                Group {
                    InsightsHome().previewDisplayName("With Today Entry (\(String(describing: color)))")
                        .background(named: .Background)
                        .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS, configMember: addStats, configStore: addTodayEntry)
                            .setEntries(MockData.getDefaultJournalEntries()))
                        .colorScheme(color)
                }
               
            }
        }
        
        
    }
}
