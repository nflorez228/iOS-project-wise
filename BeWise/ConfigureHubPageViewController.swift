//
//  ConfigureHubPageViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/4/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration.CaptiveNetwork

class ConfigureHubPageViewController: UIPageViewController {

    
    weak var configureHubDelegate: ConfigureHubPageViewControllerDelegate?
    
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newColoredViewController(color: "First"),self.newColoredViewController(color: "Second"),self.newColoredViewController(color: "Third"),self.newColoredViewController(color: "Four"),self.newColoredViewController(color: "Fived")]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderedViewControllers = [self.newColoredViewController(color: "First"),self.newColoredViewController(color: "Second"),self.newColoredViewController(color: "Third"),self.newColoredViewController(color: "Four"),self.newColoredViewController(color: "Fived")]
        let SSID: String = fethSSIDInfo()
        if SSID==""
        {
            print("empty")
            orderedViewControllers = [self.newColoredViewController(color: "First"),self.newColoredViewController(color: "Second"),self.newColoredViewController(color: "Third"),self.newColoredViewController(color: "Four"),self.newColoredViewController(color: "Five")]
        }
        
        print("SSID")
        print(fethSSIDInfo())

        // Do any additional setup after loading the view.
        dataSource = self
        delegate = self
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        
        configureHubDelegate?.configureHubPageViewController(configureHubPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
    
    }
    
    func fethSSIDInfo() -> String {
        var currentSSID = ""
        if let interfaces = CNCopySupportedInterfaces(){
            for i in 0..<CFArrayGetCount(interfaces){
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                if unsafeInterfaceData != nil{
                    let interfaceData = unsafeInterfaceData! as NSDictionary
                    currentSSID = interfaceData["SSID"] as! String
                }
            }
        }
        return currentSSID
    }
    
    
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first, let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    private func newColoredViewController(color: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(color)ViewController")
    }
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController, direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            configureHubDelegate?.configureHubPageViewController(configureHubPageViewController: self, didUpdatePageIndex: index)
        }
    }
    
}

extension ConfigureHubPageViewController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        //guard orderedViewControllersCount != nextIndex else {
          //  return orderedViewControllers.first
        //}
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

extension ConfigureHubPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstviewcontroller = viewControllers?.first, let firstViewControllerIndex = orderedViewControllers.index(of: firstviewcontroller) else {
            return 0
        }
        return firstViewControllerIndex
    }
    
}

protocol ConfigureHubPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func configureHubPageViewController(configureHubPageViewController: ConfigureHubPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func configureHubPageViewController(configureHubPageViewController: ConfigureHubPageViewController,
                                    didUpdatePageIndex index: Int)
    
}

