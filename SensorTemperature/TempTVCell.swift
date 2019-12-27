//
//  TempTVCell.swift
//  SensorTemperature
//
//  Created by Lourenço Gomes on 27/12/2019.
//  Copyright © 2019 Lourenço Gomes. All rights reserved.
//

import UIKit

class TempTVCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescriptiopn: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
