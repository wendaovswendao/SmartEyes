//
//  RSEIDViewController.m
//  R360SmartEyes
//
//  Created by Liudequan on 2017/2/25.
//  Copyright © 2017年 R360. All rights reserved.
//

#import "RSEIDViewController.h"

@interface RSEIDViewController ()

@end

@implementation RSEIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.layer.borderColor = [UIColor blackColor].CGColor;
    backButton.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor whiteColor];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(10, 50, 100, 50);
    [self.view addSubview:backButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
