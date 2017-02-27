//
//  RDPImage.m
//  R360DP
//
//  Created by LiuDequan on 15/5/18.
//  Copyright (c) 2015年 liudequan. All rights reserved.
//

#import "RDPImage.h"

@implementation RDPImage

+ (UIImage *)imageForName:(NSString *)imageName
{
    return [self imageForName:imageName bundle:nil];
}

+ (UIImage *)imageForName:(NSString *)path bundle:(NSString *)bundleName
{
    return [self imageForName:path bundle:bundleName needCache:NO];
}

+ (UIImage *)imageForName:(NSString *)path bundle:(NSString *)bundleName needCache:(BOOL)needCache
{
    if (nil == path || path.length <= 0 )
    {
        return nil;
    }
    
    if ([path hasSuffix:@".png"] || [path hasSuffix:@".jpg"])
    {
        path = [path substringToIndex:path.length - 4];
    }
    
    
    UIImage *image = nil;
    NSString *imageKey = nil;
    
    if ([path hasSuffix:@"@2x"] || [path hasSuffix:@"@3x"])
    {
        //传入的图片名称带有@3x或@2x
        imageKey = [path substringToIndex:path.length - 3];
    }
    else
    {
        //传入的图片名称为正常图片名
        imageKey = path;
    }
    
    NSBundle *bundle = [self bundleForName:bundleName];
    
    if ([UIScreen mainScreen].scale == 3)
    {
        //如果是iPhone 6 Plus，从三倍图开始找，否则从二倍图开始找
        image = [self imageForKey:[NSString stringWithFormat:@"%@@3x",imageKey]
                         inBundle:bundle
                        needCache:needCache];
        if (!image)
        {
            image = [self imageForKey:[NSString stringWithFormat:@"%@@2x",imageKey]
                             inBundle:bundle
                            needCache:needCache];
        }
    }
    else
    {
        image = [self imageForKey:[NSString stringWithFormat:@"%@@2x",imageKey]
                         inBundle:bundle
                        needCache:needCache];
    }
    
    
    if (!image)
    {
        //找基本图
        image = [self imageForKey:imageKey inBundle:bundle needCache:needCache];
    }
    
    return image;
}

+ (NSBundle *)bundleForName:(NSString *)bundleName
{
    if (nil == bundleName)
    {
        return [NSBundle mainBundle];
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@.bundle",
                                                [[NSBundle mainBundle] bundlePath],bundleName]];
    if (nil == bundle)
    {
        return  [NSBundle mainBundle];
    }
    else
    {
        if (!bundle.isLoaded) {
            [bundle load];
        }
    }
    return bundle;
}


+ (UIImage *)imageForKey:(NSString *)key inBundle:(NSBundle *)bundle needCache:(BOOL)needCache
{
    NSString *imagePath = [bundle pathForResource:key ofType:@"png"];
    NSString *imageName = [NSString stringWithFormat:@"%@.png",key];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
    {
        imagePath = [bundle pathForResource:key ofType:@"jpg"];
        imageName = [NSString stringWithFormat:@"%@.jpg",key];
    }
    if (!needCache) {
        return [UIImage imageWithContentsOfFile:imagePath];
    } else {
        UIImage *image = [UIImage imageNamed:imageName];
        if (nil == image) {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
        return image;
    }
}


+ (UIImage *)cacheImageForName:(NSString *)name
{
    return [self cacheImageForName:name bundle:nil];
}


+ (UIImage *)cacheImageForName:(NSString *)name bundle:(NSString *)bundle
{
    return [self imageForName:name bundle:bundle needCache:YES];
}


@end
