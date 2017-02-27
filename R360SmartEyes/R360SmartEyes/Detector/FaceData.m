//
//  FaceData.m
//  R360SmartEyes
//
//  Created by whj on 17/2/25.
//  Copyright © 2017年 R360. All rights reserved.
//

#import "FaceData.h"

@implementation FaceData

- (void)setPoint:(NSDictionary *)landmark {
    _mouth_left_corner = CGPointFromString([landmark objectForKey:@"mouth_left_corner"]);
    _mouth_right_corner =CGPointFromString([landmark objectForKey:@"mouth_right_corner"]);
    _mouth_upper_lip_top = CGPointFromString([landmark objectForKey:@"mouth_upper_lip_top"]);
    _mouth_lower_lip_bottom = CGPointFromString([landmark objectForKey:@"mouth_lower_lip_bottom"]);
    _mouth_middle = CGPointFromString([landmark objectForKey:@"mouth_middle"]);
    _left_eye_right_corner = CGPointFromString([landmark objectForKey:@"left_eye_right_corner"]);
    _right_eye_left_corner = CGPointFromString([landmark objectForKey:@"right_eye_left_corner"]);
    _left_eyebrow_left_corner = CGPointFromString([landmark objectForKey:@"left_eyebrow_left_corner"]);
    _right_eyebrow_right_corner = CGPointFromString([landmark objectForKey:@"right_eyebrow_right_corner"]);
    
}

- (CGFloat)mouthWidth {
    return ABS(_mouth_right_corner.x - _mouth_left_corner.x);
}

- (CGFloat)mouthHeight {
    return ABS(_mouth_lower_lip_bottom.y - _mouth_upper_lip_top.y);
}

- (CGFloat)leftEyeHieght {
    return ABS(_left_eyebrow_left_corner.y - _left_eye_right_corner.y);
}

- (CGFloat)rightEyeHeight {
    return ABS(_right_eyebrow_right_corner.y - _right_eye_left_corner.y);
}


@end
