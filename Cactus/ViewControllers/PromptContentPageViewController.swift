//
//  PromptContentPageViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class PromptContentPageViewController: UIPageViewController {

    var promptContent: PromptContent!
    var activeIndex: Int = 0
    var pageControl: UIPageControl?
    
    fileprivate lazy var screens: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.configureScreens()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureScreens()
    }
    
    func configureScreens() {
        var screens: [UIViewController] = []
        self.promptContent.content.forEach({ (content) in
            if let screen = self.getContentViewController(content) {
                screens.append(screen)
            }
        })
        self.screens = screens
        
        if let firstVC = self.screens.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
        self.configurePageControl()
    }
    
    func getContentViewController(_ content: Content) -> UIViewController? {
        var viewController: UIViewController?
        print("content type is \(content.contentType)")
        switch content.contentType {
        case .text:
            let textViewController = TextContentViewController.loadFromNib()
            textViewController.content = content
            textViewController.promptContent = self.promptContent
            viewController = textViewController
        case .quote:
            print("Setting up quote view controller")
            let quoteViewController = QuoteContentViewController.loadFromNib()
            quoteViewController.content = content
            quoteViewController.promptContent = promptContent
            viewController = quoteViewController
        case .photo:
            print("Setting up photo view controller")
            let photoViewController = PhotoContentViewController.loadFromNib()
            photoViewController.content = content
            photoViewController.promptContent = promptContent
            viewController = photoViewController
        case .reflect:
            print("Setting up reflection screen")
            let reflectionViewController = ReflectContentViewController.loadFromNib()
            reflectionViewController.content = content
            reflectionViewController.promptContent = promptContent
            viewController = reflectionViewController
        default:
            print("PromptContentPageViewController: ContentType not handled: \(content.contentType)")
        }
        
        return viewController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let pageControl = self.pageControl {
            pageControl.translatesAutoresizingMaskIntoConstraints = false
//            let bottomConstraint = pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            let left = pageControl.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 20)
            let right = pageControl.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -20)
            let topConstraint = pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40)
//            bottomConstraint.isActive = true
            topConstraint.isActive = true
            left.isActive = true
            right.isActive = true
            view.addConstraints([
                topConstraint,
                left,
                right,
//                bottomConstraint
                ])
        }
    
    }
    
    func configurePageControl() {
        //note: position is dictated by viewDidLayoutSubviews with constraints
        if self.pageControl != nil {
            self.pageControl?.removeFromSuperview()
        }
//        let yPos = self.view.bounds.maxY - self.view.safeAreaInsets.top - 40
        let yPos = self.view.bounds.minY + self.view.safeAreaInsets.top + 20
        let pageControl =  UIPageControl(frame: CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 50))
        pageControl.backgroundColor = .clear
        pageControl.numberOfPages = self.screens.count
        pageControl.currentPage = 0
        pageControl.tintColor = CactusColor.darkestPink
        pageControl.pageIndicatorTintColor = CactusColor.pink
        pageControl.currentPageIndicatorTintColor = CactusColor.darkestPink
        
        self.pageControl = pageControl
        self.view.addSubview(pageControl)
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension PromptContentPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //        handle previous
        
        guard let viewControllerIndex = self.screens.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard self.screens.count > previousIndex else { return nil }
        
        return self.screens[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //handle next
        guard let viewControllerIndex = self.screens.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < self.screens.count else { return nil }
        guard self.screens.count > nextIndex else { return nil }
        
        return self.screens[nextIndex]
        
    }
}

extension PromptContentPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        print("pageViewCpontroller transition completed delegate called")
        if let firstViewController = self.viewControllers?.first,
            let index = self.screens.firstIndex(of: firstViewController) {
            print("setting pagecontroller index to \(index)")
            self.pageControl?.currentPage = index
        }
    }
}
