//
//  FRModel.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "FRModel.h"
#import "FRNodeModel.h"

@interface FRModel()

@property(nonatomic,strong) NSArray* docTypeFilter;
@property(nonatomic,strong) NSArray* pdfTypeFilter;

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


+(NSString*)documentPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSLog(@"NSDocumentDirectory:%@",documentsDirectory);
    return documentsDirectory;
}

-(NSMutableArray*)getFileTreeByPath:(NSString*)path level:(NSInteger)level{
        
    NSMutableArray* nodeList = [NSMutableArray array];
    NSArray* fileList = [self getNodeListByPath:path];
    
    [fileList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BOOL isDirectory;
        
        NSInteger nodeLevel = level; ++nodeLevel;
        NSString* nodePath = [path stringByAppendingPathComponent:fileList[idx]];
        kFRNodeType nodeType = kFRNodeTypeUnknown;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:nodePath isDirectory:&isDirectory]) {
            
            if (isDirectory) {
                nodeType = kFRNodeTypeFolder;
            }
            
            if ([self.docTypeFilter containsObject:[nodePath pathExtension]]) {
                nodeType = kFRNodeTypeDocFile;
            }
            
            if ([self.pdfTypeFilter containsObject:[nodePath pathExtension]]) {
                nodeType = kFRNodeTypePDFFile;
            }
        }
        
        if (nodeType!=kFRNodeTypeUnknown) {
            
            FRNodeModel* nodeModel = [[FRNodeModel alloc] initWithName:fileList[idx] path:nodePath level:nodeLevel type:nodeType];
            [nodeList addObject:nodeModel];
        }
    }];
    
    return nodeList;
}

-(NSArray*)getNodeListByPath:(NSString*)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    return fileList;
}


@end
