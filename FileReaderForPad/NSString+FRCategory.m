//
//  NSString+FRCategory.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "NSString+FRCategory.h"

@implementation NSString (FRCategory)

-(BOOL)stringIsNilOrEmpty{
    return !(self && self.length);
}


+(NSString*)documentPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
//    NSLog(@"NSDocumentDirectory:%@",documentsDirectory);
    return documentsDirectory;
}

@end
