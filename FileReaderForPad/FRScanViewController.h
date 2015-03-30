//
//  SGScanViewController.h
//  SGClient
//
//  Created by JY on 14-6-15.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>



@interface FRScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;

@end
