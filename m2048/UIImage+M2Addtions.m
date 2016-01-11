//
//  UIImage+M2Addtions.m
//  m2048
//
//  Created by Yanping Lan on 1/9/16.
//  Copyright © 2016 Danqing. All rights reserved.
//

#import "UIImage+M2Addtions.h"
#import <ImageIO/ImageIO.h>


@implementation UIImage (M2Addtions)

+ (UIImage *)takeSnapshot:(UIView *)currentView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize size = screenRect.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [currentView drawViewHierarchyInRect:screenRect afterScreenUpdates:YES];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShot;
}


- (UIImage *)scaleDownToThumbnail:(NSString *)path {
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], NULL);
    if (!imageSource)
        return nil;
    
    CFDictionaryRef options = (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
        (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
        (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent,
        (id)[NSNumber numberWithFloat:60], (id)kCGImageSourceThumbnailMaxPixelSize,
        nil];
    CGImageRef imgRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    UIImage* scaledImage = [UIImage imageWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    CFRelease(imageSource);
    
    return scaledImage;
}


+ (NSString *)saveImage:(UIImage *)image {
    NSString *fileName = nil;
    if (image != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        fileName = [NSString stringWithFormat:@"record_%f.png", [NSDate date].timeIntervalSince1970];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
        
        // scaledown to thumbnail image 
        UIImage *thumbnail = [image scaleDownToThumbnail:path];
        NSData* thumbnailData = UIImagePNGRepresentation(thumbnail);
        [thumbnailData writeToFile:path atomically:YES];
    }
    return fileName;
}


+ (UIImage*)loadImage:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    return [UIImage imageWithContentsOfFile:path];
}


@end
