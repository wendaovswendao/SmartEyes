//
//  REIDAuthenticationViewController.m
//  R360SmartEyes
//
//  Created by Liudequan on 2017/3/1.
//  Copyright © 2017年 R360. All rights reserved.
//

#import "REIDAuthenticationViewController.h"
#import <AFNetworking.h>
#import <Base64/MF_Base64Additions.h>
#import <Toast/UIView+Toast.h>
#import "UIImage+Extensions.h"
#import <Masonry.h>

@interface REIDAuthenticationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation REIDAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"人脸对比";
    self.imagePicker.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _imageView = [UIImageView new];
    _imageView.frame = self.view.bounds;
    [_imageView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(100);
        make.bottom.mas_equalTo(-100);
    }];
    
    _textLabel = [UILabel new];
    [_textLabel setFrame:CGRectMake((width - 200) / 2, 100 , 200, 20)];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    [_textLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:_textLabel];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.layer.borderColor = [UIColor blackColor].CGColor;
    closeBtn.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    closeBtn.backgroundColor = [UIColor whiteColor];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(20, 40, 100, 50)];
    [self.view addSubview:closeBtn];
    
    UIButton *caremaBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    caremaBtn.layer.borderColor = [UIColor blackColor].CGColor;
    caremaBtn.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    [caremaBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    caremaBtn.backgroundColor = [UIColor whiteColor];
    [caremaBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [caremaBtn addTarget:self action:@selector(openCarema:) forControlEvents:UIControlEventTouchUpInside];
    [caremaBtn setFrame:CGRectMake(20, height - 90, 100, 50)];
    [self.view addSubview:caremaBtn];
    
    UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    uploadBtn.layer.borderColor = [UIColor blackColor].CGColor;
    uploadBtn.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    [uploadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    uploadBtn.backgroundColor = [UIColor whiteColor];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [uploadBtn addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
    [uploadBtn setFrame:CGRectMake(width - 120, height - 90, 100, 50)];
    [self.view addSubview:uploadBtn];
    
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [uploadBtn addSubview:_loadingView];
    _loadingView.center = CGPointMake(uploadBtn.bounds.size.width / 2.f, uploadBtn.bounds.size.height / 2.f);
    [_loadingView setHidden:YES];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
    }
    return _imagePicker;
}

- (void)upload {
    NSData *data = UIImageJPEGRepresentation([_img imageRotatedByDegrees:90], 0.1);
    NSString *base64 = [data base64String];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:base64 forKey:@"base64"];
    
    NSString *urlStr = @"http://10.0.128.42:8080/crawler-web/openapi/creditcard/activity/faceDetect.json";
    [_textLabel setText:@""];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableSet *set = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [set addObject:@"text/plain"];
    [set addObject:@"text/html"];
    
    
    manager.responseSerializer.acceptableContentTypes = set;
    manager.requestSerializer.timeoutInterval = 2 * 60;
    [_loadingView setHidden:NO];
    [_loadingView startAnimating];
    [manager POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"responseObject = %@", responseObject);
        
        NSString *status = [responseObject objectForKey:@"status"];
        if ([status isEqualToString:@"success"]) {
            [self.view makeToast:@"检测成功"];
        } else {
            [self.view makeToast:@"检测失败"];
        }
        
        NSString *base64Img = [responseObject objectForKey:@"base64"];
        NSData *data = [NSData dataWithBase64String:base64Img];
        UIImage *newImg = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_imageView setImage:newImg];
            
            NSString *prompt = [responseObject objectForKey:@"similary"];
           
            [_textLabel setText:[NSString stringWithFormat:@"相似度:%.2f%%",  prompt.floatValue * 100]];
            [_loadingView setHidden:YES];
            [_loadingView stopAnimating];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:@"上传失败"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_loadingView setHidden:YES];
            [_loadingView stopAnimating];
        });
    }];
}

#pragma mark - 拍照
- (void)openCarema:(id)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"需要真机运行，才能打开相机哦" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    _imagePicker.allowsEditing = false;
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    _img = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(_img, 0.1);
    _img = [UIImage imageWithData:data];
    _imageView.image = _img;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
