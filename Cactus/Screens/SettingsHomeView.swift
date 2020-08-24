//
//  SettingsHome.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct SettingsItem: Identifiable {
    
    var id = UUID()
    var title: String
    var subtitle: String?
    var destination: AnyView
    var setNavigationTitle: Bool
    init<V>(_ title: String, _ subtitle: String?=nil, destination: V, setNavigationTitle: Bool=true) where V: View {
        self.title = title
        self.subtitle = subtitle
        self.destination = AnyView(destination)
        self.setNavigationTitle = setNavigationTitle
    }
}

struct SettingsItemView: View {
    var item: SettingsItem
    
    var body: some View {
        NavigationLink(destination: self.item.destination
            .ifMatches(self.item.setNavigationTitle) { content in
                content.navigationBarTitle(item.title)
            }
        ) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.title)
                    if item.subtitle != nil {
                        Text(item.subtitle!).font(CactusFont.normal(FontSize.subTitle).font)
                    }
                }
            }
        }
        .minHeight(44)
        .padding()
        .listRowInsets(EdgeInsets())
    }
}

struct SettingsHome: View {
    @EnvironmentObject var session: SessionStore
    @State var isLoggingOut: Bool = false
    var items: [SettingsItem] {
        let email = self.session.member?.email
        var profileSubTitle: String? = email
        if let displayName = self.session.member?.fullName {
            profileSubTitle = isBlank(email) ? displayName : "\(displayName) (\(email!))"
        }
        
        let tier = self.session.member?.tier ?? .BASIC
        let providers = self.session.user?.providerData.map {$0.providerID} ?? ["password"]
        
        return [
            SettingsItem("Profile", profileSubTitle, destination: ProfileSettingsView()),
            SettingsItem("Notifications", destination: NotificationSettingsView()),
            SettingsItem("Subscription", tier.displayName, destination: SubscriptionSettingsView()),
            SettingsItem("Linked Accounts", destination: LinkedAccountsView(providers: providers).navigationBarTitle("Linked Accounts")),
            SettingsItem("Help", destination: HelpView(), setNavigationTitle: true),
            SettingsItem("Feedback", destination: FeedbackView(), setNavigationTitle: true),
            SettingsItem("Terms of Service", destination: TermsOfServiceView(), setNavigationTitle: false),
            SettingsItem("Privacy Policy", destination: PrivacyPolicyView(), setNavigationTitle: false),
        ]
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(footer: CactusButton("Log Out", .buttonSecondary).onTapGesture {
                        self.isLoggingOut = true
                }.padding([.top, .bottom], Spacing.large)
                ) {
                    ForEach(self.items) { item in
                        SettingsItemView(item: item)
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
        }
        .actionSheet(isPresented: self.$isLoggingOut) { () -> ActionSheet in
            ActionSheet(title: Text(.LogOut),
                        message: Text(.LogOutConfirm),
                        buttons: [
                            .destructive(Text(.LogOut), action: {
                                self.session.logout()
                            }),
                            .cancel()
                        ])
        }
        
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
        .background(named: .Background)
        
    }
}
