//
//  ImageLoader.swift
//  BookShelf
//
//  Created by Jerrick Warren on 10/30/18.
//  Copyright © 2018 Jerrick Warren. All rights reserved.
//

import UIKit

// URLSession for the data feed
// completion needs to return image data, if we get an image from it.. all is well...
// passing the image as the argument of completion, (e.g. bool, success etc)


class ImageLoader {
    static func fetchImage(from url: URL?, completion: @escaping (_ image: UIImage?) -> Void) {
        
        guard let url = url else { completion(nil); return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                NSLog("Unable to fetch data")
                completion(nil)
                return
            }
            
            guard let image = UIImage(data: data) else {
                NSLog("Unable to construct image")
                completion(nil)
                return
            }
            
            completion(image)
        }
        
        dataTask.resume()
    }
}
