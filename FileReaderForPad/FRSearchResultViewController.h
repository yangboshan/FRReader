//
//  FRSearchResultViewController.h
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/30.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UserDidSelectFile)(NSString* file);

@interface FRSearchResultViewController : UIViewController

-(instancetype)initWithData:(NSArray*)data block:(UserDidSelectFile)block;
@end
