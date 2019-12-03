//
//  ShopPhoto.swift
//  wiki_1
//
//  Created by 釜谷 on 2018/10/02.
//  Copyright © 2018 Regina. All rights reserved.
//

import Foundation

public class ShopPhoto {
    
    var photos = [String: [String]]()
    var names = [String: String]()
    var gids = [String]()
    let path: URL
    
    static let sharedInstance = ShopPhoto()
    
    private init() {
        
        path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        load()
    }

    private func load() {
        
        photos.removeAll()
        names.removeAll()
        gids.removeAll()
        
        let ud = UserDefaults.standard
        ud.register(defaults: [
            "photos": [String: [String]](),
            "names": [String: String](),
            "gids": [String]()
        ])
        
        ud.synchronize()
        
        if let photos = ud.object(forKey: "photos") as? [String: [String]] {
            self.photos = photos
        }
        
        if let names = ud.object(forKey: "names") as? [String: String] {
            self.names = names
        }
        
        if let gids = ud.object(forKey: "gids") as? [String] {
            self.gids = gids
        }
    }
    
    private func save() {
        let ud = UserDefaults.standard
        
        ud.set(photos, forKey: "photos")
        ud.set(names, forKey: "names")
        ud.set(gids, forKey: "gids")
        
        ud.synchronize()
    }
    
    public func append(shop: Shop, image: UIImage) {
        
        if shop.gid == nil {return}
        if shop.name == nil {return}
        
        guard let data = UIImageJPEGRepresentation(image, 0.8) else {
            return
        }
        
        let filename = NSUUID().uuidString + ".jpg"
        let fileURL = path.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print(error)
            return
        }
        
        if photos[shop.gid!] == nil {
            
            photos[shop.gid!] = [String]()
        } else {
            gids = gids.filter { $0 != shop.gid! }
        }
        gids.append(shop.gid!)
        
        photos[shop.gid!]?.append(filename)
        names[shop.gid!] = shop.name
        
        save()
    }
    
    public func image(gid: String, index: Int) -> UIImage {

        if photos[gid] == nil { return UIImage() }
        guard let photoCount = photos[gid]?.count else { return UIImage() }
        if index >= photoCount { return UIImage() }
        
        if let filename = photos[gid]?[index] {
            
            let fileURL = path.appendingPathComponent(filename)
            guard let data = try? Data(contentsOf: fileURL) else {
                return UIImage()
            }
            if let image = UIImage(data: data) {
                return image
            }
        }
        
        return UIImage()
    }
    
    public func count(gid: String) -> Int {
        if photos[gid] == nil { return 0 }
        
        return photos[gid]!.count
    }
    
    public func numberOfPhotos(in index: Int) -> Int {
        if index >= gids.count { return 0 }
        if let photos = photos[gids[index]] {
            return photos.count
        }
        
        return 0
    }
    
}
