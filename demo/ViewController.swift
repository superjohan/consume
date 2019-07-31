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
    let startButton = UIButton(type: UIButton.ButtonType.custom)
    let contentView = UIView()
    let qtFoolingBgView = UIView()
    
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
        
        self.contentView.backgroundColor = .white
        
        self.view.addSubview(self.contentView)
        
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

        self.contentView.frame = self.view.bounds

        let length = (self.view.bounds.size.width / 3.0) - 50
        
        self.testView2.frame = CGRect(x: (self.view.bounds.size.width / 2.0) - (length / 2.0), y: (self.view.bounds.size.height / 2.0) - (length / 2.0), width: length, height: length)
        self.testView2.backgroundColor = .black
        self.testView2.alpha = 0
        self.contentView.addSubview(self.testView2)

        self.testView1.frame = CGRect(x: self.testView2.frame.origin.x - length, y: self.testView2.frame.origin.y, width: length, height: length)
        self.testView1.backgroundColor = .black
        self.testView1.alpha = 0
        self.contentView.addSubview(self.testView1)
        
        self.testView3.frame = CGRect(x: self.testView2.frame.origin.x + length, y: self.testView2.frame.origin.y, width: length, height: length)
        self.testView3.backgroundColor = .black
        self.testView3.alpha = 0
        self.contentView.addSubview(self.testView3)

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
        let pattern1off = [41, 42, 43, 44, 78, 79]
        
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
                let p1: Bool
                let p2: Bool
                let p3: Bool
                
                if !pattern1off.contains(bar) {
                    p1 = pattern1[pattern1position] == 1
                    
                    pattern1position += 1
                    
                    if pattern1position >= pattern1.count {
                        pattern1position = 0
                    }
                } else {
                    p1 = false
                }

                if !pattern2off.contains(bar) {
                    p2 = pattern2[pattern2position] == 1

                    pattern2position += 1
                    
                    if pattern2position >= pattern2.count {
                        pattern2position = 0
                    }
                } else {
                    p2 = false
                }

                if !pattern3off.contains(bar) {
                    p3 = pattern3[pattern3position] == 1

                    pattern3position += 1
                    
                    if pattern3position >= pattern3.count {
                        pattern3position = 0
                    }
                } else {
                    p3 = false
                }
                
                let event = Event(p1, p2, p3)
                if event.hasAction {
                    perform(#selector(eventTrigger(_:)), with: event, afterDelay: tickPosition)
                }
                
                if tick == 8 {
                    perform(#selector(clapEvent), with: nil, afterDelay: tickPosition)
                }
            }
        }
    }
    
    @objc private func eventTrigger(_ event: Event) {
        func animate(_ view: UIView) {
            view.alpha = 1
            
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 0
            })
        }
        
        if event.p1 {
            animate(self.testView1)
        }

        if event.p2 {
            animate(self.testView2)
        }

        if event.p3 {
            animate(self.testView3)
        }
    }
    
    @objc private func clapEvent() {
    }
    
    private class Event: NSObject {
        let p1: Bool
        let p2: Bool
        let p3: Bool
        
        var hasAction: Bool {
            get {
                return p1 || p2 || p3
            }
        }
        
        init(_ p1: Bool, _ p2: Bool, _ p3: Bool) {
            self.p1 = p1
            self.p2 = p2
            self.p3 = p3
            
            super.init()
        }
    }
}
