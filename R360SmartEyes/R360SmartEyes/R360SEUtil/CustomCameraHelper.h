//
//  CustomCameraHelper.h
//  Pods
//
//  Created by zmx on 16/1/11.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomCameraHelper : NSObject
+ (UIImage *)backgroundImageWithName:(NSString *)name;


/**
 获得要裁剪图片的大小

 */
+ (CGRect)getImageRect;
@end
