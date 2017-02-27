//
//  RTJYIdentificationCustomCameraController.h
//  Pods
//
//  Created by 郑明星 on 16/1/9.
//
//

#import <UIKit/UIKit.h>
@class RTJYIdentificationCustomCameraController;

typedef NS_ENUM(NSUInteger, CustomCameraType) {
    CustomCameraTypeFront,
    CustomCameraTypeBack,
};

@protocol RTJYIdentificationCustomCameraControllerDelegate <NSObject>
- (void)customCameraController:(RTJYIdentificationCustomCameraController*)controller didSelectPhoto:(UIImage *)image;
@end

@interface RTJYIdentificationCustomCameraController : UIViewController

- (instancetype)initWithType:(CustomCameraType)type;
@property (nonatomic, assign) CustomCameraType cameraType;
@property (nonatomic, weak) id<RTJYIdentificationCustomCameraControllerDelegate>delegate;

@end
