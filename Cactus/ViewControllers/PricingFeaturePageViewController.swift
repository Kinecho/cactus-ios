//
//  PricingFeaturePageViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 4/15/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class PricingFeaturePageViewController: UIPageViewController {

    var pageControl: UIPageControl?
    var screens = [PricingFeatureItemViewController]()
    var features: [PricingFeature] = [] {
        didSet {
            self.configureFeatures()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        self.configureFeatures()
    }
    
    func configureFeatures() {
        guard self.isViewLoaded else {
            return
        }
        self.createPages()
        self.setupPages()
        self.configurePageControl()
    }

    func createPages() {
        let pages = self.features.compactMap { (feature) -> PricingFeatureItemViewController? in
            guard let featureVc = ScreenID.PricingFeatureItem.getViewController() as? PricingFeatureItemViewController else {
                return nil
            }
            featureVc.feature = feature
            return featureVc
        }
        self.screens = pages
    }
    
    func setupPages() {
        if let first = (self.screens.first) {
            self.setViewControllers([first], direction: .forward, animated: false, completion: nil)
        }
    }

    func configurePageControl() {
        //note: position is dictated by viewDidLayoutSubviews with constraints
        if self.pageControl != nil {
           self.pageControl?.removeFromSuperview()
        }
        
        let pageControl =  UIPageControl(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.backgroundColor = .clear
        pageControl.numberOfPages = self.screens.count
        pageControl.currentPage = 0
        pageControl.tintColor = CactusColor.darkestGreen
        pageControl.pageIndicatorTintColor = CactusColor.darkestGreen
        pageControl.currentPageIndicatorTintColor = CactusColor.green

        self.pageControl = pageControl
        self.view.addSubview(pageControl)
        pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        pageControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}

extension PricingFeaturePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
           //        handle previous
           guard let vc = viewController as? PricingFeatureItemViewController else {return nil}
           guard let viewControllerIndex = self.screens.firstIndex(of: vc) else { return nil }
           
           let previousIndex = viewControllerIndex - 1
           
           guard previousIndex >= 0 else { return nil }
           guard self.screens.count > previousIndex else { return nil }
           
           return self.screens[previousIndex]
           
       }
       
       func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
           //handle next
           guard let vc = viewController as? PricingFeatureItemViewController else {return nil}
           guard let viewControllerIndex = self.screens.firstIndex(of: vc) else { return nil }
           
           let nextIndex = viewControllerIndex + 1
           
           guard nextIndex < self.screens.count else { return nil }
           guard self.screens.count > nextIndex else { return nil }
           
           return self.screens[nextIndex]
           
       }
}

extension PricingFeaturePageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let firstViewController = self.viewControllers?.first as? PricingFeatureItemViewController,
            let index = self.screens.firstIndex(of: firstViewController) {
            self.pageControl?.currentPage = index
        }
    }
}
