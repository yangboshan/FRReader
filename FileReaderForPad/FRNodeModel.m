//
//  FRNodeModel.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "FRNodeModel.h"

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

//节点路径
-(NSString*)nodePath{
    
    if (!self.parent) {
        return [[FRModel documentPath] stringByAppendingString:self.nodeName];
    } else{
        return [self.parent.nodePath stringByAppendingPathComponent:self.nodeName];
    }
}

@end
