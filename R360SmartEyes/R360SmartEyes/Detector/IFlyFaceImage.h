//
//  IFlyFaceImage.h
//  R360SmartEyes
//
//  Created by whj on 17/2/25.
//  Copyright © 2017年 R360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 人脸朝向类型
typedef NS_ENUM(NSUInteger, IFlyFaceDirectionType) {
    IFlyFaceDirectionTypeUp   = 0,           ///< 人脸向上，即人脸朝向正常
    IFlyFaceDirectionTypeLeft = 1,           ///< 人脸向左，即人脸被逆时针旋转了90度
    IFlyFaceDirectionTypeDown = 2,           ///< 人脸向下，即人脸被旋转了180度
    IFlyFaceDirectionTypeRight= 3            ///< 人脸向右，即人脸被顺时针旋转了90度
};

/**
 *  @brief 用于视频流检测接口的人脸图像类
 */
@interface IFlyFaceImage : NSObject

/**
 *  @brief 图片数据
 */
@property(nonatomic, strong) NSData* data;

/**
 *  @brief 图片宽
 */
@property(nonatomic, assign) CGFloat width;

/**
 *  @brief 图片高
 */
@property(nonatomic, assign)CGFloat height;

/**
 *  @brief 图片方向
 */
@property(nonatomic, assign)IFlyFaceDirectionType direction;


@end
