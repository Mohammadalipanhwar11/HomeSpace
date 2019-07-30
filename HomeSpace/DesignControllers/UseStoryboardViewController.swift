//
//  UseStoryboardViewController.swift
//  Example
//
//  Created by Hirohisa Kawasaki on 2018/08/23.
//  Copyright © 2018 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import PageController
import FirebaseFirestore

class UseStoryboardViewController: PageController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        menuBar.backgroundColor = .black
        menuBar.register(UINib(nibName: "CustomMenuBarCell", bundle: nil))
        menuBar.isAutoSelectDidEndUserInteractionEnabled = false
        delegate = self
        self.viewControllers = self.createViewControllers()

       // removeSwipeGesture()
    }
    func removeSwipeGesture(){
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
    
    

    override var frameForMenuBar: CGRect {
        let frame = super.frameForMenuBar

        return CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 150)
    }
    
 
    
    
    func createViewControllers() -> [UIViewController] {
        let names = ["Archive","New","Today","Tomorrow"]
        let top = adjustedContentInsetTop
        let bottom: CGFloat
        if #available(iOS 11.0, *) {
            bottom = 0
        } else {
            bottom = tabBarController?.tabBar.frame.height ?? 0
        }
        let contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
        let viewControllers = names.map { name -> ViewController in
            let viewController = storyboard?.instantiateViewController(withIdentifier: "new") as! ViewController
            viewController.title = name
           

            if viewController.view != nil {
                viewController.mainTaskTable?.scrollsToTop = false
                viewController.mainTaskTable?.contentInset = contentInset
            }
            
            return viewController
        }

        return viewControllers
    }
}

extension UseStoryboardViewController: PageControllerDelegate {
    func pageController(_ pageController: PageController, didChangeVisibleController visibleViewController: UIViewController, fromViewController: UIViewController?) {
        if pageController.visibleViewController == visibleViewController {
            print("visibleViewController is assigned pageController.visibleViewController")
        }
        
        if let viewController = fromViewController as? ViewController  {
            viewController.mainTaskTable?.scrollsToTop = false
        }
        if let viewController = visibleViewController as? ViewController  {
            viewController.mainTaskTable?.scrollsToTop = true
            let title = viewController.title!
            
        }
        
        
    }
    
    
    
    
}
