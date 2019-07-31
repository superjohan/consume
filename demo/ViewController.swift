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

let bpm = 140.0
let barLength = (120.0 / bpm) * 2.0
let tickLength = barLength / 16.0
let endBar = 81

class ViewController: UIViewController {
    let autostart = true
    
    let audioPlayer: AVAudioPlayer
    let startButton = UIButton(type: UIButton.ButtonType.custom)
    let contentView = UIView()
    let qtFoolingBgView = UIView()
    
    let backgroundView = UIView()
    
    let squaresView = UIView()
    let squareView1 = UIView()
    let squareView2 = UIView()
    let squareView3 = UIView()

    private var events: [Event]?
    
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
        
        self.events = createEvents()

        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControl.Event.touchUpInside)
        
        self.view.backgroundColor = .black
        
        self.qtFoolingBgView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // barely visible tiny view for fooling Quicktime player. completely black images are ignored by QT
        self.view.addSubview(self.qtFoolingBgView)
        
        self.contentView.backgroundColor = .white
        self.contentView.isHidden = true
        
        self.view.addSubview(self.contentView)
        
        self.contentView.addSubview(self.backgroundView)
        self.contentView.addSubview(self.squaresView)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.qtFoolingBgView.frame = CGRect(
            x: (self.view.bounds.size.width / 2) - 1,
            y: (self.view.bounds.size.height / 2) - 1,
            width: 2,
            height: 2
        )

        self.contentView.frame = self.view.bounds
        self.squaresView.frame = self.view.bounds
        self.backgroundView.frame = self.view.bounds
        
        let length = (self.view.bounds.size.width / 3.0) - 50
        
        self.squareView2.frame = CGRect(x: (self.view.bounds.size.width / 2.0) - (length / 2.0), y: (self.view.bounds.size.height / 2.0) - (length / 2.0), width: length, height: length)
        self.squareView2.backgroundColor = .black
        self.squareView2.alpha = 0
        self.squaresView.addSubview(self.squareView2)

        self.squareView1.frame = CGRect(x: self.squareView2.frame.origin.x - length, y: self.squareView2.frame.origin.y, width: length, height: length)
        self.squareView1.backgroundColor = .black
        self.squareView1.alpha = 0
        self.squaresView.addSubview(self.squareView1)
        
        self.squareView3.frame = CGRect(x: self.squareView2.frame.origin.x + length, y: self.squareView2.frame.origin.y, width: length, height: length)
        self.squareView3.backgroundColor = .black
        self.squareView3.alpha = 0
        self.squaresView.addSubview(self.squareView3)

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
    
    private func createEvents() -> [Event] {
        let pattern1 = [1, 0, 0, 0, 0]
        let pattern1resets = [8, 28, 29, 45, 52, 58, 62, 69, 80]
        let pattern1off = [41, 42, 43, 44, 78, 79]
        
        let pattern2 = [0, 1, 0, 0, 1]
        let pattern2resets = [16, 20, 35, 45, 55, 56, 60, 65, 66, 80]
        let pattern2off = [33, 34, 73, 74, 75, 76, 77, 78, 79]
        
        let pattern3 = [0, 0, 1, 1, 0]
        let pattern3resets = [12, 24, 37, 45, 53, 59, 64, 74, 80]
        let pattern3off = [44, 70, 71, 72, 73]
        
        var pattern1position = 0
        var pattern2position = 0
        var pattern3position = 0

        var events = [Event]()
        var index = 0
        
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
                
                let event = Event(p1, p2, p3, bar, tick, tickPosition)

                if event.hasAction {
                    event.index = index
                    events.append(event)
                    
                    index += 1
                }
                
//                if tick == 8 {
//                    perform(#selector(clapEvent), with: nil, afterDelay: tickPosition)
//                }
            }
        }
        
        return events
    }
    
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
        
        self.contentView.isHidden = false
        
        scheduleEvents()
    }
    
    private func scheduleEvents() {
        guard let events = self.events else { abort() }
        
        for event in events {
            perform(#selector(eventTrigger(_:)), with: event, afterDelay: event.timestamp)
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
            animate(self.squareView1)
        }

        if event.p2 {
            animate(self.squareView2)
        }

        if event.p3 {
            animate(self.squareView3)
        }
        
        updateBackground(event: event)
    }
    
    private func updateBackground(event: Event) {
        guard let events = self.events else { abort() }
        
        let bgElementWidth = self.view.bounds.size.width / CGFloat(event.index + 1)
        let bgElementHeight = self.view.bounds.size.height / CGFloat(3)
        
        UIView.animate(withDuration: 0.1, animations: {
            for view in self.backgroundView.subviews {
                let viewIndex = view.tag
                view.frame = CGRect(
                    x: CGFloat(viewIndex) * bgElementWidth,
                    y: view.frame.origin.y,
                    width: bgElementWidth,
                    height: view.bounds.size.height
                )
            }
        })
        
        let x = CGFloat(event.index) * bgElementWidth
        
        func addView(index: Int) {
            let view = UIView(frame: CGRect(x: x, y: bgElementHeight * CGFloat(index), width: bgElementWidth, height: bgElementHeight))
            
            if index == 0 {
                view.backgroundColor = UIColor(white: 0.5, alpha: 1)
            } else if index == 1 {
                view.backgroundColor = UIColor(white: 0.6, alpha: 1)
            } else if index == 2 {
                view.backgroundColor = UIColor(white: 0.7, alpha: 1)
            }
            
            view.tag = event.index // yeah, yeah, sue me
            
            self.backgroundView.addSubview(view)
        }
        
        if event.p1 {
            addView(index: 0)
        }
        
        if event.p2 {
            addView(index: 1)
        }
        
        if event.p3 {
            addView(index: 2)
        }
    }
    
    @objc private func clapEvent() {
    }
    
    private class Event: NSObject {
        let p1: Bool
        let p2: Bool
        let p3: Bool
        let bar: Int
        let tick: Int
        let timestamp: TimeInterval
        var index: Int = 0
        
        var hasAction: Bool {
            get {
                return p1 || p2 || p3
            }
        }
        
        init(_ p1: Bool, _ p2: Bool, _ p3: Bool, _ bar: Int, _ tick: Int, _ timestamp: TimeInterval) {
            self.p1 = p1
            self.p2 = p2
            self.p3 = p3
            self.bar = bar
            self.tick = tick
            self.timestamp = timestamp
            
            super.init()
        }
    }
}
