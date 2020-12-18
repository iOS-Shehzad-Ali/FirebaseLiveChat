//
//  CacheOfProfileImageDownloaded.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 14/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString : String) {
        
        //check cache for image first
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject)
        {
            self.image = cachedImage as? UIImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil
            {
                print("Error in downloading image from Firebase database", error ?? "")
                return
            }
            
            if let downloadedImage = UIImage(data: data!)
            {
                imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                self.image = downloadedImage
            }
            
            
            //cell.profileImageView.image = UIImage(data: data!)
        }).resume()
    }
}
