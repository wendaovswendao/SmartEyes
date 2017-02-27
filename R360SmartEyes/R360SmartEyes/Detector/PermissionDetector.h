//
//  PermissionDetector.h
//  R360SmartEyes
//
//  Created by whj on 17/2/25.
//  Copyright © 2017年 R360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PermissionDetector : NSObject

/**
 *  检测相机权限
 *
 *  @return 准许返回YES;否则返回NO
 */
+(BOOL)isCapturePermissionGranted;

/**
 *  检测相册权限
 *
 *  @return 准许返回YES;否则返回NO
 */
+(BOOL)isAssetsLibraryPermissionGranted;

@end
