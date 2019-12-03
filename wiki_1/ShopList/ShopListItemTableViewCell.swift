//
//  ShopListItemTableViewCell.swift
//  wiki_1
//
//  Created by 釜谷 on 2018/09/04.
//  Copyright © 2018年 Regina. All rights reserved.
//

import UIKit

class ShopListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var coupon: UILabel!
    @IBOutlet weak var station: UILabel!

    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var stationWidth: NSLayoutConstraint!
    @IBOutlet weak var stationX: NSLayoutConstraint!
    
    var shop: Shop = Shop() {
        didSet {
            
            if let url = shop.photoUrl {
                photo.sd_cancelCurrentAnimationImagesLoad()
                photo.sd_setImage(with: URL(string: url),
                                  placeholderImage: UIImage(named: "loading"),
                                  options: [.retryFailed, .cacheMemoryOnly])
            }
            
            name.text = shop.name
            var x: CGFloat = 0
            let margin: CGFloat = 10
            if shop.hasCoupon {
                coupon.isHidden = false
                x += coupon.frame.size.width + margin
                
                coupon.layer.cornerRadius = 4
                coupon.clipsToBounds = true
            } else {
                coupon.isHidden = true
            }
            
            if shop.station != nil {
                station.isHidden = false
                station.text = shop.station
                
                stationX.constant = x
                
                let size = station.sizeThatFits(CGSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: CGFloat.greatestFiniteMagnitude
                ))
                
                if x + size.width + margin > iconContainer.frame.width {
                    stationWidth.constant = iconContainer.frame.width
                } else {
                    stationWidth.constant = size.width + margin
                }
                
                station.clipsToBounds = true
                station.layer.cornerRadius = 4
                
            } else {
                station.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maxFrame = CGRect(x: 0, y: 0, width: name.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let actualFrame = name.textRect(forBounds: maxFrame, limitedToNumberOfLines: 2)
        
        nameHeight.constant = actualFrame.size.height
        
    }
}
