//
//  FRNodeModel.h
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, kFRNodeType){
    
    //文件夹
    kFRNodeTypeFolder = 0,
    
    //Doc文件
    kFRNodeTypeDocFile,
    
    //PDF文件
    kFRNodeTypePDFFile,
    
    //未知
    kFRNodeTypeUnknown,
};

@interface FRNodeModel : NSObject

@property(nonatomic,strong) NSString* nodeName;
@property(nonatomic,strong) NSString* nodePath;
@property(nonatomic,strong) NSArray*  children;

@property(nonatomic,assign) BOOL isSelected;
@property(nonatomic,assign) NSInteger nodeLevel;
@property(nonatomic,assign) kFRNodeType nodeType;

-(instancetype)initWithName:(NSString*)name path:(NSString*)path level:(NSInteger)level type:(kFRNodeType)type;


@end
