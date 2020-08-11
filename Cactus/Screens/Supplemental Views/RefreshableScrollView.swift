//
//  RefreshableScrollView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct RefreshableScrollView<ROOTVIEW>: UIViewRepresentable where ROOTVIEW: View {
    
    var width: CGFloat, height: CGFloat
    let handlePullToRefresh: () -> Void
    let rootView: () -> ROOTVIEW
    @State private var contentView: UIHostingController<ROOTVIEW>?
    
    func makeCoordinator() -> Coordinator<ROOTVIEW> {
        Coordinator(self, rootView: rootView, handlePullToRefresh: handlePullToRefresh)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let control = UIScrollView()
        control.refreshControl = UIRefreshControl()
        control.refreshControl?.addTarget(context.coordinator, action:
            #selector(Coordinator.handleRefreshControl),
                                          for: .valueChanged)

        let childView = UIHostingController(rootView: rootView() )
        childView.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        control.addSubview(childView.view)
        return control
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let contentView = uiView.subviews.first { $0 is ROOTVIEW }
        contentView?.removeFromSuperview()
        let childView = UIHostingController(rootView: rootView() )
        childView.view.frame = CGRect(x: 0, y: 0, width: width, height: height)        
        uiView.addSubview(childView.view)
    }

    class Coordinator<ROOTVIEW>: NSObject where ROOTVIEW: View {
        var control: RefreshableScrollView
        var handlePullToRefresh: () -> Void
        var rootView: () -> ROOTVIEW

        init(_ control: RefreshableScrollView, rootView: @escaping () -> ROOTVIEW, handlePullToRefresh: @escaping () -> Void) {
            self.control = control
            self.handlePullToRefresh = handlePullToRefresh
            self.rootView = rootView
        }

        @objc func handleRefreshControl(sender: UIRefreshControl) {

            sender.endRefreshing()
            handlePullToRefresh()
           
        }
    }
}
