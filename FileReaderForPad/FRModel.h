//
//  FRModel.h
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRGCDSingleton.h"


@interface FRModel : NSObject

+(FRModel*)sharedFRModel;

+(NSString*)documentPath;

-(NSMutableArray*)getFileTreeByPath:(NSString*)path level:(NSInteger)level;

@end
