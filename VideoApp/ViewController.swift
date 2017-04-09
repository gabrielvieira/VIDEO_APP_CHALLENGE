//
//  ViewController.swift
//  VideoApp
//
//  Created by Gabriel Vieira on 4/8/17.
//  Copyright © 2017 Gabriel Vieira. All rights reserved.
//

import UIKit
import pop
import Alamofire
import AlamofireObjectMapper
import SDWebImage
import AVKit
import AVFoundation
import EMPageViewController

class ViewController: UIViewController {

    var sumView : UIImageView!
    var playView : UIImageView!
    var logoView : UIImageView!
    var searchButton : UIButton!
    var collectionView : UICollectionView! = nil
    var pageViewController: EMPageViewController?
    var scrollView: UIScrollView!
    var containerView = UIView()
    var pageControllerVisible = false
    var cachePlayer : AVPlayer!
    var collectionViewIndex = 0
    var videos : [Video] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareScrollView()
        prepareSubViews()
        prepareCollectionView()
        self.view.backgroundColor = Color.blue
        getVideos()
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
         return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func prepareScrollView(){
        
        scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        scrollView.delegate = self
        scrollView.contentSize = CGSize.init(width: view.frame.width, height: view.frame.height )
        scrollView.bounces = true
        
        containerView = UIView()
        containerView.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
    }
    
    private func ajustContainerView(){
        
        scrollView.contentSize = CGSize.init(width: view.frame.width, height: 210 +  self.collectionView.collectionViewLayout.collectionViewContentSize.height + 20)
        scrollView.bounces = false
        
        containerView.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: 210 +  self.collectionView.collectionViewLayout.collectionViewContentSize.height + 20)
        
        print("gere")
        print(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
    }
    
