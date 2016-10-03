//
//
//  ProgressHUD.swift
//  GBU
//
//  Created by Agentum on 01.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit

class ProgressHUD: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .Dark)
    var vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.text = ""
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndictor)
        vibrancyView.contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width: CGFloat = 280.0 //2.3
            let height: CGFloat = 60.0
            self.frame = CGRectMake(superview.frame.size.width / 2 - width / 2,
                                    superview.frame.height / 2 - height / 2,
                                    width,
                                    height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRectMake(5, height / 2 - activityIndicatorSize / 2,
                                                activityIndicatorSize,
                                                activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.numberOfLines = 0
            label.lineBreakMode = .ByWordWrapping
            label.textAlignment = NSTextAlignment.Center
            label.frame = CGRectMake(activityIndicatorSize + 5, 0, width - activityIndicatorSize - 15, height)
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.boldSystemFontOfSize(12)
        }
    }
    
    func show() {
        self.hidden = false
    }
    
    func hide() {
        self.hidden = true
    }
}
