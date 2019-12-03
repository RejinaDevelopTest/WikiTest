//
//  FreewordTableViewCell.swift
//  wiki_1
//
//  Created by 釜谷 on 2018/09/17.
//  Copyright © 2018年 Regina. All rights reserved.
//

import UIKit

class FreewordTableViewCell: UITableViewCell {

    @IBOutlet weak var freeword: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
