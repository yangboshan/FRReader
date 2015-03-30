//
//  FRNodeModel.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "FRNodeModel.h"
#import "FRModel.h"
#import "NSString+FRCategory.h"


@implementation FRNodeModel

-(instancetype)initWithName:(NSString*)name path:(NSString*)path level:(NSInteger)level type:(kFRNodeType)type{
    if (self = [super init]) {
        _nodeName = name;
        _nodePath = path;
        _nodeLevel = level;
        _nodeType = type;
    }
    return self;
}

-(BOOL)isEqual:(id)object{
    
    if ([object class]!=[FRNodeModel class]) {
        return NO;
    }
    
    FRNodeModel* nodeModel = object;
    if ([nodeModel.nodePath isEqualToString:self.nodePath]) {
        return YES;
    }
    
    return NO;
}

//根据树结构 动态获取节点路径
-(NSString*)nodePath{
    
    if (self.nodeLevel == 0) {
        
        return [NSString documentPath];
        
    } else{
        
        if (self.parent) {
                    
            return [self.parent.nodePath stringByAppendingPathComponent:self.nodeName];
            
        }else{
            
            return [[NSString documentPath] stringByAppendingPathComponent:self.nodeName];
        }
    }
}

@end
