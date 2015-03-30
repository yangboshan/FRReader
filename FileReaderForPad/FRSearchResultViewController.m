//
//  FRSearchResultViewController.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/30.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "FRSearchResultViewController.h"

@interface FRSearchResultViewController ()

@property (nonatomic,strong) NSArray* data;

@end

@implementation FRSearchResultViewController

-(instancetype)initWithData:(NSArray*)data{
    if (self = [super init]) {
        _data = data;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
