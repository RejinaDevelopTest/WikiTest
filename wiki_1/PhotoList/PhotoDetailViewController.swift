//
//  PhotoDetailViewController.swift
//  wiki_1
//
//  Created by 釜谷 on 2018/10/03.
//  Copyright © 2018 Regina. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!

    var image: UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        photo.alpha = 0
        photo.image = image
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentInset.top = (scrollView.bounds.size.height - photo.bounds.size.height) / 2.0
        scrollView.contentInset.bottom = (scrollView.bounds.size.height - photo.bounds.size.height) / 2.0
        
        scrollView.setZoomScale(1, animated: false)
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        
        view.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.1, animations:   {
            self.photo.alpha = 1
        })
    }
    
    // MARK: - UIScrollViewDeelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photo
    }
}
