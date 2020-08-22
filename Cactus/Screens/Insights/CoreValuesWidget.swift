//
//  CoreValuesWidget.swift
//  Cactus
//
//  Created by Neil Poulin on 8/18/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import SwiftUIX
import NoveFeatherIcons

struct CoreValuesWidget: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    
    @State var showAssessment: Bool = false
    @State var showMoreActions: Bool = false
    
    var memberCoreValues: [CoreValue]? {
        self.session.member?.tier.isPaidTier == true ? self.session.member?.coreValues : nil
    }
    
    func getBackground(geo: GeometryProxy) -> some View {
        if self.memberCoreValues?.isEmpty == false {
            return NamedColor.CardBackground.color.eraseToAnyView()
        }
        
        return ZStack {
            Image(CactusImage.grainy.rawValue)
                .resizable(resizingMode: .tile)
                .opacity(0.5)
                .background(NamedColor.Dolphin.color)
            
            Image(CactusImage.cvBlob.rawValue)
                .resizable()
                .width(140)
                .height(140)
                .aspectRatio(contentMode: .fit)
                .offset(x: -geo.size.width/2, y: -40)
            
            Image(CactusImage.vBackground.rawValue)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fill)
                .width(120)
                .height(120)
                .foregroundColor(NamedColor.Magenta.color)
                .offset(x: geo.size.width * 1/2, y: -50)
        }.eraseToAnyView()
    }
    
    var moreActions: ActionSheet {
        ActionSheet(title: Text("Core Values"), buttons: [
            .default(Text("Retake Assessment"), action: {
                self.showAssessment = true
            }),
            .cancel(Text("Cancel"))
        ])
    }
    
    var unlockedBody: some View {
        if let coreValues = self.memberCoreValues {
            return Group {
                VStack {
                    HStack(alignment: .center) {
                        Text("Core Values").font(CactusFont.bold(.title))
                            .foregroundColor(named: .TextDefault)
                        Spacer()
                        MoreActionsButton(active: self.$showMoreActions)
                    }
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: Spacing.normal) {
                            
                            VStack(alignment: .leading, spacing: Spacing.small) {
                                ForEach(coreValues, id: \.hashValue) { value in
                                    Text("\(value)")
                                        .font(CactusFont.bold(.normal))
                                        .foregroundColor(named: .Heading3Text)
                                }
                            }
                        }
                        Spacer()
                        Image(CoreValueBlob.forCoreValues(self.memberCoreValues ?? []).image.rawValue)
                        .resizable()
                            .aspectRatio(contentMode: .fit)
                        .maxHeight(160)
                    }
                }
            }.eraseToAnyView()
        }
        
        return Group {
            VStack(alignment: .leading, spacing: Spacing.normal) {
                VStack(alignment: .leading) {
                    Text("What are your core values?").font(CactusFont.bold(.title))
                    Text("Discover what drives your life decisions and deepest needs.")
                }
                CactusButton("Take the Assessment", .buttonSecondary).onTapGesture {
                    self.showAssessment = true
                }
            }
            
        }.eraseToAnyView()
    }
    
    var lockedBody: some View {
        return HStack(alignment: .top) {
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
                    .fixedSize(horizontal: false, vertical: true)
                Text("Discover what drives your life decisions and deepest needs.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(NamedColor.White.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if self.session.member?.tier == .PLUS {
                self.unlockedBody
            } else {
                self.lockedBody
            }
            
        }
        .foregroundColor(NamedColor.White.color)
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(Spacing.normal)
        .fixedSize(horizontal: false, vertical: true)
        .background(GeometryReader { geo in
            self.getBackground(geo: geo)
        })
        .cornerRadius(CornerRadius.normal)
        .border(NamedColor.BorderLight.color, cornerRadius: CornerRadius.normal, style: .continuous, width: 1)
        .onTapGesture {
            if (self.memberCoreValues?.isEmpty ?? true) == true{
                self.showAssessment = true
            }
        }
        .sheet(isPresented: self.$showAssessment) {
            CoreValuesAssessmentWebView(onClose: {
                self.showAssessment = false
            }).environmentObject(self.session)
                .environmentObject(self.checkout)
        }
        .actionSheet(isPresented: self.$showMoreActions, content: {
            self.moreActions
        })
    }
    
}

struct CoreValuesWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ///BASIC
            CoreValuesWidget()
                .padding()
                .background(named: .Background)
                .environmentObject(SessionStore.mockLoggedIn(tier: .BASIC))
                .environmentObject(CheckoutStore.mock())
                .colorScheme(.dark)
                .previewLayout(.fixed(width: 440, height: 130))
                .previewDisplayName("BASIC User - Locked (Dark)")
            
            CoreValuesWidget()
                .padding()
                .background(named: .Background)
                .environmentObject(SessionStore.mockLoggedIn(tier: .BASIC))
                .environmentObject(CheckoutStore.mock())
                .colorScheme(.light)
                .previewLayout(.fixed(width: 440, height: 200))
                .previewDisplayName("BASIC User - Locked (Light)")
            
            ///PLUS - No values
            CoreValuesWidget()
                .padding()
                .background(named: .Background)
                .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .environmentObject(CheckoutStore.mock())
                .colorScheme(.dark)
                .previewLayout(.fixed(width: 440, height: 200))
                .previewDisplayName("PLUS User - No Core Values (Dark)")
            
            CoreValuesWidget()
                .padding()
                .background(named: .Background)
                .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .environmentObject(CheckoutStore.mock())
                .colorScheme(.light)
                .previewLayout(.fixed(width: 440, height: 200))
                .previewDisplayName("PLUS User - No Core Values (Light)")
            
            
            ///PLUS - With values
            CoreValuesWidget()
                .padding()
                .previewLayout(.fixed(width: 440, height: 300))
                .background(named: .Background)
                .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS, configMember: { member in
                    member.coreValues = ["Security", "Personal Growth", "Altruism"]
                }))
                .environmentObject(CheckoutStore.mock())
                .colorScheme(.dark)
                
                .previewDisplayName("PLUS User - Has Core Values (Dark)")
            
            CoreValuesWidget()
                .padding()
                .previewLayout(.fixed(width: 440, height: 300))
                .background(named: .Background)
                .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS, configMember: { member in
                    member.coreValues = ["Security", "Personal Growth", "Altruism"]
                }))
                
                .colorScheme(.light)
                
                .previewDisplayName("PLUS User - Has Core Values (Light)")
        }
    }
}
