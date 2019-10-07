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
    var prompt: ReflectionPrompt?
    var reflectionResponse: ReflectionResponse?
    var closeButton: UIButton?
    var journalDataSource: JournalFeedDataSource?
    
    fileprivate lazy var screens: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.configureScreens()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureScreens()
    }
    
    func goToNextPage(animated: Bool = true){
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: animated, completion: nil)
    }
    
    func goToPreviousPage(animated: Bool = true){
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: animated, completion: nil)
    }
    
    //    func configureNavbar() {
    //        guard let navBar = self.navigationController?.navigationBar else {return}
    //
    //        navBar.barStyle = .blackTranslucent
    //        navBar.isOpaque = false
    //        let closeButton = UIBarButtonItem()
    //
    //        closeButton.image = CactusImage.close.getImage()
    //        closeButton.tintColor = CactusColor.darkGreen
    //        self.navigationItem.rightBarButtonItem = closeButton
    //    }
    
    func configureScreens() {
        var screens: [UIViewController] = []
        self.promptContent.content.forEach({ (content) in
            if let screen = self.getContentViewController(content) {
                screens.append(screen)
            }
        })
        
        let celebrate = CelebrateViewController.loadFromNib()
        celebrate.journalDataSource = self.journalDataSource
        screens.append(celebrate)
        self.screens = screens
        
        if let firstVC = self.screens.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
        self.configurePageControl()
        self.addCloseButton()
    }
    
    func getContentViewController(_ content: Content) -> UIViewController? {
        var viewController: UIViewController?
        print("content type is \(content.contentType)")
        
        var backgroundColor: UIColor? = CactusColor.lightBlue
        
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
            reflectionViewController.reflectionResponse = self.reflectionResponse
            reflectionViewController.delegate = self
            viewController = reflectionViewController
            backgroundColor = .white
        default:
            print("PromptContentPageViewController: ContentType not handled: \(content.contentType)")
        }
        
        viewController?.view.backgroundColor = backgroundColor
        
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
                right
                //                bottomConstraint
            ])
        }
        
    }
    
    @objc func dismissPrompt() {
        //        if self.isBeingPresented {
        self.dismiss(animated: true, completion: nil)
        //        }
    }
    
    func addCloseButton() {
        if self.closeButton != nil {
            self.closeButton?.removeFromSuperview()
        }
        let buttonWidth: CGFloat = 50
        let yPos = self.view.bounds.minY + self.view.safeAreaInsets.top + 20
        let xPos = self.view.bounds.maxX - 40 - self.view.safeAreaInsets.right
        let button = UIButton(frame: CGRect(x: xPos, y: yPos, width: 80, height: 80))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(CactusImage.close.getImage(), for: .normal)
        button.tintColor = CactusColor.darkGreen
        
        let contentInset: CGFloat = 10
        button.contentEdgeInsets = UIEdgeInsets.init(top: contentInset, left: contentInset, bottom: contentInset, right: contentInset)
        self.view.addSubview(button)
        
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        button.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
        button.addTarget(self, action: #selector(self.dismissPrompt), for: .primaryActionTriggered)
        
        self.closeButton = button
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
        pageControl.pageIndicatorTintColor = CactusColor.darkPink
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
        if let firstViewController = self.viewControllers?.first,
            let index = self.screens.firstIndex(of: firstViewController) {
            self.pageControl?.currentPage = index
        }
    }
}

extension PromptContentPageViewController: ReflectionContentViewControllerDelegate {
    func save(_ response: ReflectionResponse) {
        
    }
    
    func nextScreen() {
        self.goToNextPage()
    }
    
    
}
