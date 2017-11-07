//
//  UIImageExtenstions.swift
//  AuctionApp
//
//  Created by Jeff Kereakoglow on 01/17/16.
//  https://gist.github.com/jkereako/200342b66b5416fd715a
//

import UIKit

extension UIImage {
    
    // credit: http://stackoverflow.com/questions/603907/uiimage-resize-then-crop#605385
    func scaleAndCropImage(toSize size: CGSize) -> UIImage {
        let image = self
        // Make sure the image isn't already sized.
        guard !image.size.equalTo(size) else {
            return image
        }
        
        let widthFactor = size.width / image.size.width
        let heightFactor = size.height / image.size.height
        var scaleFactor: CGFloat = 0.0
        
        scaleFactor = heightFactor
        
        if widthFactor > heightFactor {
            scaleFactor = widthFactor
        }
        
        var thumbnailOrigin = CGPoint.zero
        let scaledWidth  = image.size.width * scaleFactor
        let scaledHeight = image.size.height * scaleFactor
        
        if widthFactor > heightFactor {
            thumbnailOrigin.y = (size.height - scaledHeight) / 2.0
        }
            
        else if widthFactor < heightFactor {
            thumbnailOrigin.x = (size.width - scaledWidth) / 2.0
        }
        
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailOrigin
        thumbnailRect.size.width  = scaledWidth
        thumbnailRect.size.height = scaledHeight
        
        // Why use `UIGraphicsBeginImageContextWithOptions` over `UIGraphicsBeginImageContext`?
        // see: http://stackoverflow.com/questions/4334233/how-to-capture-uiview-to-uiimage-without-loss-of-quality-on-retina-display#4334902
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: thumbnailRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
