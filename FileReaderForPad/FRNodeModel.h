//
//  FRNodeModel.h
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRModel.h"


typedef NS_ENUM(NSInteger, kFRNodeType){
    
    //文件夹
    kFRNodeTypeFolder = 0,
    
    //Doc文件
    kFRNodeTypeDocFile,
    
    //PDF文件
    kFRNodeTypePDFFile,
    
    //其他文件
    kFRNodeTypeDocument,
    
    //未知
    kFRNodeTypeUnknown,
};

@interface FRNodeModel : NSObject

//节点名称
@property(nonatomic,strong) NSString* nodeName;

//节点路径
@property(nonatomic,strong) NSString* nodePath;

//父亲节点
@property(nonatomic,strong) FRNodeModel* parent;

//子节点集合
@property(nonatomic,strong) NSMutableArray*  children;

@property(nonatomic,assign) BOOL isSelected;

//节点层级
@property(nonatomic,assign) NSInteger nodeLevel;

//节点类型
@property(nonatomic,assign) kFRNodeType nodeType;

-(instancetype)initWithName:(NSString*)name path:(NSString*)path level:(NSInteger)level type:(kFRNodeType)type;


@end
