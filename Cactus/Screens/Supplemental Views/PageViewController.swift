//
//  PageViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    typealias UIViewType = UIPageControl
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = self.numberOfPages
        control.addTarget(
                    context.coordinator,
                    action: #selector(Coordinator.updateCurrentPage(sender:)),
                    for: .valueChanged)
        return control
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = self.currentPage
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var control: PageControl
        
        init(_ control: PageControl) {
            self.control = control
        }
        
        @objc func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}

struct PageViewController: UIViewControllerRepresentable {
    var controllers: [UIViewController]
    @Binding var currentPage: Int
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        return pageViewController
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers([self.controllers[currentPage]],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
    }
    
    typealias UIViewControllerType = UIPageViewController
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController
        
        init (_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }
        
        func pageViewController(
                    _ pageViewController: UIPageViewController,
                    viewControllerBefore viewController: UIViewController) -> UIViewController?
                {
                    guard let index = parent.controllers.firstIndex(of: viewController) else {
                        return nil
                    }
                    if index == 0 {
                        return nil
                    }
                    return parent.controllers[index - 1]
                }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController?
        {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == parent.controllers.count {
                return nil
            }
            return parent.controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.controllers.firstIndex(of: visibleViewController)
            {
                parent.currentPage = index
            }
        }
        
    }
    
    
    
}

struct PageViewController_Previews: PreviewProvider {
    struct StatePreview<Content: View>: View {
        @State var currentPage: Int = 0
        var content: (Binding<Int>) -> Content
        
        var body: some View {
            content(self.$currentPage)
        }
    }
    
    
    static var previews: some View {
        StatePreview { (currentPage) in
            PageViewController(controllers: [
                                UIHostingController(rootView: Text("Page 1")),
                                UIHostingController(rootView: Text("Page 2"))
                            ], currentPage: currentPage)
        }
        
    }
}
