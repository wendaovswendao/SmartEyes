//
//  ViewController.m
//  R360SmartEyes
//
//  Created by Liudequan on 2017/2/24.
//  Copyright © 2017年 R360. All rights reserved.
//

#import "ViewController.h"
#import "RSEIDViewController.h"

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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoIDCardVC {
    RSEIDViewController *idCardVC = [[RSEIDViewController alloc] init];
    [self presentViewController:idCardVC animated:YES completion:nil];
}


@end
