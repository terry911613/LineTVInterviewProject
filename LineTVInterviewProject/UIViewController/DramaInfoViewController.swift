//
//  DramaInfoViewController.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/5.
//

import UIKit

class DramaInfoViewController: UIViewController {

    @IBOutlet weak var dramaImageView: UIImageView!
    @IBOutlet weak var dramaTitleLabel: UILabel!
    @IBOutlet weak var totalViewsLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    
    public var drama: Drama!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(drama != nil)
        
        configureUI()
    }
    
    private func configureUI() {
        navigationItem.title = "戲劇資訊"
        if let thumbData = drama.thumbData {
            dramaImageView.load(data: thumbData)
        }
        else {
            dramaImageView.load(urlString: drama.thumb)
        }
        dramaTitleLabel.text = drama.name
        rateButton.setTitle(drama.ratingDisplayString, for: .normal)
        rateButton.setTitleColor(.label, for: .normal)
        rateButton.tintColor = .yellow
        rateButton.layer.cornerRadius = rateButton.frame.height / 2
        totalViewsLabel.text = drama.totalViewsDisplayString
        createdDateLabel.text = drama.createdDateDisplayString
    }
}
