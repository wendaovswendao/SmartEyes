//
//  RSEIDViewController.m
//  R360SmartEyes
//
//  Created by Liudequan on 2017/2/25.
//  Copyright © 2017年 R360. All rights reserved.
//

#import "RSEIDViewController.h"
#import "RTJYIdentificationCustomCameraController.h"
#import "UIImage+R360SmartEyes.h"
#import <TesseractOCR/TesseractOCR.h>
#import "CustomCameraHelper.h"

@interface RSEIDViewController ()<RTJYIdentificationCustomCameraControllerDelegate,G8TesseractDelegate>


/**
 头像ImageView
 */
@property (nonatomic, strong) UIImageView *imageView;


/**
 名字
 */
@property (nonatomic, strong) UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *IDNumberLabel;
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
    
    
    
    UIButton *button_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button_1.layer.borderColor = [UIColor blackColor].CGColor;
    button_1.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    [button_1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button_1.backgroundColor = [UIColor whiteColor];
    [button_1 setTitle:@"拍照" forState:UIControlStateNormal];
    [button_1 addTarget:self action:@selector(showIDViewController) forControlEvents:UIControlEventTouchUpInside];
    button_1.frame = CGRectMake(10, 110, 100, 50);
    [self.view addSubview:button_1];
    
    self.imageView = [UIImageView new];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = CGRectMake(10, 170, 214, 135);
    self.imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.backgroundColor  = [UIColor greenColor];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.frame = CGRectMake(10, 320, 400, 50);
    [self.view addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *IDNumberLabel = [UILabel new];
    IDNumberLabel.backgroundColor  = [UIColor greenColor];
    IDNumberLabel.font = [UIFont systemFontOfSize:15];
    IDNumberLabel.textColor = [UIColor whiteColor];
    IDNumberLabel.frame = CGRectMake(10, 380, 400, 50);
    [self.view addSubview:IDNumberLabel];
    self.IDNumberLabel = IDNumberLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showIDViewController {
    RTJYIdentificationCustomCameraController *vc = [[RTJYIdentificationCustomCameraController alloc] initWithType:CustomCameraTypeFront];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 
#pragma mark - RTJYIdentificationCustomCameraControllerDelegate delegate
- (void)customCameraController:(RTJYIdentificationCustomCameraController*)controller didSelectPhoto:(UIImage *)originImage {
    UIImage *orientationFixedImage = [UIImage imageWithCGImage:originImage.CGImage
                                                         scale:originImage.scale
                                                   orientation:UIImageOrientationUp];
    
    UIImage *image = [orientationFixedImage getSubImage:[CustomCameraHelper getImageRect]];

    
    UIImage* resizeImage =  [image resizedImageToFitInSize:CGSizeMake(856, 540) scaleIfSmaller:YES];
     
    self.imageView.image = resizeImage;
    [self OCR:resizeImage];
}

/*OCR Method Implementation*/
-(void)OCR:(UIImage *)image{
    // Create RecognitionOperation
    
    //    CGRect nameRect = CGRectMake(40*4, 16*4, 35*4, 15*4);
    //
    //    CGRect IDNumberRect = CGRectMake(70*4, 108*4, 123*4, 15*4);
    
    
    CGRect nameRect = CGRectMake(150, 65, 260, 70);
    
    CGRect IDNumberRect = CGRectMake(260, 420, 500, 60);
    
    
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"chi_sim"];
    
    // Configure inner G8Tesseract object as described before
    //    operation.tesseract.charWhitelist = @"01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    operation.tesseract.image = [image g8_blackAndWhite];
    
    
    //
    //    NSString* filePath =[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"blackAndWhite.jpg"];
    //
    //    NSLog(@"%@",filePath);
    //    [UIImageJPEGRepresentation(operation.tesseract.image, 1) writeToFile:filePath atomically:YES];
    
    
    operation.tesseract.delegate=self;
    operation.tesseract.rect = nameRect;
    // Setup the recognitionCompleteBlock to receive the Tesseract object
    // after text recognition. It will hold the recognized text.
    
    //    __weak typeof(operation) weakOperation = operation;
    
    operation.recognitionCompleteBlock = ^(G8Tesseract *recognizedTesseract) {
        // Retrieve the recognized text upon completion
        
        //        __strong typeof(weakOperation) strongOperation = weakOperation;
        //
        //         NSArray *characterBoxes = [strongOperation.tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelSymbol];
        //
        //
        //        UIImage* image2 =   [strongOperation.tesseract imageWithBlocks:characterBoxes drawText:YES thresholded:YES];
        //
        //         UIImageWriteToSavedPhotosAlbum(image2, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        NSLog(@" OCR TEXT NAME: %@", [recognizedTesseract recognizedText]);
        if ([recognizedTesseract recognizedText].length > 0) {
            self.nameLabel.text =[@"姓名:" stringByAppendingString: [recognizedTesseract recognizedText]];
        }
    };
    
    
    
    
    
    // Add operation to queue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    
    
    
    
    G8RecognitionOperation *operation2 = [[G8RecognitionOperation alloc] initWithLanguage:@"chi_sim"];
    
    // Configure inner G8Tesseract object as described before
    operation2.tesseract.charWhitelist = @"1234567890X";
    operation2.tesseract.image = [image g8_blackAndWhite];
    operation2.tesseract.delegate=self;
    operation2.tesseract.rect = IDNumberRect;
    // Setup the recognitionCompleteBlock to receive the Tesseract object
    // after text recognition. It will hold the recognized text.
    operation2.recognitionCompleteBlock = ^(G8Tesseract *recognizedTesseract) {
        // Retrieve the recognized text upon completion
        NSLog(@" OCR TEXT IDNumber:%@", [recognizedTesseract recognizedText]);
        if ([recognizedTesseract recognizedText].length > 0) {
            self.IDNumberLabel.text = [@"身份证号:" stringByAppendingString:[recognizedTesseract recognizedText]];
        }
    };
    
    
    [queue addOperation:operation2];
    
    
}

#pragma mark - 
#pragma mark - G8TesseractDelegate methods

@end
