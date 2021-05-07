//
//  HistoryTableViewCell.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/6.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    public var clickDelete: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        clickDelete?()
    }
}
