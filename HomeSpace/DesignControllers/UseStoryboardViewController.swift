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
import CodableFirebase

class UseStoryboardViewController: PageController {
    
    var names:[Group] = []{
        didSet{
            print(self.viewControllers)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Firestore.firestore().collection("groups")
            .order(by: "date", descending: true)
            .addSnapshotListener(includeMetadataChanges: true, listener: { (snap, err) in
                snap?.documentChanges.forEach({ (group) in
//                    if !group.document.metadata.hasPendingWrites{
                        let gID = group.document.documentID
                        let object = group.document.data()
                        print(object)
                        var groupData = try! FirestoreDecoder().decode(Group.self, from: object)
                        groupData.id = gID
                        switch group.type {
                        case .added:
                            let cont = self.createViewControllers(group: groupData) as! ViewController
                            cont.group = groupData
                            self.viewControllers.append(cont)
                            self.menuBar.selectedIndex = 0
//                            self.reloadPages(at: 0)
                            self.switchPage(AtIndex: 0)
                            Task.sharedSearch.append((groupData,[]))
                        case .modified:
                            let index = self.viewControllers.map({$0 as! ViewController}).firstIndex(where: {$0.group!.id == groupData.id})
//                            let cont = self.viewControllers[index!] as! ViewController
//                            cont.title = groupData.name
//                            cont.group = groupData
//                            cont.view.setNeedsDisplay()
                            self.viewControllers.remove(at: index!)
                            let cont = self.createViewControllers(group: groupData) as! ViewController
                            cont.group = groupData
                            self.viewControllers.insert(cont, at: index!)
                            self.menuBar.selectedIndex = index!
//                            self.reloadPages(at: index!)
                            self.switchPage(AtIndex: index!)
                            
                            let gIndex = Task.sharedSearch.firstIndex(where: {$0.group.id == groupData.id})
                            if let i = gIndex{
                                let g = Task.sharedSearch[i]
                                let data = (groupData,g.tasks)
                                Task.sharedSearch[i] = data
                            }
                            

                        case .removed:
                            let index = self.viewControllers.map({$0 as! ViewController}).firstIndex(where: {$0.group!.id == groupData.id})
                            self.viewControllers.remove(at: index!)
                            self.menuBar.selectedIndex = index!
//                            self.reloadPages(at: index!)
                            self.switchPage(AtIndex: index!)
                            let gIndex = Task.sharedSearch.firstIndex(where: {$0.group.id == groupData.id})
                            Task.sharedSearch.remove(at: gIndex!)
                        }
//                    }

                })
            })
        
        
        
        
        
        
        menuBar.backgroundColor = .black
        
        menuBar.register(UINib(nibName: "CustomMenuBarCell", bundle: nil))
        menuBar.isAutoSelectDidEndUserInteractionEnabled = false
        delegate = self
        
        
        removeSwipeGesture()
        
//        taskManager.shared.getAllGroup { (gArr, err) in
//            self.names = gArr
//            self.viewControllers = self.createViewControllers()
//
//        }
        
    }
    func removeSwipeGesture(){
        let frame = super.frameForMenuBar
        
        let gest = UISwipeGestureRecognizer()
        let gest1 = UIPanGestureRecognizer()
        let gest2 = UITapGestureRecognizer()
        
        menuBar.addGestureRecognizer(gest)
        menuBar.addGestureRecognizer(gest1)
        menuBar.addGestureRecognizer(gest2)
        
        for view in self.menuBar.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
                subView.isUserInteractionEnabled = false
            }
        }
    }
    
    
    override var frameForMenuBar: CGRect {
        let frame = super.frameForMenuBar
        if UIDevice().userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
            case 2436:
                return CGRect(x: frame.minX, y: frame.minY - 30, width: frame.width, height: frame.height + 65)
            case 2688:
                return CGRect(x: frame.minX, y: frame.minY - 30, width: frame.width, height: frame.height + 65)
            case 1792:
                return CGRect(x: frame.minX, y: frame.minY - 30, width: frame.width, height: frame.height + 65)
            default:
                return CGRect(x: frame.minX, y: frame.minY , width: frame.width, height: 65)
            }
        }
        return CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
    }
    
    func createViewControllers() -> [UIViewController] {
        
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
            viewController.title = name.name
            viewController.group = name
            
            
            if viewController.view != nil {
                viewController.mainTaskTable?.scrollsToTop = false
                viewController.mainTaskTable?.contentInset = contentInset
            }
            
            return viewController
        }
        
        return viewControllers
    }
    
    func createViewControllers(group:Group) -> UIViewController {
        
        let top = adjustedContentInsetTop
        let bottom: CGFloat
        if #available(iOS 11.0, *) {
            bottom = 0
        } else {
            bottom = tabBarController?.tabBar.frame.height ?? 0
        }
        let contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
        let viewController = storyboard?.instantiateViewController(withIdentifier: "new") as! ViewController
        viewController.title = group.name
        viewController.group = group
        
        
        if viewController.view != nil {
            viewController.mainTaskTable?.scrollsToTop = false
            viewController.mainTaskTable?.contentInset = contentInset
        }
        
        return viewController
        
    }
}

extension UseStoryboardViewController: PageControllerDelegate {
    
    
    func pageController(_ pageController: PageController, didChangeVisibleController visibleViewController: UIViewController, fromViewController: UIViewController?) {
        if pageController.visibleViewController == visibleViewController
        {
            print("visibleViewController is assigned pageController.visibleViewController")
        }
        
        if let viewController = fromViewController as? ViewController  {
            viewController.mainTaskTable?.scrollsToTop = false
        }
        if let viewController = visibleViewController as? ViewController  {
            viewController.mainTaskTable?.scrollsToTop = true
            //            let title = viewController.title!
        }
    }
}
