//
//  MovieCell.swift
//  flicks
//
//  Created by Yi Cao on 7/14/16.
//  Copyright © 2016 yidea. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
    
    //override the hightlight of selected table cell
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set background color
        let view = UIView()
        //view.backgroundColor =  UIColor(red: 1, green: 168/255, blue: 0, alpha: 0.1)
        selectedBackgroundView = view
    }
}
