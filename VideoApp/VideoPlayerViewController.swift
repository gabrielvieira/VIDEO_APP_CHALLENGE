//
//  VideoPlayerViewController.swift
//  VideoApp
//
//  Created by Gabriel Vieira on 4/8/17.
//  Copyright © 2017 Gabriel Vieira. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayerViewController: AVPlayerViewController {

    open var titleLabel = UILabel()
    open var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let screenSize: CGRect = UIScreen.main.bounds
        
        titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 30, width: screenSize.width, height: 25))
//        titleLabel.text = "VIDEO"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTitle(title : String) {
        
        titleLabel.text = title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.player?.pause()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
