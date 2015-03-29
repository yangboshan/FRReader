//
//  MasterViewController.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "FRModel.h"
#import "FRNodeModel.h"
#import "FRNodeTableViewCell.h"
#import "UIImage+FRCategory.h"
#import "FRMacro.h"
#import "FRToolbar.h"
#import "PureLayout.h"
#import "AppDelegate.h"
#import "NSString+FRCategory.h"

typedef NS_ENUM(NSInteger, kFRAlertViweTag){
    kFRAlertViweTagCreateFolder = 1000,
    kFRAlertViweTagDeleteItem,
    kFRAlertViweTagRenameItem,
};

@interface MasterViewController ()

@property NSMutableArray *objects;

@property (nonatomic,strong) UIBarButtonItem* addButton;
@property (nonatomic,strong) FRToolbar* toolbar;
@property (nonatomic,strong) FRNodeModel* renameModel;
@property (nonatomic,strong) FRNodeModel* selectedModel;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) NSIndexPath *editIndexPath;
@end

static NSString* cellId = @"cellId";

@implementation MasterViewController

#pragma mark - lifeCycle

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件目录";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createFolder:)];
    self.navigationItem.rightBarButtonItem = self.addButton;
    [self.addButton setEnabled:NO];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self initialSetup];
}

-(void)initialSetup{
    
    self.objects = [[FRModel sharedFRModel] getFileTreeByPath:[FRModel documentPath] level:0];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FRNodeTableViewCell" bundle:nil] forCellReuseIdentifier:cellId];
    
    [self.view setBackgroundColor:RGB(236, 236, 236)];

    
    UISplitViewController *splitViewController = (UISplitViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [splitViewController.view addSubview:self.toolbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods

//新建文件夹
- (void)createFolder:(id)sender {
    
    //获取当前选择的节点
    self.selectedIndexPath = [self.tableView indexPathForSelectedRow];
    FRNodeModel* selectedModel = self.objects[self.selectedIndexPath.row];
    self.selectedModel = selectedModel;
    
    //弹框让用户输入文件夹名称
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"新建"
                                                        message:[NSString stringWithFormat:@"点击确定,将在<%@>下新建目录",selectedModel.nodeName]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = kFRAlertViweTagCreateFolder;
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        switch (alertView.tag) {
                
            case kFRAlertViweTagCreateFolder:
                
                [self addFolderByName:[[alertView textFieldAtIndex:0] text]];

                break;
            case kFRAlertViweTagDeleteItem:
                
                [self delete];

                break;
                
            case kFRAlertViweTagRenameItem:
                [self renameByName:[[alertView textFieldAtIndex:0] text]];
                break;
            default:
                break;
        }
    }
}

-(void)renameByName:(NSString*)name{
    
    NSString* path1= self.renameModel.nodePath;
    NSString* path2 = [[path1 stringByDeletingLastPathComponent] stringByAppendingPathComponent:name];
    BOOL isSuccess = [[FRModel sharedFRModel] renameByPath1:path1 path2:path2];
    
    if (!isSuccess) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"重命名失败"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
        
    }else{
        
        self.renameModel.nodeName = name;
        self.renameModel.nodePath = path2;
        
        //清空所有子节点 或者可以修改所有自节点的路径
        [self.renameModel.children removeAllObjects];
        
        [self.tableView reloadData];
    }
}


-(void)delete{
    
    FRNodeModel* currentModel = self.objects[self.editIndexPath.row];
    BOOL isSuccess = [[FRModel sharedFRModel] deleteByPath:currentModel.nodePath];
    
    if (!isSuccess) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"删除失败"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    //从父节点的叶子节点集合里面移除自己
    if (currentModel.parent) {
        [currentModel.parent.children removeObject:currentModel];

    }
    
    //递归删除所有叶子节点
    [self shrinkThisRows:currentModel.children];
    
    //删掉当前节点
    NSInteger indexToRemove = [self.objects indexOfObjectIdenticalTo:currentModel];
    if (indexToRemove != NSNotFound) {
        
        [self.objects removeObjectAtIndex:indexToRemove];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToRemove inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)addFolderByName:(NSString*)name{
    
    //文件夹名称为空返回
    if ([name stringIsNilOrEmpty]) {
        return;
    }
    
    NSString* folderPath = [self.selectedModel.nodePath stringByAppendingPathComponent:name];
    NSLog(@"%@",folderPath);
    
    //新建文件夹
    BOOL isSuccess = [[FRModel sharedFRModel] createFolderByPath:folderPath];
    
    //失败了 提示
    if (!isSuccess) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"新建文件夹失败"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    
    //新建成功
    }else{
        
        //构建新的节点 并添加到列表中
        NSInteger level = self.selectedModel.nodeLevel; ++ level;
        
        FRNodeModel* nodeModel = [[FRNodeModel alloc] initWithName:name path:folderPath level:level type:kFRNodeTypeFolder];
        [self.selectedModel.children addObject:nodeModel];
        NSInteger index = self.selectedIndexPath.row + 1;
        NSArray* folderArray = @[[NSIndexPath indexPathForRow:index inSection:0]];
        [self.objects insertObject:nodeModel atIndex:index++];
        [self.tableView insertRowsAtIndexPaths:folderArray withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        id object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FRNodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 2.0;
    [cell addGestureRecognizer:longPress];
    

    FRNodeModel *nodeModel = self.objects[indexPath.row];
    cell.nodeModel = nodeModel;
    cell.nameLabel.text = nodeModel.nodeName;
    
    return cell;
}

-(void)handleLongPress:(UIGestureRecognizer*)gesture{
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        FRNodeTableViewCell* cell = (FRNodeTableViewCell*)gesture.view;
        self.renameModel = cell.nodeModel;
        NSString* tip = (cell.nodeModel.nodeType == kFRNodeTypeFolder) ? @"请输入新的文件夹名称" :@"请输入新的文件名称";
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:tip
                                                            message:[NSString stringWithFormat:@"该名称将会替代<%@>",
                                                                     cell.nodeModel.nodeName]
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        
        alertView.tag = kFRAlertViweTagRenameItem;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput ;
        [alertView show];
        
        NSLog(@"%@",cell.nodeModel.nodeName);
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //获取当前节点
    FRNodeModel* currentNode = self.objects[indexPath.row];
    
    //如果该节点是文件夹 enable 添加文件夹功能
    [self.addButton setEnabled:(currentNode.nodeType == kFRNodeTypeFolder) ? YES : NO];
    
    BOOL isExpanded;
    
    NSInteger index = indexPath.row;
    
    //如果当前节点不是文件夹 则打开文档
    if (currentNode.nodeType != kFRNodeTypeFolder) {
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    
    //当前节点为文件夹
    }else{
        
        //获取节点下的列表
        NSMutableArray* children = [[FRModel sharedFRModel] getFileTreeByPath:currentNode.nodePath level:currentNode.nodeLevel];
        
        [children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FRNodeModel* child = obj;
            child.parent = currentNode;
        }];
        
        //如果已有子节点集合则使用
        if (currentNode.children) {
            children = currentNode.children;
        }
        
        //判断是否已经展开
        if (self.objects.count-1 > indexPath.row) {
            
            FRNodeModel* nextNode = self.objects[++index];
            
            for(FRNodeModel* nodeModel in children){
                if ([nodeModel isEqual:nextNode]) {
                    isExpanded = YES;
                    break;
                }
            }
        }
        
        
        //展开
        if (!isExpanded) {
            
            index = indexPath.row + 1;
            NSMutableArray* addList = [NSMutableArray array];
            currentNode.children = children;
            
            for(FRNodeModel* nodeModel in children){
                
                [addList addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                [self.objects insertObject:nodeModel atIndex:index++];
            }
            
            [tableView insertRowsAtIndexPaths:addList withRowAnimation:UITableViewRowAnimationFade];
        
        //收起
        }else{
            
            [self shrinkThisRows:children];
        }
    }
}

//收起
-(void)shrinkThisRows:(NSArray*)list{
    
    //遍历子节点
    for(FRNodeModel *nodeModel in list ) {
    
        NSUInteger indexToRemove=[self.objects indexOfObjectIdenticalTo:nodeModel];
        NSArray* children = nodeModel.children;
        
        //递归子节点 执行收起
        if (children && children.count) {
            [self shrinkThisRows:children];
        }
        
        if (indexToRemove!=NSNotFound) {
            
            [self.objects removeObjectAtIndex:indexToRemove];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToRemove inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.editIndexPath = indexPath;
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"确定要删除吗?如果删除文件夹该文件夹下面的所有内容都会被删除"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        
        [alertView setTag:kFRAlertViweTagDeleteItem];
        [alertView show];


    } else if (editingStyle == UITableViewCellEditingStyleInsert) {}
}


-(FRToolbar*)toolbar{
    if (!_toolbar) {
        _toolbar = [[[NSBundle mainBundle] loadNibNamed:@"FRToolbar" owner:self options:nil] lastObject];
    }
    return _toolbar;
}
@end
