//
//  CollectionViewController.swift
//  VideoApp
//
//  Created by Gabriel Vieira on 4/8/17.
//  Copyright © 2017 Gabriel Vieira. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import EMPageViewController

class CollectionViewController: UIViewController ,EMPageViewControllerDataSource, EMPageViewControllerDelegate {

    var pageViewController: EMPageViewController?
//    var 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pageViewController = EMPageViewController()
        
        // Or, for a vertical orientation
        // let pageViewController = EMPageViewController(navigationOrientation: .Vertical)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // Set the initially selected view controller
        // IMPORTANT: If you are using a dataSource, make sure you set it BEFORE calling selectViewController:direction:animated:completion
        let currentViewController = self.viewController(at: 0)!
        pageViewController.selectViewController(currentViewController, direction: .forward, animated: false, completion: nil)
        
        // Add EMPageViewController to the root view controller
        self.addChildViewController(pageViewController)
        self.view.insertSubview(pageViewController.view, at: 0) // Insert the page controller view below the navigation buttons
        pageViewController.didMove(toParentViewController: self)
        
        self.pageViewController = pageViewController
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        return self.viewController(at: 0)
        
    }
    
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        return self.viewController(at: 0)
    }
    
    func viewController(at index: Int) -> VideoPlayerViewController? {

        let player = AVPlayer.init(url: URL.init(string: "https://blicup.com/videoapp/video/wake.mp4")!)
        let playerController = VideoPlayerViewController()
        playerController.showsPlaybackControls = false
        playerController.player = player
        
        return playerController
    }
    
    func index(of viewController: VideoPlayerViewController) -> Int? {
//        if let greeting: String = viewController.titleLabel.text {
//            return self.greetings.index(of: greeting)
//        } else {
//            return nil
//        }

        return nil
    }
    
    
    // MARK: - EMPageViewController Delegate
    
    func em_pageViewController(_ pageViewController: EMPageViewController, willStartScrollingFrom startViewController: UIViewController, destinationViewController: UIViewController) {
        
        let startGreetingViewController = startViewController as! VideoPlayerViewController
        let destinationGreetingViewController = destinationViewController as! VideoPlayerViewController
        
        print("Will start scrolling from \(startGreetingViewController.titleLabel) to \(destinationGreetingViewController.titleLabel).")
    }
    
    func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startViewController: UIViewController, destinationViewController: UIViewController, progress: CGFloat) {
        let startGreetingViewController = startViewController as! VideoPlayerViewController
        let destinationGreetingViewController = destinationViewController as! VideoPlayerViewController
        
        // Ease the labels' alphas in and out
        let absoluteProgress = fabs(progress)
        startGreetingViewController.titleLabel.alpha = pow(1 - absoluteProgress, 2)
        destinationGreetingViewController.titleLabel.alpha = pow(absoluteProgress, 2)
        
        print("Is scrolling from \(startGreetingViewController.titleLabel) to \(destinationGreetingViewController.titleLabel) with progress '\(progress)'.")
    }
    
    func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        let startViewController = startViewController as! VideoPlayerViewController?
        let destinationViewController = destinationViewController as! VideoPlayerViewController
        
         }
    
}


