//
//  DetailViewController.h
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>


@interface DetailViewController : UIViewController<QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@end

