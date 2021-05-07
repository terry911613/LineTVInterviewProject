//
//  DramaTableViewCell.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/5.
//

import UIKit

class DramaTableViewCell: UITableViewCell {

    @IBOutlet weak var dramaImageView: UIImageView!
    @IBOutlet weak var dramaTitleLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
