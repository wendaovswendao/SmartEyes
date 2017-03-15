//
//  ViewController.m
//  R360SmartEyes
//
//  Created by Liudequan on 2017/2/24.
//  Copyright © 2017年 R360. All rights reserved.
//

#import "ViewController.h"
#import "RSEIDViewController.h"
#import "RSECheckViewController.h"
#import "RSECreditCardViewController.h"
#import "REIDAuthenticationViewController.h"
#import <UIKit/UIKit.h>

@interface RSEButton : UIButton

@end

@implementation RSEButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1/[UIScreen mainScreen].scale;
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end

@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    RSEButton *button = [RSEButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"身份证" forState:UIControlStateNormal];
    button.frame = CGRectMake(10, 50, 100, 50);
    [button addTarget:self action:@selector(gotoIDCardVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    RSEButton *deteBtn = [RSEButton buttonWithType:UIButtonTypeCustom];
    [deteBtn setTitle:@"活体检测" forState:UIControlStateNormal];
    deteBtn.frame = CGRectMake(10, 150, 100, 50);
    [deteBtn addTarget:self action:@selector(gotoLivingDetectionVc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deteBtn];
    
    RSEButton *button1 = [RSEButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitle:@"信用卡" forState:UIControlStateNormal];
    button1.frame = CGRectMake(10, 220, 100, 50);
    [button1 addTarget:self action:@selector(gotoCreditCardVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    RSEButton *button2 = [RSEButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"身份认证" forState:UIControlStateNormal];
    button2.frame = CGRectMake(10, 300, 100, 50);
    [button2 addTarget:self action:@selector(gotoIDAuthenticationVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoIDCardVC {
    RSEIDViewController *idCardVC = [[RSEIDViewController alloc] init];
    [self presentViewController:idCardVC animated:YES completion:nil];
}

- (void)gotoLivingDetectionVc {
    RSECheckViewController *vc = [RSECheckViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)gotoCreditCardVC {
    RSECreditCardViewController *creditCardVC = [[RSECreditCardViewController alloc] init];
    [self presentViewController:creditCardVC animated:YES completion:nil];
}


- (void)gotoIDAuthenticationVC {
    REIDAuthenticationViewController *vc  = [[REIDAuthenticationViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
