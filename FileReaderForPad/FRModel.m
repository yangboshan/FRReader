//
//  FRModel.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "FRModel.h"
#import "FRNodeModel.h"
#import "NSString+FRCategory.h"

@interface FRModel()

@property(nonatomic,strong) NSArray* docTypeFilter;
@property(nonatomic,strong) NSArray* pdfTypeFilter;

@property(nonatomic,strong) NSString* searchKey;
@property(nonatomic,strong) NSMutableArray* searchList;

@end

@implementation FRModel

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(FRModel)

-(NSArray*)docTypeFilter{
    
    if (!_docTypeFilter) {
        _docTypeFilter = @[@"doc",@"docx"];
    }
    return _docTypeFilter;
}

-(NSArray*)pdfTypeFilter{
    if (!_pdfTypeFilter) {
        _pdfTypeFilter = @[@"pdf"];
    }
    return _pdfTypeFilter;
}


-(BOOL)createFolderByPath:(NSString*)folderPath{
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    if (error) {
        return NO;
    }else{
        return YES;
    }
}

-(BOOL)deleteByPath:(NSString*)path{
    
    NSError* error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error) {
        return NO;
    }else{
        return YES;
    }
}

-(BOOL)renameByPath1:(NSString*)path1 path2:(NSString*)path2{
    
    NSError* error;
    [[NSFileManager defaultManager] moveItemAtPath:path1 toPath:path2 error:&error];
    
    if (error) {
        return NO;
    }else{
        return YES;
    }
}

-(NSMutableArray*)getFileTreeByNodeModel:(FRNodeModel*)requestNodeModel{
    
    BOOL isRootNode;
    
    //如果是从根开始请求构建一个临时Node
    if (!requestNodeModel) {
        
        isRootNode = YES;
        requestNodeModel = [[FRNodeModel alloc] initWithName:nil path:[NSString documentPath] level:0 type:0];
    }
    
    NSMutableArray* nodeList = [NSMutableArray array];
    NSArray* fileList = [self getNodeListByPath:requestNodeModel.nodePath];
    
    [fileList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BOOL isDirectory;
        
        NSInteger nodeLevel = requestNodeModel.nodeLevel; ++nodeLevel;
        kFRNodeType nodeType = kFRNodeTypeUnknown;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileList[idx] isDirectory:&isDirectory]) {
            
            if (isDirectory) {
                nodeType = kFRNodeTypeFolder;
            }
            
            if ([self.docTypeFilter containsObject:[fileList[idx] pathExtension]]) {
                nodeType = kFRNodeTypeDocFile;
            }
            
            if ([self.pdfTypeFilter containsObject:[fileList[idx] pathExtension]]) {
                nodeType = kFRNodeTypePDFFile;
            }
        }
        
        if (nodeType!=kFRNodeTypeUnknown) {
            
            FRNodeModel* nodeModel = [[FRNodeModel alloc] initWithName:[fileList[idx] lastPathComponent] path:nil level:nodeLevel type:nodeType];
            [nodeList addObject:nodeModel];
            
            //为节点的父节点赋值
            if (!isRootNode) {
                nodeModel.parent = requestNodeModel;
            }
        }
    }];
    
    //为请求节点的子节点集合赋值
    if (!isRootNode) {
        requestNodeModel.children = nodeList;
    }
    
    return nodeList;
}


-(NSArray*)getNodeListByPath:(NSString*)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    NSMutableArray* pathList = [NSMutableArray array];
    for(NSString* file in fileList){
        [pathList addObject:[path stringByAppendingPathComponent:file]];
    }
    
    return pathList;
}

//递归查找文件
-(NSArray*)searchDirectoryByFileName:(NSString*)file{
    
    self.searchKey = file;
    self.searchList = nil;
    self.searchList = [NSMutableArray array];
    
    [self searchByPath:[NSString documentPath]];
    
    return self.searchList;
}


-(void)searchByPath:(NSString*)path{
    
    NSArray* list = [self getNodeListByPath:path];
    
    for(NSString* path in list){
        
        if ([self isDirectiory:path]) {
            [self searchByPath:path];
            
        }else{
            
            if ([[path lastPathComponent] containsString:self.searchKey]) {
                [self.searchList addObject:path];
            }
        }
    }
}


-(BOOL)isDirectiory:(NSString*)path{
    
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    return isDirectory;
}
@end
