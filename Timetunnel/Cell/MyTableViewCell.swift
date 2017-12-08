//
//  MyTableViewCell.swift
//  Timetunnel
//
//  Created by kobe on 2017/10/7.
//  Copyright © 2017年 kobe. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {

    @IBOutlet weak var uploadTime: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    
    
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /*
    //將cell內縮10, 並且cell有圓角
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue
            frame.origin.x += 10
            frame.size.width -= 2 * frame.origin.x;
            frame.size.height -= 2 * frame.origin.x;
            
            
            
            self.layer.masksToBounds = true;
            self.layer.cornerRadius = 5.0;
            //frame.size.width -= 2 * 25
            
            super.frame = frame
        }
    }
 */
}
