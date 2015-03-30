//
//  SGScanViewController.m
//  SGClient
//
//  Created by JY on 14-6-15.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import "FRScanViewController.h"
#import "FRMacro.h"
#import "PureLayout.h"
#import "FRModel.h"
#import "FRSearchResultViewController.h"



@interface FRScanViewController ()

@property(nonatomic,copy) SendSearchResult scanFinishBlock;
@end

@implementation FRScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(instancetype)initWithFinishBlock:(SendSearchResult)finish{
    self = [super init];
    if (self) {
        self.scanFinishBlock = finish;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    NSLog(@"%f  %f",self.view.frame.size.width,self.view.frame.size.height);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
	UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [scanButton setTitle:@"取消" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scanButton.titleLabel setFont:Lantinghei(22)];
    scanButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [scanButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    
    [scanButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    [scanButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [scanButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [scanButton autoSetDimension:ALDimensionHeight toSize:40];


    
    
    
    UILabel * labIntroudction= [[UILabel alloc] init];
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"将二维码图像置于矩形方框内，离摄像头10CM左右。";
    [self.view addSubview:labIntroudction];
    
    [labIntroudction autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [labIntroudction autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [labIntroudction autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [labIntroudction autoSetDimension:ALDimensionHeight toSize:50];
    
    
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:150];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:150];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:150];
    [imageView autoSetDimension:ALDimensionWidth toSize:300];
    [imageView autoSetDimension:ALDimensionHeight toSize:300];

    
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(160, 160, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(160, 160+2*num, 220, 2);
        if (2*num == 280) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(160, 160+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}
-(void)backAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self setupCamera];
    [self setOrientationForCamara:self.interfaceOrientation];
}
- (void)setupCamera
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];

    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =CGRectMake(0,0,600,620);
    [self.view.layer insertSublayer:self.preview atIndex:0];

    [_session startRunning];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    [timer invalidate];
    
    stringValue = @"核心动画编程指南1.pdf";
    NSArray* results = [[FRModel sharedFRModel] searchDirectoryByFileName:stringValue];
    
    if (results.count) {
        if (results.count>1) {
            FRSearchResultViewController *searchResult = [[FRSearchResultViewController alloc] initWithData:results block:^(NSString *file) {
                [self dismissViewControllerAnimated:YES completion:^{
                    self.scanFinishBlock(file,kFRScanResultFlagNormal);
                }];
            }];
            [self.navigationController pushViewController:searchResult animated:NO];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                self.scanFinishBlock(results[0],kFRScanResultFlagNormal);
            }];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            self.scanFinishBlock(stringValue,kFRScanResultFlagNone);
        }];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    [self setOrientationForCamara:toInterfaceOrientation];
}

-(void)setOrientationForCamara:(UIInterfaceOrientation)orientation{
    
    AVCaptureConnection *previewLayerConnection=self.preview.connection;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
        case UIInterfaceOrientationUnknown:
            break;
    }
}
@end