    private func prepareCollectionView(){
        
        let collectionFrame = CGRect.init(x: 0, y: view.frame.height, width: view.frame.width, height: 1000)
        
        collectionView = UICollectionView.init(frame: collectionFrame, collectionViewLayout: UICollectionViewFlowLayout.init())
        self.containerView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "VideoCell")
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
    }

    func preparePageController(){
    
        let pageViewController = EMPageViewController()
        pageViewController.scrollView.bounces = false
        // Or, for a vertical orientation
        // let pageViewController = EMPageViewController(navigationOrientation: .Vertical)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // Set the initially selected view controller
        // IMPORTANT: If you are using a dataSource, make sure you set it BEFORE calling selectViewController:direction:animated:completion
        let currentViewController = self.viewController(at: collectionViewIndex)!
        pageViewController.selectViewController(currentViewController, direction: .forward, animated: false, completion: nil)
        
        // Add EMPageViewController to the root view controller
        self.addChildViewController(pageViewController)
//        self.view.insertSubview(pageViewController.view, at: 0) // Insert the page controller view below the navigation buttons
        self.view.addSubview(pageViewController.view)
        
        pageViewController.didMove(toParentViewController: self)
        
        self.pageViewController = pageViewController
        pageControllerVisible = true
    }
    
    private func prepareSubViews(){
        
        //set logo at center of screen and use as position reference
        logoView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 277, height: 68))
        logoView.image = UIImage.init(named: "LOGO_TEXT")
        logoView.center.x = self.view.center.x
        logoView.center.y = self.view.center.y
        self.containerView.addSubview(logoView)
        
        //params for sum icon
        let sumSize = 75.0
        let sumYposition = Double(self.view.center.y) - Double(sumSize/2) - Double(logoView.frame.height/2) - 75

        sumView = UIImageView.init(frame: CGRect.init(x: 0.0, y: sumYposition, width: sumSize, height: sumSize))
        sumView.image = UIImage.init(named: "SUM")
        sumView.center.x = self.view.center.x
        
        self.containerView.addSubview(sumView)
        
        if let rotateAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            
            rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            rotateAnimation.toValue = (M_PI * 2);
            rotateAnimation.duration = 50
            rotateAnimation.repeatForever = true
            self.sumView.layer.pop_add(rotateAnimation, forKey: "rotate")
        }
        
        //play icon inside sumview
        let playSize = 14
        
        playView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: playSize, height: playSize))
        playView.image = UIImage.init(named: "PLAY_BUTTON")
        playView.center.x = sumView.center.x
        playView.center.y = sumView.center.y
        self.containerView.addSubview(playView)
        
        //search button
        let buttomHeight = 47.0
        let buttomWidth = 210.0
        let buttomYposition = Double(self.view.center.y) - Double(buttomHeight/2) + Double(logoView.frame.height/2) + 50
        
        searchButton = UIButton.init(frame: CGRect.init(x: 0, y: buttomYposition, width: buttomWidth, height: buttomHeight))
        searchButton.layer.cornerRadius = CGFloat(buttomHeight/2); // this value vary as per your desire
        searchButton.clipsToBounds = true;
        searchButton.setTitle("Search for videos", for: .normal)
        searchButton.titleLabel?.textColor = Color.gray
        searchButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        searchButton.backgroundColor = Color.darkBlue
        searchButton.center.x = self.view.center.x
        
        searchButton.addTarget(self, action:  #selector(self.searchVideos), for: .touchUpInside)
        searchButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
        
        let searchIcon = UIImageView.init(frame: CGRect.init(x: 25, y: 17, width: 15, height: 15))
        searchIcon.image = UIImage.init(named: "SEARCH_ICON")
        searchButton.addSubview(searchIcon)
        
        self.containerView.addSubview(searchButton)
    }
    
    @objc private func searchVideos(){
        
        let scaleSmallAnimation = POPBasicAnimation(propertyNamed:kPOPLayerScaleXY)
        scaleSmallAnimation?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleSmallAnimation?.toValue = CGSize.init(width: 0.92, height: 0.92)
        scaleSmallAnimation?.duration = 0.2
        self.searchButton.layer.pop_add(scaleSmallAnimation, forKey: "layerScaleSmallAnimation")

        
        scaleSmallAnimation?.completionBlock = {(animation, finished) in
            
            let scaleBigAnimation = POPSpringAnimation(propertyNamed:kPOPLayerScaleXY)
            scaleBigAnimation?.velocity = CGSize.init(width: 3, height: 3)
            scaleBigAnimation?.toValue = CGSize.init(width: 1, height: 1)
            scaleBigAnimation?.springBounciness = 15
            self.searchButton.layer.pop_add(scaleBigAnimation, forKey: "layerScaleSpringAnimation")
            
            scaleBigAnimation?.completionBlock = {(animation, finished) in
                self.showCollectionAnimated()
            }
        }
    }

    private func showCollectionAnimated(){
        
        let animationDuration = 0.3
        
        //sum and player icon animation
        let moveSumToTop = POPBasicAnimation(propertyNamed:kPOPLayerPositionY)
        moveSumToTop?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        moveSumToTop?.toValue = 100
        moveSumToTop?.duration = animationDuration
        self.sumView.layer.pop_add(moveSumToTop, forKey: "moveToTop")
        self.playView.layer.pop_add(moveSumToTop, forKey: "moveToTop")
        
        //scale and move logo to top
        let moveLogoToTop = POPBasicAnimation(propertyNamed:kPOPLayerPositionY)
        moveLogoToTop?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        moveLogoToTop?.toValue = 180
        moveLogoToTop?.duration = animationDuration
        
        let scaleSmallAnimation = POPBasicAnimation(propertyNamed:kPOPLayerScaleXY)
        scaleSmallAnimation?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleSmallAnimation?.toValue = CGSize.init(width: 0.6, height: 0.6)
        scaleSmallAnimation?.duration = animationDuration
    
        self.logoView.layer.pop_add(scaleSmallAnimation, forKey: "layerScaleSmallAnimation")
        self.logoView.layer.pop_add(moveLogoToTop, forKey: "moveToTop")
 
        //fade search button
        let fadeAnimation = POPBasicAnimation(propertyNamed:kPOPViewAlpha)
        fadeAnimation?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        fadeAnimation?.fromValue = 1.0
        fadeAnimation?.duration = 0.2
        fadeAnimation?.toValue = 0.0
        self.searchButton.pop_add(fadeAnimation, forKey: "fade")
        
        
//        scroll collection view to top
        let moveCollectionToTop = POPBasicAnimation(propertyNamed:kPOPLayerPositionY)
        moveCollectionToTop?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        moveCollectionToTop?.toValue = 710
        moveCollectionToTop?.duration = animationDuration
        self.collectionView.layer.pop_add(moveCollectionToTop, forKey: "moveToTop")
    
//        playVideo()
    }
    
    private func getVideos(){
    
        Alamofire.request(Config.baseURL).responseArray { (response: DataResponse<[Video]>) in
        
            let result = response.result.value

            if let result = result{
                self.videos = result
                self.collectionView.reloadData()
                self.ajustContainerView()
            }
        }
    }
    
    private func playVideo() {
    
        let player = AVPlayer.init(url: URL.init(string: "https://blicup.com/videoapp/video/wake.mp4")!)
        
        let playerController = VideoPlayerViewController()
        playerController.showsPlaybackControls = false
        playerController.player = player
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2) ) {
            self.present(playerController, animated: false) {
                player.play()
            }
        }
        

        
    }
}

