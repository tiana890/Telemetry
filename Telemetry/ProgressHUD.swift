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
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .dark)
    var vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
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
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                                    y: superview.frame.height / 2 - height / 2,
                                    width: width,
                                    height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: 5, y: height / 2 - activityIndicatorSize / 2,
                                                width: activityIndicatorSize,
                                                height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: activityIndicatorSize + 5, y: 0, width: width - activityIndicatorSize - 15, height: height)
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 12)
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}
