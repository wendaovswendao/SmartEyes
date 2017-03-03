//
//  RSECheckViewController.m
//  R360SmartEyes
//
//  Created by whj on 17/2/25.
//  Copyright © 2017年 R360. All rights reserved.
//

#import "RSECheckViewController.h"
#import "CaptureManager.h"
#import "CanvasView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "PermissionDetector.h"
#import "UIImage+Extensions.h"
#import "iflyMSC/IFlyFaceSDK.h"
#import "CaptureManager.h"
#import "CanvasView.h"
#import "IFlyFaceImage.h"
#import "CalculatorTools.h"
#import "FaceData.h"
#import "IFlyFaceResultKeys.h"

typedef NS_ENUM(NSUInteger, kAuthStatus) {
    kAuthFace = 0,
    kAuthStatusMouth,
    kAuthMidFace,
    kAuthStatusLeftShake,
    kAuthStatusRightShake,
    kAuthStatusEye,
    kAuthStatusSuccess,
};

@interface RSECheckViewController ()<CaptureManagerDelegate>

@property (nonatomic, strong) UIView *previewView;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) CaptureManager *captureManager;

@property (nonatomic, strong) IFlyFaceDetector *faceDetector;
@property (nonatomic, strong) CanvasView *viewCanvas;

@property (nonatomic, strong) UILabel *promptLabel;

@property (nonatomic, assign) kAuthStatus currentStatus;

@property (nonatomic, strong) FaceData *preData;

@property (nonatomic, assign) BOOL isWaiting;

@property (nonatomic, strong) NSMutableArray *sortArray;

@property (nonatomic, strong) NSMutableArray *headArray;

@property (nonatomic, assign) NSInteger errorTimes;

@end

@implementation RSECheckViewController

@synthesize captureManager;


#pragma mark - View lifecycle

-(void)dealloc{
    self.captureManager = nil;
    self.viewCanvas = nil;
}

- (void)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchCamera {
    [self.captureManager cameraToggle];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.title = @"活体检测";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor=[UIColor blackColor];
    _previewView = [[UIView alloc] initWithFrame:self.view.bounds];
    _previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_previewView];
    self.previewView.backgroundColor = [UIColor blackColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(20, 20, 60, 40)];
    [self.view addSubview:btn];
    
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    [switchBtn setBackgroundColor:[UIColor whiteColor]];
    [switchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [switchBtn setTitle:@"切换" forState:UIControlStateNormal];
    [switchBtn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 20, 60, 40)];
    [self.view addSubview:switchBtn];
    
    _promptLabel = [UILabel new];
    [_promptLabel setText:@"检测中..."];
    [_promptLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_promptLabel];
    [_promptLabel setFrame:CGRectMake(100, 20, [UIScreen mainScreen].bounds.size.width - 200, 40)];
    
    self.faceDetector=[IFlyFaceDetector sharedInstance];
    [self.faceDetector setParameter:@"1" forKey:@"align"];
    [self.faceDetector setParameter:@"1" forKey:@"detect"];
    //初始化 CaptureSessionManager
    self.captureManager=[[CaptureManager alloc] init];
    self.captureManager.delegate=self;
    
    self.previewLayer=self.captureManager.previewLayer;
    
    self.captureManager.previewLayer.frame = self.previewView.frame;
    self.captureManager.previewLayer.position = self.previewView.center;
    self.captureManager.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.captureManager.previewLayer];
    
    
    self.viewCanvas = [[CanvasView alloc] initWithFrame:self.captureManager.previewLayer.frame] ;
    [self.previewView addSubview:self.viewCanvas] ;
    self.viewCanvas.center=self.captureManager.previewLayer.position;
    self.viewCanvas.backgroundColor = [UIColor clearColor] ;
    
    [self.captureManager setup];
    [self.captureManager addObserver];
    [self reload];
}

