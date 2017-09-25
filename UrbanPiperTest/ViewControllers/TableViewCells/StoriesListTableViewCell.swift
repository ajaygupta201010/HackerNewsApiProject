//
//  StoriesListTableViewCell.swift
//  UrbanPiperTest
//
//  Created by Gupta, Ajay - Ajay on 9/19/17.
//  Copyright © 2017 Gupta, Ajay - Ajay. All rights reserved.
//

import UIKit

class StoriesListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var storyUrlLbl: UILabel!
    @IBOutlet weak var updatingTimeOfStory: UILabel!
    @IBOutlet weak var numberOfComments: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
