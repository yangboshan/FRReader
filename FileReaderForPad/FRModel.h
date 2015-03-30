//
//  FRModel.h
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRGCDSingleton.h"

@class FRNodeModel;

@interface FRModel : NSObject

+(FRModel*)sharedFRModel;

-(NSMutableArray*)getFileTreeByNodeModel:(FRNodeModel*)nodeModel;

-(BOOL)createFolderByPath:(NSString*)folderPath;

-(BOOL)deleteByPath:(NSString*)path;

-(BOOL)renameByPath1:(NSString*)path1 path2:(NSString*)path2 ;

-(NSArray*)searchDirectoryByFileName:(NSString*)file;

@end
