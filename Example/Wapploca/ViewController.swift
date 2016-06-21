//
//  ViewController.swift
//  Wapploca
//
//  Created by gabmarfer on 06/02/2016.
//  Copyright (c) 2016 gabmarfer. All rights reserved.
//

import UIKit
import Wapploca

class ViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    
    let manager = Wapploca.Manager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(localize),
                                                         name: Manager.Notification.didChangeLanguageKey,
                                                         object: nil)
        localize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Manager.Notification.didChangeLanguageKey,
                                                            object: nil)
    }
    
    func localize() {
        messageLabel.text = manager.translationForKey("bloombees.mobileapp.welcome.message_welcome")
        changeButton.setTitle(manager.translationForKey("bloombees.mobileapp.action.change"), forState: UIControlState.Normal)
    }

    // MARK: - Actions
    @IBAction func handleTapChangeButton(sender: AnyObject) {
        manager.showLanguageSelectorFromViewController(self)
    }
}