- (void)reload {
    _currentStatus = kAuthFace;
    NSArray *array = @[@(kAuthMidFace), @(kAuthStatusMouth), @(kAuthStatusEye)];
    _sortArray = [NSMutableArray array];
    while (_sortArray.count < 3) {
        NSInteger index = arc4random() % 3;
        NSNumber *num = [array objectAtIndex:index];
        if (![_sortArray containsObject:num]) {
            [_sortArray addObject:num];
        }
    }
    
    array = @[@(kAuthStatusLeftShake), @(kAuthStatusRightShake)];
    _headArray = [NSMutableArray array];
    while (_headArray.count < 2) {
        NSInteger index = arc4random() % 2;
        NSNumber *num = [array objectAtIndex:index];
        if (![_headArray containsObject:num]) {
            [_headArray addObject:num];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.captureManager removeObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    [self.captureManager observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)authFace:(FaceData *)face {
    if (_isWaiting) {
        return;
    }
    
    switch (_currentStatus) {
        case kAuthFace:
            [_promptLabel setText:@"检测到人脸"];
            _currentStatus = [[_sortArray firstObject] integerValue];
            [_sortArray removeObject:[_sortArray firstObject]];
            [self wait];
            break;
        case kAuthStatusMouth:
            
            if (face.mouthWidth == 0 || face.mouthHeight == 0) {
                return;
            }
            
            [_promptLabel setText:@"检测张嘴"];
            NSLog(@"当前宽度:%f 和高度:%f", face.mouthWidth, face.mouthHeight);
            
            if (!_preData) {
                _preData = face;
            } else {
                if (ABS(face.mouthWidth - _preData.mouthWidth) > 20 && ABS(face.mouthHeight - _preData.mouthHeight) > 20) {
                    NSNumber *num = [_sortArray firstObject];
                    if (!num) {
                        _currentStatus = kAuthStatusSuccess;
                    } else {
                       _currentStatus = [num integerValue];
                        [_sortArray removeObject:num];
                    }
                    _preData = nil;
                    [_promptLabel setText:@"检测张嘴成功"];
                    [self wait];
                }
            }
            break;
        case kAuthMidFace:
        {
            NSLog(@"当前坐标:%@", NSStringFromCGPoint(face.position.origin));
            [_promptLabel setText:@"请保持居中"];
            CGFloat centerX = face.position.origin.x + face.position.size.width / 2.f;
            if (ABS(centerX - _previewView.center.x) < 10) {
                _preData = face;
                _currentStatus = [[_headArray firstObject] integerValue];
                [_headArray removeObject:[_headArray firstObject]];
                [self wait];
            }
            break;
        }
        case kAuthStatusLeftShake:
            [_promptLabel setText:@"请向左摇头"];
            NSLog(@"当前坐标:%@", NSStringFromCGPoint(face.position.origin));
            if (_preData.position.origin.x - face.position.origin.x > 50) {
                NSNumber *num = [_headArray firstObject];
                if (!num) {
                    NSNumber *num = [_sortArray firstObject];
                    if (!num) {
                        _currentStatus = kAuthStatusSuccess;
                    } else {
                        _currentStatus = [num integerValue];
                        [_sortArray removeObject:num];
                    }
                    _preData = nil;
                } else {
                    _currentStatus = [num integerValue];
                    [_headArray removeObject:num];
                }
                [_promptLabel setText:@"检测左摇成功"];
                [self wait];
            }
            break;
        case kAuthStatusRightShake:
        {
            [_promptLabel setText:@"请向右摇头"];
            NSLog(@"当前坐标:%@", NSStringFromCGPoint(face.position.origin));
            if (face.position.origin.x - _preData.position.origin.x > 50) {
                NSNumber *num = [_headArray firstObject];
                if (!num) {
                    NSNumber *num = [_sortArray firstObject];
                    if (!num) {
                        _currentStatus = kAuthStatusSuccess;
                    } else {
                        _currentStatus = [num integerValue];
                        [_sortArray removeObject:num];
                    }
                    _preData = nil;
                } else {
                    _currentStatus = [num integerValue];
                    [_headArray removeObject:num];
                }
                [_promptLabel setText:@"检测右摇成功"];
                [self wait];
            }
            break;
        }
        case kAuthStatusEye:
        {
            [_promptLabel setText:@"请眨眼"];
            if (_preData == nil) {
                _preData = face;
            } else {
                if (_preData.leftEyeHieght - face.leftEyeHieght > 3 || _preData.rightEyeHeight - face.rightEyeHeight > 3) {
                    NSNumber *num = [_sortArray firstObject];
                    if (!num) {
                        _currentStatus = kAuthStatusSuccess;
                    } else {
                        _currentStatus = [num integerValue];
                        [_sortArray removeObject:num];
                    }
                    [_promptLabel setText:@"检测眨眼成功"];
                    _preData = nil;
                }
            }
            break;
        }
        case kAuthStatusSuccess:
        {
            [_promptLabel setText:@"检测成功"];
            _preData = nil;
        }
        default:
            break;
    }
}

- (void)wait {
    _isWaiting = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isWaiting = NO;
    });
}

#pragma mark - Data Parser

- (void) showFaceLandmarksAndFaceRectWithPersonsArray:(NSMutableArray *)arrPersons{
    if (self.viewCanvas.hidden) {
        self.viewCanvas.hidden = NO ;
    }
    self.viewCanvas.arrPersons = arrPersons ;
    [self.viewCanvas setNeedsDisplay] ;
}

- (void) hideFace {
    if (!self.viewCanvas.hidden) {
        self.viewCanvas.hidden = YES ;
    }
}

-(NSString*)praseDetect:(NSDictionary* )positionDic OrignImage:(IFlyFaceImage*)faceImg {
    
    if(!positionDic){
        return nil;
    }
    
    
    
    // 判断摄像头方向
    BOOL isFrontCamera=self.captureManager.videoDeviceInput.device.position==AVCaptureDevicePositionFront;
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = self.previewLayer.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.previewLayer.frame.size.height / faceImg.width;
    
    CGFloat bottom =[[positionDic objectForKey:KCIFlyFaceResultBottom] floatValue];
    CGFloat top=[[positionDic objectForKey:KCIFlyFaceResultTop] floatValue];
    CGFloat left=[[positionDic objectForKey:KCIFlyFaceResultLeft] floatValue];
    CGFloat right=[[positionDic objectForKey:KCIFlyFaceResultRight] floatValue];
    
    
    float cx = (left+right)/2;
    float cy = (top + bottom)/2;
    float w = right - left;
    float h = bottom - top;
    
    float ncx = cy ;
    float ncy = cx ;
    
    CGRect rectFace = CGRectMake(ncx-w/2 ,ncy-w/2 , w, h);
    
    if(!isFrontCamera){
        rectFace=rSwap(rectFace);
        rectFace=rRotate90(rectFace, faceImg.height, faceImg.width);
    }
    
    rectFace=rScale(rectFace, widthScaleBy, heightScaleBy);
    
    return NSStringFromCGRect(rectFace);
    
}

-(NSMutableDictionary *)praseAlign:(NSDictionary* )landmarkDic OrignImage:(IFlyFaceImage*)faceImg{
    if(!landmarkDic){
        return nil;
    }
    
    // 判断摄像头方向
    BOOL isFrontCamera=self.captureManager.videoDeviceInput.device.position==AVCaptureDevicePositionFront;
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = self.previewLayer.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.previewLayer.frame.size.height / faceImg.width;
    
    NSMutableDictionary *arrStrPoints = [NSMutableDictionary dictionary] ;
    NSEnumerator* keys=[landmarkDic keyEnumerator];
    for(id key in keys){
        id attr=[landmarkDic objectForKey:key];
        if(attr && [attr isKindOfClass:[NSDictionary class]]){
            
            id attr=[landmarkDic objectForKey:key];
            CGFloat x=[[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
            CGFloat y=[[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
            
            CGPoint p = CGPointMake(y,x);
            
            if(!isFrontCamera){
                p=pSwap(p);
                p=pRotate90(p, faceImg.height, faceImg.width);
            }
            
            p=pScale(p, widthScaleBy, heightScaleBy);
            
            [arrStrPoints setObject:NSStringFromCGPoint(p) forKey:key];
            
        }
    }
    return arrStrPoints;
    
}


-(void)praseTrackResult:(NSString*)result OrignImage:(IFlyFaceImage*)faceImg{
    
    if(!result){
        return;
    }
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* faceDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        resultData=nil;
        if(!faceDic){
            return;
        }
        
        NSString* faceRet=[faceDic objectForKey:KCIFlyFaceResultRet];
        NSArray* faceArray=[faceDic objectForKey:KCIFlyFaceResultFace];
        faceDic=nil;
        
        int ret=0;
        if(faceRet){
            ret=[faceRet intValue];
        }
        //没有检测到人脸或发生错误
        if (ret || !faceArray || [faceArray count]<1) {
            if (_currentStatus != kAuthStatusSuccess && _currentStatus != kAuthMidFace) {
                _errorTimes ++;
                if (_errorTimes > 60) {
                    [self reload];
                    _errorTimes = 0;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_promptLabel setText:@"检测失败, 重新检测中..."];
                    } ) ;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideFace];
            } ) ;
            return;
        } else {
            _errorTimes = 0;
        }
        
        //检测到人脸
        
        NSMutableArray *arrPersons = [NSMutableArray array] ;
        
        for(id faceInArr in faceArray){
            
            if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                
                FaceData *face = [FaceData new];
                NSDictionary* positionDic=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                NSString* rectString=[self praseDetect:positionDic OrignImage: faceImg];
                positionDic=nil;
                face.position = CGRectFromString(rectString);
                
                NSDictionary* landmarkDic=[faceInArr objectForKey:KCIFlyFaceResultLandmark];
                
                NSMutableDictionary *pointDic = [self praseAlign:landmarkDic OrignImage:faceImg] ;
                [face setPoint:pointDic];
                NSArray* strPoints=[pointDic allValues];
                landmarkDic=nil;
                
                
                NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
                if(rectString){
                    [dicPerson setObject:rectString forKey:RECT_KEY];
                }
                if(strPoints){
                    [dicPerson setObject:strPoints forKey:POINTS_KEY];
                }
                
                strPoints=nil;
                
                [dicPerson setObject:@"0" forKey:RECT_ORI];
                [arrPersons addObject:dicPerson] ;
                dicPerson=nil;
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self authFace:face];
                    [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
                } ) ;
            }
        }
        faceArray=nil;
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
}

#pragma mark - CaptureManagerDelegate

-(void)onOutputFaceImage:(IFlyFaceImage*)faceImg{
    
    NSString* strResult=[self.faceDetector trackFrame:faceImg.data withWidth:faceImg.width height:faceImg.height direction:(int)faceImg.direction];
    NSLog(@"result:%@",strResult);
    
    //此处清理图片数据，以防止因为不必要的图片数据的反复传递造成的内存卷积占用。
    faceImg.data=nil;
    
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(praseTrackResult:OrignImage:)];
    if (!sig) return;
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self];
    [invocation setSelector:@selector(praseTrackResult:OrignImage:)];
    [invocation setArgument:&strResult atIndex:2];
    [invocation setArgument:&faceImg atIndex:3];
    [invocation retainArguments];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil  waitUntilDone:NO];
    faceImg=nil;
}

@end
