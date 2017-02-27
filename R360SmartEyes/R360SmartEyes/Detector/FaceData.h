//
//  FaceData.h
//  R360SmartEyes
//
//  Created by whj on 17/2/25.
//  Copyright © 2017年 R360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaceData : NSObject

@property (nonatomic, assign) CGRect position;

@property (nonatomic, assign) CGPoint mouth_left_corner;

@property (nonatomic, assign) CGPoint mouth_right_corner;

@property (nonatomic, assign) CGPoint mouth_upper_lip_top;

@property (nonatomic, assign) CGPoint mouth_lower_lip_bottom;

@property (nonatomic, assign) CGPoint mouth_middle;

@property (nonatomic, assign) CGPoint left_eye_right_corner;

@property (nonatomic, assign) CGPoint right_eye_left_corner;

@property (nonatomic, assign) CGPoint left_eyebrow_left_corner;

@property (nonatomic, assign) CGPoint right_eyebrow_right_corner;


- (void)setPoint:(NSDictionary *)pointDic;

- (CGFloat)mouthWidth;
- (CGFloat)mouthHeight;
- (CGFloat)leftEyeHieght;
- (CGFloat)rightEyeHeight;

@end
