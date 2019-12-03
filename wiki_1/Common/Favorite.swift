//
//  Favorite.swift
//  wiki_1
//
//  Created by 釜谷 on 2018/09/21.
//  Copyright © 2018年 Regina. All rights reserved.
//

import Foundation

public struct Favorite {
    public static var favorites = [String]()
    
    public static func load() {
        let ud = UserDefaults.standard
        ud.register(defaults: ["favorites": [String]()])
        favorites = ud.object(forKey: "favorites") as! [String]
     }
    
    public static func save() {
        let ud = UserDefaults.standard
        ud.set(favorites, forKey: "favorites")
        ud.synchronize()
    }
    
    public static func add(_ gid: String) {
        if favorites.contains(gid) {
            remove(gid)
        }
 
        favorites.append(gid)
        save()
    }
    
    public static func remove(_ gid: String) {
        if let index = favorites.index(of: gid) {
            favorites.remove(at: index)
        }
        save()
    }
    
    public static func toggle(_ gid: String) {
        if inFavorites(gid) {
            remove(gid)
        } else {
            add(gid)
        }
        
//        NotificationCenter.default.post(name: .changeFavorite, object: nil)
    }
    
    public static func inFavorites(_ gid: String) -> Bool {
        return favorites.contains(gid)
    }
    
    public static func move(_ sourceIndex: Int, to destinationIndex: Int) {

        if sourceIndex >= favorites.count || destinationIndex >= favorites.count {
            return
        }
        
        let srcGid = favorites[sourceIndex]
        favorites.remove(at: sourceIndex)
        favorites.insert(srcGid, at: destinationIndex)
        save()
    }
}
