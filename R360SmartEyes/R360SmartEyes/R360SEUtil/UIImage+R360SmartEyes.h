//
//  UIImage+R360SmartEyes.h
//  R360SmartEyes
//
//  Created by Liudequan on 2017/2/24.
//  Copyright © 2017年 R360. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (R360SmartEyes)

// 图片二值化
- (UIImage *)rseblackAndWhite;

// 图片变形
-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
@end
