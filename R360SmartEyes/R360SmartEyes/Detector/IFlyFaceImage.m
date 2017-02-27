//
//  IFlyFaceImage.m
//  R360SmartEyes
//
//  Created by whj on 17/2/25.
//  Copyright © 2017年 R360. All rights reserved.
//

#import "IFlyFaceImage.h"

@implementation IFlyFaceImage

@synthesize data=_data;

-(instancetype)init{
    if (self = [super init]) {
        _data=nil;
        self.width=0;
        self.height=0;
        self.direction=IFlyFaceDirectionTypeLeft;
    }
    
    return self;
}

-(void)dealloc{
    self.data=nil;
}

@end
