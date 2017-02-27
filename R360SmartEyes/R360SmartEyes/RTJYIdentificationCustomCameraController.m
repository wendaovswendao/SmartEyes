//
//  RTJYIdentificationCustomCameraController.m
//  Pods
//
//  Created by 郑明星 on 16/1/9.
//
//

#import "RTJYIdentificationCustomCameraController.h"
#import "LLSimpleCamera.h"
#import "CustomCameraHelper.h"
#import "LLSimpleCamera.h"
#import "RDPImage.h"
#import "Masonry.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;


typedef NS_ENUM(NSUInteger, CustomCameraTakePhotoState) {
    CustomCameraTakePhotoStateDoing = 54,
    CustomCameraTakePhotoStateDone,
};
@interface RTJYIdentificationCustomCameraController ()
@property (nonatomic, strong) LLSimpleCamera *llSimpleCamera;
@property (nonatomic, strong) UIImageView *resultImageView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *retakeButton;
@property (nonatomic, strong) UILabel *recognizeLabel;
@end

@implementation RTJYIdentificationCustomCameraController
#pragma mark - LifeCycle
- (instancetype)initWithType:(CustomCameraType)type {
    self = [super init];
    if (self){
        self.cameraType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor=[UIColor blackColor];
    
    CGFloat width=self.view.bounds.size.width;
    CGFloat height=[UIScreen mainScreen].bounds.size.height;
    
    LLSimpleCamera *llSimpleCamera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh position:LLCameraPositionRear videoEnabled:NO];
    self.llSimpleCamera=llSimpleCamera;
    [llSimpleCamera attachToViewController:self withFrame:CGRectMake(0, 0, width, height)];
    llSimpleCamera.fixOrientationAfterCapture = NO;
    
    WS(weakSelf);
    [llSimpleCamera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusDenied || status==AVAuthorizationStatusRestricted) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""message:@"照片权限被禁用，请在设置-隐私-相机中开启" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"我知道了"style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                   [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    [self configCustomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.llSimpleCamera start];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.llSimpleCamera stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
}
#pragma mark - Selectors
- (void)takePhotoButtonDidClick:(UIButton *)button{
    if (button.tag == CustomCameraTakePhotoStateDoing){
        WS(weakSelf);
        [self.llSimpleCamera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            if(!error) {
                button.tag=CustomCameraTakePhotoStateDone;
                [button setBackgroundImage:[RDPImage imageForName:@"identification_definite" bundle:nil] forState:UIControlStateNormal];
                weakSelf.bgImageView.image = [CustomCameraHelper backgroundImageWithName:@"identification_custom_camera_bg"];
                weakSelf.retakeButton.hidden=NO;
                weakSelf.recognizeLabel.hidden=NO;
                
                // we should stop the camera, since we don't need it anymore. We will open a new vc.
                // this very important, otherwise you may experience memory crashes
                [camera stop];
                // show the image
                weakSelf.resultImageView.image=image;
                
            }else {
            }
        } exactSeenImage:YES];
    }else{
        if ([self.delegate respondsToSelector:@selector(customCameraController:didSelectPhoto:)]){
            [self.delegate customCameraController:self didSelectPhoto:self.resultImageView.image];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)retakePhotoButtonDidClick{
    [self.takePhotoButton setBackgroundImage:[RDPImage imageForName:@"identification_camera_unable" bundle:nil] forState:UIControlStateNormal];
    self.takePhotoButton.tag = CustomCameraTakePhotoStateDoing;
    UIImage *bgImage= nil;
    if (self.cameraType == CustomCameraTypeFront) {
        bgImage = [CustomCameraHelper backgroundImageWithName:@"identification_bg_front"];
    }else{
        bgImage = [CustomCameraHelper backgroundImageWithName:@"identification_bg_back"];
    }
    self.bgImageView.image=bgImage;
    self.retakeButton.hidden=YES;
    self.recognizeLabel.hidden=YES;
    self.resultImageView.image=nil;
    [self.llSimpleCamera start];
}
#pragma mark - Private Methods
- (CGRect)rahmenFrameAccordingToDevice{
    CGSize size=[UIScreen mainScreen].bounds.size;
    NSInteger width=(NSInteger)size.width;
    NSInteger height=(NSInteger)size.height;
    if (width==320){
        if (height==480){
            return CGRectMake(64, 72, 282, 176);
        }else if(height==568){
            return CGRectMake(74, 49, 354, 224);
        }
    }else if (width==375){
        return CGRectMake(86, 58, 414, 262);
    }else if(width==414){
        return CGRectMake(95, 63, 458, 288);
    }
    return CGRectMake(86, 58, 414, 262);
}

- (void)configCustomView {
    CGFloat width=self.view.bounds.size.width;
    CGFloat height=self.view.bounds.size.height;
    
    self.resultImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.resultImageView];
    
    UIView *transformView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    transformView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:transformView];
    transformView.transform = CGAffineTransformMakeRotation(M_PI * (90) / 180.0);
    transformView.bounds = CGRectMake(0, 0, height, width);
    
    //底部背景图
    UIImage *bgImage= nil;
    if (self.cameraType == CustomCameraTypeFront) {
        bgImage = [CustomCameraHelper backgroundImageWithName:@"identification_bg_front"];
    }else{
        bgImage = [CustomCameraHelper backgroundImageWithName:@"identification_bg_back"];
    }
    UIImageView *bgImageView= [[UIImageView alloc] initWithImage:bgImage];
    self.bgImageView=bgImageView;
    bgImageView.frame=CGRectMake(0, 0, height, width);
    [transformView addSubview:bgImageView];
    
    //右边背景图
    bgImage=[CustomCameraHelper backgroundImageWithName:@"identification_bar_bg"];
    UIImageView *rightBgImageView=[[UIImageView alloc]initWithImage:bgImage];
    rightBgImageView.userInteractionEnabled=YES;
    rightBgImageView.frame=CGRectMake(height-bgImage.size.width, 0, bgImage.size.width, bgImage.size.height);
    [transformView addSubview:rightBgImageView];
    
    //文字说明
    UILabel *topInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    topInfoLabel.font = [UIFont systemFontOfSize:15];
    topInfoLabel.textColor = [UIColor blackColor];
    topInfoLabel.textAlignment = NSTextAlignmentCenter;
    if (self.cameraType == CustomCameraTypeFront){
        topInfoLabel.text=@"拍摄身份证带有头像的一面,对齐边缘";
    }else{
        topInfoLabel.text=@"拍摄身份证带有国徽的一面,对齐边缘";
    }
    CGRect frame= [self rahmenFrameAccordingToDevice];
    topInfoLabel.frame=CGRectMake(frame.origin.x, 0, frame.size.width, frame.origin.y);
    [transformView addSubview:topInfoLabel];
    
    UILabel *bottomInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    bottomInfoLabel.font = [UIFont systemFontOfSize:15];;
    bottomInfoLabel.textColor = [UIColor blackColor];;
    bottomInfoLabel.textAlignment = NSTextAlignmentCenter;
    bottomInfoLabel.text=@"为了提高识别率,仅支持横屏拍摄";
    CGFloat y=frame.origin.y+frame.size.height;
    bottomInfoLabel.frame=CGRectMake(frame.origin.x, y, frame.size.width, width-y);
    [transformView addSubview:bottomInfoLabel];
    
    //关闭按钮
    UIImage *closeImage = [RDPImage imageForName:@"identification_close" bundle:nil];
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:closeImage forState:UIControlStateNormal];
    [button setBackgroundImage:nil forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    button.frame=CGRectMake(0, 0, closeImage.size.width, closeImage.size.height);
    [transformView addSubview:button];
    
    
    //拍照按钮
    UIImage *takePhotoImage = [RDPImage imageForName:@"identification_camera_unable" bundle:nil];
    self.takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.takePhotoButton.tag = CustomCameraTakePhotoStateDoing;
    [self.takePhotoButton setBackgroundImage:takePhotoImage forState:UIControlStateNormal];
    [self.takePhotoButton addTarget:self action:@selector(takePhotoButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightBgImageView addSubview:self.takePhotoButton];
    [self.takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(takePhotoImage.size.width);
        make.height.mas_equalTo(takePhotoImage.size.height);
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
    //重拍
    self.retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.retakeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.retakeButton setTitle:@"重拍" forState:UIControlStateNormal];
    [self.retakeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.retakeButton addTarget:self action:@selector(retakePhotoButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.retakeButton.hidden = YES;
    [rightBgImageView addSubview:self.retakeButton];
    [self.retakeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.takePhotoButton);
        make.bottom.mas_equalTo(self.takePhotoButton.mas_top).offset(-60);
    }];
    
    //识别
    self.recognizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.recognizeLabel.font = [UIFont systemFontOfSize:15];
    self.recognizeLabel.textColor = [UIColor blackColor];
    self.recognizeLabel.textAlignment = NSTextAlignmentCenter;
    self.recognizeLabel.text = @"识别";
    self.recognizeLabel.hidden = YES;
    [rightBgImageView addSubview:self.recognizeLabel];
    [self.recognizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.takePhotoButton);
        make.top.mas_equalTo(self.takePhotoButton.mas_bottom).offset(5);
    }];
    
}

- (void)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
