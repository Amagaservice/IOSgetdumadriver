//
//  welcomeVCTableViewCell.swift
//  OcoryDriver
//
//  Created by malika saini on 09/09/22.
//

import UIKit

class welcomeVCTableViewCell: UITableViewCell {
    @IBOutlet weak var mTitleLBL: UILabel!
    
    @IBOutlet weak var mStatusLBL: UILabel!
    @IBOutlet weak var mImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //MARK:- default func
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
