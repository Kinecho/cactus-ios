//
//  SocialContactTableViewCell.swift
//  Cactus
//
//  Created by Neil Poulin on 1/16/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class SocialContactTableViewCell: UITableViewCell {

    let imageDiameter: CGFloat = 50
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }

    func configureCell() {
//        self.activityItemsConfiguration = UserActivityCon
//        let trashView = UIImageView(image: CactusImage.close.ofWidth(newWidth: 20))
//        trashView.tintColor = CactusColor.textMinimized
//        self.accessoryView = trashView
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let imageViewFrame = self.imageView?.frame {
            self.imageView?.frame = imageViewFrame.insetBy(dx: 10, dy: 10)
        }
        imageView?.layer.cornerRadius = max(imageView?.bounds.width ?? 0, imageView?.bounds.height ?? 0) / 2
    }

}
