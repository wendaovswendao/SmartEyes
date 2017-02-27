//
//  CustomCameraHelper.m
//  Pods
//
//  Created by zmx on 16/1/11.
//
//

#import "CustomCameraHelper.h"
#import "RDPImage.h"

@implementation CustomCameraHelper
+ (UIImage *)backgroundImageWithName:(NSString *)name {
    NSString *imageName = [name stringByAppendingFormat:@"%@", [self imageSuffixNameAccordingToDevice]];
    return [RDPImage imageForName:imageName bundle:nil];
}

+ (NSString *)imageSuffixNameAccordingToDevice{
    CGSize size = [UIScreen mainScreen].bounds.size;
    NSInteger width = (NSInteger)size.width;
    NSInteger height = (NSInteger)size.height;
    if (width == 320){
        if (height == 480){
            return @"960x640";
        }else if(height == 568){
            return @"1136x640";
        }
    }else if (width == 375){
        return @"1334x750";
    }else if(width == 414){
        return @"2208x1242";
    }
    
    //如果匹配失败，默认返回iphone 6对应的图片
    return @"1334x750";
}

+ (CGRect)getImageRect {
    CGSize size = [UIScreen mainScreen].bounds.size;
    NSInteger width = (NSInteger)size.width;
    NSInteger height = (NSInteger)size.height;

    
    if (width==320){
        if (height==480){
            return CGRectMake(64, 72, 282, 176);
        }else if(height==568){
            return CGRectMake(74, 49, 354, 224);
        }
    }else if (width==375){
        return CGRectMake(86, 58, 414, 262);
    }else if(width==414){
        return CGRectMake(95*2.608, 63*2.608, 458*2.608, 288*2.608);
    }

    //如果匹配失败，默认返回iphone 6对应的图片
    return CGRectMake(26, 33, 163, 103);
}
@end
