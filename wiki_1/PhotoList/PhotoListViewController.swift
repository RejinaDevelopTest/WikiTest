//
//  PhotoListViewController.swift
//  wiki_1
//
//  Created by 釜谷 on 2018/10/03.
//  Copyright © 2018 Regina. All rights reserved.
//

import UIKit

class PhotoListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var collectionView: UICollectionView!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = self.view.frame.size.width / 3
        
        return CGSize(width: size, height: size)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return ShopPhoto.sharedInstance.gids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return ShopPhoto.sharedInstance.numberOfPhotos(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoListItem", for: indexPath) as! PhotoListItemCollectionViewCell
        
        let gid = ShopPhoto.sharedInstance.gids[indexPath.section]
        
        cell.photo.image = ShopPhoto.sharedInstance.image(gid: gid, index: indexPath.row)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionHeader,
                    withReuseIdentifier: "PhotoListHeader",
                    for: indexPath) as! PhotoListItemCollectionViewHeader
                
            
            let gid = ShopPhoto.sharedInstance.gids[indexPath.section]
            let name = ShopPhoto.sharedInstance.names[gid]
            
            header.title.text = name
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "PushPhotoDetail", sender: indexPath)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PushPhotoDetail" {
            let vc = segue.destination as! PhotoDetailViewController
            if let indexPath = sender as? IndexPath {
                let gid = ShopPhoto.sharedInstance.gids[indexPath.section]
                let image = ShopPhoto.sharedInstance.image(gid: gid, index: indexPath.row)
                
                vc.image = image
            }
        }
    }
}