extension ViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
        
        let video =  videos[indexPath.row]
        
        cell.name.text = video.name?.uppercased()
        cell.background.sd_setImage(with: URL(string: video.thumb!), placeholderImage: nil)
        cell.backgroundColor = Color.darkBlue
        
        return cell
    }
}

extension ViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! VideoCell
        let video = self.videos[indexPath.row]
        
        self.cachePlayer = AVPlayer.init(url: URL.init(string: video.url!)!)
        
        let scaleSmallAnimation = POPBasicAnimation(propertyNamed:kPOPLayerScaleXY)
        scaleSmallAnimation?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleSmallAnimation?.toValue = CGSize.init(width: 0.92, height: 0.92)
        scaleSmallAnimation?.duration = 0.2
        cell.layer.pop_add(scaleSmallAnimation, forKey: "layerScaleSmallAnimation")
        
        
        scaleSmallAnimation?.completionBlock = {(animation, finished) in
            
            let scaleBigAnimation = POPSpringAnimation(propertyNamed:kPOPLayerScaleXY)
            scaleBigAnimation?.velocity = CGSize.init(width: 3, height: 3)
            scaleBigAnimation?.toValue = CGSize.init(width: 1, height: 1)
            scaleBigAnimation?.springBounciness = 15
            cell.layer.pop_add(scaleBigAnimation, forKey: "layerScaleSpringAnimation")
            
            scaleBigAnimation?.completionBlock = {(animation, finished) in
//                
                let tempView = UIImageView()
                tempView.frame = cell.frame
                tempView.image = cell.background.image
                tempView.frame.origin.y = tempView.frame.origin.y + collectionView.frame.origin.y - self.scrollView.contentOffset.y
                self.view.addSubview(tempView)
                
                UIView.animate(withDuration: 1, animations: { 
                     tempView.frame = self.view.frame
                    
                }, completion: { (finished) in
                    
                    self.preparePageController()
                    tempView.removeFromSuperview()
                })
            }
        }
        
        self.collectionViewIndex = indexPath.row
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (self.view.frame.width - (3 * 30)) / 2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //        let leftRightInset = view.frame.size.width / 16.0
        
        return UIEdgeInsetsMake(20, 30, 20, 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ViewController : EMPageViewControllerDataSource{
    
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if (collectionViewIndex - 1 < 0) {
            return nil
        }
        
        if let afterViewController = self.viewController(at: collectionViewIndex - 1)
        {
            return afterViewController
        }
        else{
            return nil
        }
        
    }
    
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if (collectionViewIndex + 1 >= self.videos.count) {
            return nil
        }
        
        if let afterViewController = self.viewController(at: collectionViewIndex + 1)
        {
            return afterViewController
        }
        else{
            return nil
        }
    }
    
    func viewController(at index: Int) -> VideoPlayerViewController? {
        
        if (self.videos.count == 0) || (collectionViewIndex < 0) || (index >= self.videos.count) {
            return nil
        }
        
        let video = self.videos[index]
        
        let player = AVPlayer.init(url: URL.init(string: video.url!)!)
    
        let playerController = VideoPlayerViewController()
        playerController.showsPlaybackControls = false
        playerController.index = index
        playerController.player = player
        
//        let str = video.name
//        
//        playerController.titleLabel.text = "GEREMIAS"
//        if pageControllerVisible {
//            playerController.player = player
//        }
//        else{
//            playerController.player = self.cachePlayer
//        }
        
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
}

extension ViewController : EMPageViewControllerDelegate{
    
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
        
        if let index1 = startViewController?.index{
        
            if(index1 > destinationViewController.index){
                            collectionViewIndex -= 1
                        }
                        else{
                            collectionViewIndex += 1
                        }
        }
        
//        if(startViewController.index > destinationViewController.index){
//            collectionViewIndex += 1
//        }
//        else{
//            collectionViewIndex -= 1
//        }
        
    }
}


