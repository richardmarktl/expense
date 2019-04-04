//
//  UIImage+Resize.swift
//  InVoice
//
//  Created by Georg Kitz on 7/17/18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {
    func resized(to maxValue: CGFloat) -> UIImage? {
        guard let imageData = UIImageJPEGRepresentation(self, 1.0) as CFData?,
            let source = CGImageSourceCreateWithData(imageData, nil) else {
                return nil
        }
        
        let options = [
            kCGImageSourceShouldAllowFloat as String: true as NSNumber,
            kCGImageSourceCreateThumbnailWithTransform as String: true as NSNumber,
            kCGImageSourceCreateThumbnailFromImageAlways as String: true as NSNumber,
            kCGImageSourceThumbnailMaxPixelSize as String: maxValue as NSNumber
        ]
        
        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: thumbnail)
    }
    
    /// This method will crop transparent parts of an image empty pixels with alpha = 0. This source is based
    /// on https://gist.github.com/krooked/9c4c81557fc85bc61e51c0b4f3301e6e
    ///
    /// - Returns: a cropped image
    func imageByCroppingTransparentPixels() -> UIImage {
        guard let cgImage = self.cgImage,
            let context = createARGBBitmapContext(from: cgImage),
            let data:UnsafeMutableRawPointer = context.data else {
            return self
        }
        
        let height = cgImage.height
        let width = cgImage.width
        var minX: Int  = width
        var minY: Int = height
        var maxX: Int = 0
        var maxY: Int = 0
        
        // Filter through data and look for non-transparent pixels.
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (width * y + x) * 4 // 4 for A, R, G, B
                // The opacity goes from 0 ... 255, 0 = no transparency 255 full transparency
                if data.load(fromByteOffset: pixelIndex, as: UInt8.self) != 0 {
                    if (x < minX) {
                        minX = x
                    }
                    if (x > maxX) {
                        maxX = x
                    }
                    if (y < minY) {
                        minY = y
                    }
                    if (y > maxY) {
                        maxY = y
                    }
                }
            }
        }
        
        let rect = CGRect(x: CGFloat(minX), y: CGFloat(minY), width: CGFloat(maxX-minX), height: CGFloat(maxY-minY))
        if let croppedImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedImage, scale:  self.scale, orientation: self.imageOrientation)
        }
        return self
    }
    
    /// This method will create an RGBA image context.
    ///
    /// - Parameter inImage: the source image
    /// - Returns: a context
    private func createARGBBitmapContext(from image: CGImage) -> CGContext? {
        let width = image.width
        let height = image.height
        
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
        
        let context = CGContext(
            data: bitmapData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bitmapBytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

        return context
    }
}
