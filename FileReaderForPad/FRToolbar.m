//
//  FRToolbar.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/28.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "FRToolbar.h"
#import "PureLayout.h"
#import "FRMacro.h"
#import "UIImage+FRCategory.h"


@implementation FRToolbar

-(void)awakeFromNib{
    
    [self.scanBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.scanBtn.titleLabel setFont:Lantinghei(18.0)];
    [self.scanBtn setImageEdgeInsets:UIEdgeInsetsMake(-1, -5, 0, 0)];
    [self.scanBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    
    
    [self.searchBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.searchBtn.titleLabel setFont:Lantinghei(18.0)];
    [self.searchBtn setImageEdgeInsets:UIEdgeInsetsMake(-1, -5, 0, 0)];
    [self.searchBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    
    [self.settingBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.settingBtn.titleLabel setFont:Lantinghei(18.0)];
    [self.settingBtn setImageEdgeInsets:UIEdgeInsetsMake(-1, -5, 0, 0)];
    [self.settingBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    
    [self.toolbar setBackgroundImage:[UIImage imageWithColor:RGBA(247, 247, 247,0.9)] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}


-(void)didMoveToSuperview{
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self autoSetDimension:ALDimensionWidth toSize:ScreenWidth];
    [self autoSetDimension:ALDimensionHeight toSize:44];
    [self autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [self autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
}
@end
