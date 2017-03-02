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
    _imageView.frame = CGRectMake(0, 120, width, width);
    [self.view addSubview:_imageView];
    
    _textLabel = [UILabel new];
    [_textLabel setFrame:CGRectMake((width - 200) / 2, 100 , 200, 20)];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    [_textLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:_textLabel];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(20, 40, 100, 50)];
    [self.view addSubview:closeBtn];
    
    UIButton *caremaBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [caremaBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [caremaBtn addTarget:self action:@selector(openCarema:) forControlEvents:UIControlEventTouchUpInside];
    [caremaBtn setFrame:CGRectMake(20, height - 90, 100, 50)];
    [self.view addSubview:caremaBtn];
    
    UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [uploadBtn addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
    [uploadBtn setFrame:CGRectMake(width - 120, height - 90, 100, 50)];
    [self.view addSubview:uploadBtn];
    
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_imageView addSubview:_loadingView];
    _loadingView.center = CGPointMake(_imageView.bounds.size.width / 2.f, _imageView.bounds.size.height / 2.f);
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
    NSData *data = UIImageJPEGRepresentation(_img , 1);
    NSString *base64 = [data base64String];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:base64 forKey:@"base64"];
    
    NSString *urlStr = @"http://10.2.129.89:8080/crawler-web/openapi/creditcard/activity/faceDetect.json";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableSet *set = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [set addObject:@"text/plain"];
    [set addObject:@"text/html"];
    
    
    manager.responseSerializer.acceptableContentTypes = set;
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
        [_imageView setImage:newImg];
        
        NSString *prompt = [responseObject objectForKey:@"similary"];
        [_textLabel setText:[NSString stringWithFormat:@"相似度:%@", prompt]];
        [_loadingView setHidden:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败");
        [_loadingView setHidden:YES];
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
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = _img;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
