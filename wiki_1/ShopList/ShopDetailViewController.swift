//
//  ShopDetailViewController.swift
//  wiki_1
//
//  Created by 釜谷 on 2018/09/19.
//  Copyright © 2018年 Regina. All rights reserved.
//

import UIKit
import MapKit
import Social

class ShopDetailViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var addressContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var line: UIButton!
    @IBOutlet weak var twitter: UIButton!
    
    var shop = Shop()
    let ipc = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = shop.photoUrl {
            photo.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "loading"))
        } else {
            photo.image = UIImage(named: "loading")
        }
        
        name.text = shop.name
        tel.text = shop.tel
        address.text = shop.address
        
        updateFavoriteButton()
        
        if let lat = shop.lat {
            if let lon = shop.lon {
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 200, 200)
                map.setRegion(mkcr, animated: false)
                
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                map.addAnnotation(pin)
            }
        }
        
        ipc.delegate = self
        ipc.allowsEditing = true
        
        if UIApplication.shared.canOpenURL(URL(string: "line://")!) {
            line.isEnabled = true
        }

        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            twitter.isEnabled = false
        }
        
//        twitter.isEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.delegate = self
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollView.delegate = nil
        
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        let nameFrame = name.sizeThatFits(
            CGSize(width: name.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        )
        nameHeight.constant = nameFrame.height
        
        let addressFrame = address.sizeThatFits(
            CGSize(width: address.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        )
        addressContainerHeight.constant = addressFrame.height
        
        view.layoutIfNeeded()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollOffset <= 0 {
            photo.frame.origin.y = scrollOffset
            photo.frame.size.height = 200 - scrollOffset
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        ipc.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            ShopPhoto.sharedInstance.append(shop: shop, image: image)
        }

        ipc.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - App Logic
    func updateFavoriteButton() {
        guard let gid = shop.gid else {
            return
        }
        
        if Favorite.inFavorites(gid) {
            favoriteIcon.image = UIImage(named: "star-on")
            favoriteLabel.text = "お気に入りからはずす"
        } else {
            favoriteIcon.image = UIImage(named: "star-off")
            favoriteLabel.text = "お気に入りに入れる"
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushMapDetail" {
            let vc = segue.destination as! ShopMapDetailViewController
            vc.shop = shop
        }
    }
    
    // MARK: - IBAction
    @IBAction func telTapped(_ sender: UIButton) {
        guard let tel = shop.tel else {
            return
        }
        
        guard let url = URL(string: "tel:\(tel)") else {
            return
        }
        
        if !UIApplication.shared.canOpenURL(url) {
            let alert = UIAlertController(
                title: "can't call phone" , message: "dont have call function", preferredStyle: .alert
            )
            
            alert.addAction(
                UIAlertAction(title: "OK", style: .default, handler: nil)
            )
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let name = shop.name else {
            return
        }
        
        let alert = UIAlertController(title: "tel", message: "call \(name)", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: "call phone", style: .destructive, handler: {
                action in
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
                return
            })
        )
        
        alert.addAction(
            UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        )
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addressTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "PushMapDetail", sender: nil)
    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        guard let gid = shop.gid else {
            return
        }
        
        Favorite.toggle(gid)
        updateFavoriteButton()
    }
    
    @IBAction func addPhotoTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(
                UIAlertAction(title: "写真を撮る", style: .default, handler: {
                    action in
                    
                    self.ipc.sourceType = .camera
                    self.present(self.ipc, animated: true, completion: nil)
                })
            )
        }

        alert.addAction(
            UIAlertAction(title: "写真を選択", style: .default, handler: {
                action in
                
                self.ipc.sourceType = .photoLibrary
                self.present(self.ipc, animated: true, completion: nil)
            })
        )

        alert.addAction(
            UIAlertAction(title: "キャンセル", style: .cancel, handler: {
                action in
            })
        )
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func lineTapped(_ sender: UIButton) {
        
        var message = ""
        
        if let name = shop.name {
            message += name + "\n"
        }
        
        if let url = shop.url {
            message += url + "\n"
        }
        
        if let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            if let uri = URL(string: "line://msg/text" + encoded) {
                UIApplication.shared.open(uri, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func twitterTapped(_ sender: UIButton) {
    }
    
}
