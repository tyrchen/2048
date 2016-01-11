//
//  UIButton+M2Additions.m
//  m2048
//
//  Created by Yanping Lan on 1/9/16.
//  Copyright © 2016 Danqing. All rights reserved.
//

#import "UIButton+M2Additions.h"

@implementation UIButton (M2Additons)

- (void)M2ButtonStyle {
    self.backgroundColor = [GSTATE buttonColor];
    self.layer.cornerRadius = [GSTATE cornerRadius];
    self.layer.masksToBounds = YES;
    self.exclusiveTouch = YES;
}


@end
