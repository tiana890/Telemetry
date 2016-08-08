//
//  SelectableCell.swift
//  Telemetry
//
//  Created by IMAC  on 08.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit

class SelectableCell: UITableViewCell {
    @IBOutlet var mainText: UILabel!
    @IBOutlet var additionalText: UILabel!
    @IBOutlet var additionalImg: UIImageView!

    override func setSelected(selected: Bool, animated: Bool) {
        if(!selected){
            self.mainText.font = UIFont(name: "HelveticaNeue", size: 13.0)
            self.additionalImg.hidden = true
        } else {
            self.mainText.font = UIFont(name: "HelveticaNeue-Bold", size: 13.0)
            self.additionalImg.hidden = false
        }
        
    }
}
