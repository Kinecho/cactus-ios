//
//  CactusElementPageViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/30/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class CactusElementPageViewController: UIPageViewController {
    var pageControl: UIPageControl?
    var screens: [CactusElementDetailViewController] = []
    var initialElement: CactusElement?
    var backgroundColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.createPages()
        self.setupPages()
        self.configurePageControl()
        
        self.view.backgroundColor = backgroundColor        
    }

    func setupPages() {
        var elementVc: CactusElementDetailViewController?
        if let element = self.initialElement {
            elementVc = self.screens.first { (vc) -> Bool in
                return vc.element == element
            }
        }
        
        if let first = (elementVc ?? self.screens.first) {
            self.setViewControllers([first], direction: .forward, animated: false, completion: nil)
        }
    }
    
    func createPages() {
        let pages = CactusElement.orderedElements.map({ (element) -> CactusElementDetailViewController in
            return createDetailView(element)
        })
        self.screens = pages
    }
    
    func createDetailView(_ element: CactusElement) -> CactusElementDetailViewController {
        let vc = CactusElementDetailViewController()
        vc.element = element
        vc.hideCloseButton = true
        vc.view.frame = self.view.bounds
        return vc
    }

    func configurePageControl() {
        //note: position is dictated by viewDidLayoutSubviews with constraints
        if self.pageControl != nil {
           self.pageControl?.removeFromSuperview()
        }
        
        let pageControl =  UIPageControl(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.backgroundColor = .clear
        pageControl.numberOfPages = self.screens.count
        pageControl.currentPage = self.screens.firstIndex(where: { $0.element == self.initialElement}) ?? 0
        pageControl.tintColor = CactusColor.darkPink
        pageControl.pageIndicatorTintColor = CactusColor.lightBlue
        pageControl.currentPageIndicatorTintColor = CactusColor.darkPink

        self.pageControl = pageControl
        self.view.addSubview(pageControl)
        pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
        pageControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension CactusElementPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //        handle previous
        guard let vc = viewController as? CactusElementDetailViewController else {return nil}
        guard let viewControllerIndex = self.screens.firstIndex(of: vc) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard self.screens.count > previousIndex else { return nil }
        
        return self.screens[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //handle next
        guard let vc = viewController as? CactusElementDetailViewController else {return nil}
        guard let viewControllerIndex = self.screens.firstIndex(of: vc) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < self.screens.count else { return nil }
        guard self.screens.count > nextIndex else { return nil }
        
        return self.screens[nextIndex]
        
    }
}

extension CactusElementPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let firstViewController = self.viewControllers?.first as? CactusElementDetailViewController,
            let index = self.screens.firstIndex(of: firstViewController) {
            self.pageControl?.currentPage = index
        }
    }
}
