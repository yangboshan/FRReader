//
//  FRSettingManager.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/28.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "FRSettingManager.h"
#import "NSString+FRCategory.h"


static NSString *SETTING_FIRST_TIME_RUN = @"SETTING_FIRST_TIME_RUN";

@interface FRSettingManager()

@property(nonatomic,strong) NSUserDefaults* userDefaults;
@property(nonatomic,strong) NSArray* folderList;

@end

@implementation FRSettingManager

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(FRSettingManager)

-(instancetype)init{
    
    if (self = [super init]) {
        
        NSObject *setting = [self.userDefaults objectForKey:SETTING_FIRST_TIME_RUN];
        
        if (!setting) {
            
            [self.userDefaults setObject:@(1) forKey:SETTING_FIRST_TIME_RUN];
            [self buildFolders];
        }
    }
    return self;
}

-(void)buildFolders{
    [self.folderList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString documentPath] stringByAppendingPathComponent:obj] withIntermediateDirectories:NO attributes:nil error:nil];
    }];
}

-(NSArray*)folderList{
    if (!_folderList) {
        _folderList = @[@"操作规程",@"说明书",@"调试纪录",@"定值单"];
    }
    return _folderList;
}

-(NSUserDefaults*)userDefaults{
    
    if (!_userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return _userDefaults;
}

@end
