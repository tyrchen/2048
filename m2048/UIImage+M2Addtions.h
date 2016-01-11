//
//  UIImage+M2Addtions.h
//  m2048
//
//  Created by Yanping Lan on 1/9/16.
//  Copyright © 2016 Danqing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (M2Addtions)

+ (UIImage *)takeSnapshot:(UIView *)currentView;
+ (NSString *)saveImage:(UIImage *)image;
+ (UIImage*)loadImage:(NSString *)fileName;

- (UIImage *)scaleDownToThumbnail:(NSString *)path;

@end
