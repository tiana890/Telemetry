//
//  CommonHeaderCell.swift
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit

class CommonCell: UITableViewCell {

    @IBOutlet var mainText: UILabel!
    @IBOutlet var additionalText: UILabel!
    @IBOutlet var additionalImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
