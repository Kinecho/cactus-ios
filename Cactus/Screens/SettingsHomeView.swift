//
//  SettingsHome.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct SettingsItem: Identifiable {
    
    var id: Int
    var title: String
    var subtitle: String?
    var destination: AnyView
    var setNavigationTitle: Bool
    init<V>(id: Int, _ title: String, _ subtitle: String?=nil, destination: V, setNavigationTitle: Bool=true) where V: View {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.destination = AnyView(destination)
        self.setNavigationTitle = setNavigationTitle
    }
}

struct SettingsItemView: View {
    var item: SettingsItem
    @Binding var selectedId: Int?
    
    let highlightColor: Color = NamedColor.GrayLight.color
    
    var body: some View {
        NavigationLink(destination: self.item.destination
            .onAppear {
                self.selectedId = self.item.id
            }
            .maxWidth(700)
            .ifMatches(self.item.setNavigationTitle) { content in
                content.navigationBarTitle(item.title)
            },
            tag: self.item.id,
            selection: self.$selectedId
        ) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.title)
                    if item.subtitle != nil {
                        Text(item.subtitle!)
                            .font(CactusFont.normal(FontSize.small).font)
                            .foregroundColor(CactusColor.textMinimized.color)
                    }
                }
            }.tag(item.id)
        }
        .isDetailLink(true)
        .tag(item.id)
        .minHeight(44)
        .padding([.leading, .trailing], Spacing.normal)
        .padding([.top, .bottom], Spacing.medium)
        .listRowInsets(EdgeInsets())
        .foregroundColor(CactusColor.highContrast.color)
        .ifMatches(self.selectedId == self.item.id, content: { $0.background(self.highlightColor)})
    }
}

struct SettingsHome: View {
    @EnvironmentObject var session: SessionStore
    @State var isLoggingOut: Bool = false
    @State var selectedItemId: Int? = 1
    
    var items: [SettingsItem] {
        let email = self.session.member?.email
        var profileSubTitle: String? = email
        if let displayName = self.session.member?.fullName {
            profileSubTitle = isBlank(email) ? displayName : "\(displayName) (\(email!))"
        }
        
        let tier = self.session.member?.tier ?? .BASIC
        let providers = self.session.user?.providerData.map {$0.providerID} ?? ["password"]
        
        return [
            SettingsItem(id: 1, "Profile", profileSubTitle, destination: ProfileSettingsView()),
            SettingsItem(id: 2, "Notifications", destination: NotificationSettingsView()),
            SettingsItem(id: 3, "Subscription", tier.displayName, destination: SubscriptionSettingsView()),
            SettingsItem(id: 4,"Linked Accounts", destination: LinkedAccountsView(providers: providers).navigationBarTitle("Linked Accounts")),
            SettingsItem(id: 5,"Help", destination: HelpView(), setNavigationTitle: true),
            SettingsItem(id: 6,"Feedback", destination: FeedbackView(), setNavigationTitle: true),
            SettingsItem(id: 7,"Terms of Service", destination: TermsOfServiceView(), setNavigationTitle: false),
            SettingsItem(id: 8,"Privacy Policy", destination: PrivacyPolicyView(), setNavigationTitle: false),
        ]
    }
    
    var tableFooterView: some View {
        CactusButton("Log Out", .link).onTapGesture {
                self.isLoggingOut = true
        }
        .padding([.top, .bottom], Spacing.normal)
        .padding(.leading, Spacing.xsmall)
    }
    
    var logoutActionSheet: ActionSheet {
        ActionSheet(title: Text(.LogOut),
                    message: Text(.LogOutConfirm),
                    buttons: [
                        .destructive(Text(.LogOut), action: {
                            self.session.logout()
                        }),
                        .cancel()
                    ])
    }
    
    var body: some View {
        NavigationView {
            List(selection: self.$selectedItemId) {
                Section(footer: self.tableFooterView) {
                    ForEach(self.items) { item in
                        SettingsItemView(item: item, selectedId: self.$selectedItemId)
                            .tag(item.id)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .onAppear {
                UITableView.appearance().separatorStyle = .singleLine
                UITableView.appearance().separatorInset = .zero
            }
            .font(CactusFont.normal.font)
            .navigationBarTitle("Settings")
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            
            self.items.first!.destination
                .ifMatches(self.items.first!.setNavigationTitle) { content in
                content.navigationBarTitle(self.items.first!.title)
            }
            
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .actionSheet(isPresented: self.$isLoggingOut) { self.logoutActionSheet }
        
    }
}

struct SettingsHome_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsHome().environmentObject(SessionStore.mockLoggedIn())
                .previewDisplayName("Logged In (Light)")
            
            SettingsHome().environmentObject(SessionStore.mockLoggedIn())
                .colorScheme(.dark)
                .previewDisplayName("Logged In (Dark)")
        }
//        .background(named: .Background)
        
    }
}
