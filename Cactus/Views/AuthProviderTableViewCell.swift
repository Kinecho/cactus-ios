//
//  AuthProviderTableViewCell.swift
//  Cactus
//
//  Created by Neil Poulin on 10/9/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class AuthProviderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.sharedConfig()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sharedConfig() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        if let imageView = self.imageView {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
            imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        if let textLabel = self.textLabel {
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        }
        
        if let imageView = self.imageView, let textLabel = self.textLabel {
            imageView.trailingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -10).isActive = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
//        self.imageView?.inset
    }
    
}
