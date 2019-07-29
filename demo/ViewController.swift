//
//  ViewController.swift
//  demo
//
//  Created by Johan Halin on 12/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController {
    let autostart = true
    
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)

    // MARK: - UIViewController
    
    init() {
        if let trackUrl = Bundle.main.url(forResource: "dist", withExtension: "m4a") {
            guard let audioPlayer = try? AVAudioPlayer(contentsOf: trackUrl) else {
                abort()
            }
            
            self.audioPlayer = audioPlayer
        } else {
            abort()
        }
        
        let startButtonText =
            "\"some demo\"\n" +
                "by dekadence\n" +
                "\n" +
                "programming and music by ricky martin\n" +
                "\n" +
                "presented at some party 2018\n" +
                "\n" +
        "tap anywhere to start"
        self.startButton = UIButton.init(type: UIButton.ButtonType.custom)
        self.startButton.setTitle(startButtonText, for: UIControl.State.normal)
        self.startButton.titleLabel?.numberOfLines = 0
        self.startButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.startButton.backgroundColor = UIColor.black
        
        super.init(nibName: nil, bundle: nil)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControl.Event.touchUpInside)
        
        self.view.backgroundColor = .black
        
        self.qtFoolingBgView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // barely visible tiny view for fooling Quicktime player. completely black images are ignored by QT
        self.view.addSubview(self.qtFoolingBgView)
        
        if !self.autostart {
            self.view.addSubview(self.startButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.audioPlayer.prepareToPlay()
    }

    let testView1 = UIView()
    let testView2 = UIView()
    let testView3 = UIView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.qtFoolingBgView.frame = CGRect(
            x: (self.view.bounds.size.width / 2) - 1,
            y: (self.view.bounds.size.height / 2) - 1,
            width: 2,
            height: 2
        )

        self.testView1.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.testView1.backgroundColor = .red
        self.testView1.alpha = 0
        self.view.addSubview(self.testView1)

        self.testView2.frame = CGRect(x: 100, y: 0, width: 100, height: 100)
        self.testView2.backgroundColor = .green
        self.testView2.alpha = 0
        self.view.addSubview(self.testView2)

        self.testView3.frame = CGRect(x: 200, y: 0, width: 100, height: 100)
        self.testView3.backgroundColor = .blue
        self.testView3.alpha = 0
        self.view.addSubview(self.testView3)

        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.autostart {
            start()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.audioPlayer.stop()
    }
    
    // MARK: - Private
    
    @objc
    fileprivate func startButtonTouched(button: UIButton) {
        self.startButton.isUserInteractionEnabled = false
        
        // long fadeout to ensure that the home indicator is gone
        UIView.animate(withDuration: 4, animations: {
            self.startButton.alpha = 0
        }, completion: { _ in
            self.start()
        })
    }
    
    fileprivate func start() {
        self.audioPlayer.play()
        
        scheduleEvents()
    }
    
    private func scheduleEvents() {
        let bpm = 140.0
        let barLength = (120.0 / bpm) * 2.0
        let tickLength = barLength / 16.0
        
        let pattern1 = [1, 0, 0, 0, 0]
        let pattern1resets = [8, 28, 29, 45, 52, 58, 62, 69, 80]
        let pattern1off = [41, 42, 43, 44, 78, 81]
        
        let pattern2 = [0, 1, 0, 0, 1]
        let pattern2resets = [16, 20, 35, 45, 55, 56, 60, 65, 66, 80]
        let pattern2off = [33, 34, 73, 74, 75, 76, 77, 78, 79]
        
        let pattern3 = [0, 0, 1, 1, 0]
        let pattern3resets = [12, 24, 37, 45, 53, 59, 64, 74, 80]
        let pattern3off = [44, 70, 71, 72, 73]

        let endBar = 81

        var pattern1position = 0
        var pattern2position = 0
        var pattern3position = 0
        
        for bar in 0..<endBar {
            let barPosition = Double(bar) * barLength

            if pattern1resets.contains(bar) {
                pattern1position = 0
            }

            if pattern2resets.contains(bar) {
                pattern2position = 0
            }

            if pattern3resets.contains(bar) {
                pattern3position = 0
            }

            for tick in 0...15 {
                let tickPosition = barPosition + (Double(tick) * tickLength)
                
                if !pattern1off.contains(bar) {
                    if pattern1[pattern1position] == 1 {
                        perform(#selector(pattern1event), with: nil, afterDelay: tickPosition)
                    }

                    pattern1position += 1
                    
                    if pattern1position >= pattern1.count {
                        pattern1position = 0
                    }
                }

                if !pattern2off.contains(bar) {
                    if pattern2[pattern2position] == 1 {
                        perform(#selector(pattern2event), with: nil, afterDelay: tickPosition)
                    }
                    
                    pattern2position += 1
                    
                    if pattern2position >= pattern2.count {
                        pattern2position = 0
                    }
                }

                if !pattern3off.contains(bar) {
                    if pattern3[pattern3position] == 1 {
                        perform(#selector(pattern3event), with: nil, afterDelay: tickPosition)
                    }
                    
                    pattern3position += 1
                    
                    if pattern3position >= pattern3.count {
                        pattern3position = 0
                    }
                }
            }
        }
    }
    
    @objc private func pattern1event() {
        self.testView1.alpha = 1
        
        UIView.animate(withDuration: 0.1, animations: {
            self.testView1.alpha = 0
        })
    }
    
    @objc private func pattern2event() {
        self.testView2.alpha = 1
        
        UIView.animate(withDuration: 0.1, animations: {
            self.testView2.alpha = 0
        })
    }
    
    @objc private func pattern3event() {
        self.testView3.alpha = 1
        
        UIView.animate(withDuration: 0.1, animations: {
            self.testView3.alpha = 0
        })
    }
}
