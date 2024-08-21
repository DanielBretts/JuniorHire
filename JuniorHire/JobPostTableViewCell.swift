//
//  JobPostTableViewCell.swift
//  JuniorHire
//
//  Created by amit lupo  on 8/20/24.
//

import UIKit

class JobPostTableViewCell: UITableViewCell {

    @IBOutlet weak var dateOfExpirationLbl: UILabel!
    @IBOutlet weak var remainingDaysLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var positionTitleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
