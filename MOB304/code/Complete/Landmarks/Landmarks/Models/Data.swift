/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Helpers for loading images and data.
*/

import UIKit
import SwiftUI
import CoreLocation

// this is just used for the previews. At runtime, data are now taken from UserData and loaded through AppDelegate
let landmarkData: [Landmark] = load("landmarkData.json")

func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

// allow to create image with uniform color
// https://gist.github.com/isoiphone/031da3656d69c0d85805
extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

// manage iage cache and download
final class ImageStore {
    typealias _ImageDictionary = [String: Image]
    
    fileprivate let placeholderName = "circle"
    fileprivate var images: _ImageDictionary
    fileprivate static var scale = 2
    
    static var shared = ImageStore()

    init() {
        images = [:]
        images[self.placeholderName] = Image(uiImage: UIImage.imageWithColor(color: UIColor.white, size: CGSize(width:300, height: 300)))
    }
    
    func image(name: String) -> Image {
        guard
            let img = images[name]
        else {
            // should not happen
            fatalError("Request non existent image")
        }
        return img
    
    }
    
    func placeholder() -> Image {
        if let img = images[self.placeholderName] {
            return img
        } else {
            fatalError("Image cache is incorrectly initialized")
        }
    }

    func addImage(name: String, image : Data) {
        guard
            let i = UIImage(data: image)
        else {
            fatalError("Couldn't convert image data \(name)")
        }
        images[name] = Image(i.cgImage!, scale: CGFloat(ImageStore.scale), label: Text(verbatim: name))
    }
}
