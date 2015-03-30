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
#import "FRScanViewController.h"

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
@property (nonatomic,strong) FRNodeModel* searchResultModel;
@property (nonatomic,assign) BOOL fromTableView;

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
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleBordered target:self action:@selector(editAction:)];
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createFolder:)];
    [self.addButton setEnabled:YES];
    
    self.navigationItem.leftBarButtonItem = editButton;
    self.navigationItem.rightBarButtonItem = self.addButton;
    ;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self initialSetup];
}

-(void)editAction:(UIBarButtonItem*)editButton{
    
    if ([editButton.title isEqualToString:@"编辑"]) {
        [editButton setTitle:@"完成"];
        [editButton setStyle:UIBarButtonItemStyleDone];
        [self.tableView setEditing:YES animated:YES];
    }else{
        [editButton setTitle:@"编辑"];
        [editButton setStyle:UIBarButtonItemStylePlain];
        [self.tableView setEditing:NO animated:YES];
    }
}

-(void)initialSetup{
    
    self.objects = [[FRModel sharedFRModel] getFileTreeByNodeModel:nil];
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


#pragma mark - alertView delegate

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
    }else{
        
        if (alertView.tag == kFRAlertViweTagDeleteItem) {
            [self.tableView setEditing:NO animated:YES];
        }
    }
}



#pragma mark - 新建文件夹
- (void)createFolder:(id)sender {
    
    //获取当前选择的节点
    self.selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (self.selectedIndexPath) {
        self.selectedModel = self.objects[self.selectedIndexPath.row];
        
    //根节点
    }else{
        self.selectedModel = [[FRNodeModel alloc] initWithName:@"根目录"
                                                          path:[NSString documentPath]
                                                         level:0
                                                          type:kFRNodeTypeFolder];
    }
    

    
    //弹框让用户输入文件夹名称
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"新建"
                                                        message:[NSString stringWithFormat:@"点击确定,将在<%@>下新建文件夹",self.selectedModel.nodeName]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = kFRAlertViweTagCreateFolder;
    [alertView show];
    
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
        
        FRNodeModel* nodeModel = [[FRNodeModel alloc] initWithName:name
                                                              path:nil
                                                             level:level
                                                              type:kFRNodeTypeFolder];
        [self.selectedModel.children addObject:nodeModel];
        nodeModel.parent = self.selectedModel;
        
        NSInteger index;
        if(self.selectedIndexPath){
            index = self.selectedIndexPath.row + 1;
        }else{
            index = self.objects.count;
        }
        
        NSArray* folderArray = @[[NSIndexPath indexPathForRow:index inSection:0]];
        [self.objects insertObject:nodeModel atIndex:index++];
        [self.tableView insertRowsAtIndexPaths:folderArray withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - 重命名
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
        [self.tableView reloadData];
    }
}

#pragma mark - 删除
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



#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        FRNodeModel* object;
        
        if (self.fromTableView) {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            object = self.objects[indexPath.row];
            
            NSLog(@"%@",object.nodePath);
        }else{
            object = self.searchResultModel;
        }

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
    longPress.minimumPressDuration = 1.0;
    [cell addGestureRecognizer:longPress];
    

    FRNodeModel *nodeModel = self.objects[indexPath.row];
    cell.nodeModel = nodeModel;
    cell.nameLabel.text = nodeModel.nodeName;
    
    return cell;
}

//处理长按
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
 
    FRNodeModel* currentNode = self.objects[indexPath.row];
    [self.addButton setEnabled:(currentNode.nodeType > kFRNodeTypeFolder) ? NO : YES];
    
    BOOL isAlreadyExpanded;
    
    NSInteger index = indexPath.row;
    
    //如果当前节点不是文件夹 则打开文档
    if (currentNode.nodeType != kFRNodeTypeFolder) {
        self.fromTableView = YES;
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    
    //当前节点为文件夹
    }else{
        
        //获取节点下的列表
        NSMutableArray* children = currentNode.children ? currentNode.children : [[FRModel sharedFRModel] getFileTreeByNodeModel:currentNode];
        
        
        //判断是否已经展开
        if (self.objects.count-1 > indexPath.row) {
            
            FRNodeModel* nextNode = self.objects[++index];
            
            for(FRNodeModel* nodeModel in children){
                if ([nodeModel isEqual:nextNode]) {
                    isAlreadyExpanded = YES;
                    break;
                }
            }
        }
        
        //展开
        if (!isAlreadyExpanded) {
            
            index = indexPath.row + 1;
            NSMutableArray* addList = [NSMutableArray array];
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
                                                            message:@"确定要删除吗?"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        
        [alertView setTag:kFRAlertViweTagDeleteItem];
        [alertView show];


    } else if (editingStyle == UITableViewCellEditingStyleInsert) {}
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  @"删除";
}


-(FRToolbar*)toolbar{
    if (!_toolbar) {
        _toolbar = [[[NSBundle mainBundle] loadNibNamed:@"FRToolbar" owner:self options:nil] lastObject];
        [_toolbar.scanBtn addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolbar;
}

-(void)showCamera{
    
    FRScanViewController *scan = [[FRScanViewController alloc] initWithFinishBlock:^(NSString *file,kFRScanResultFlag flag) {
        
        if (flag == kFRScanResultFlagNone) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"没有检索到<%@>相关的文档",file] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
            [alertView show];
            
        }else{
            
            self.fromTableView = NO;
            self.searchResultModel = [[FRNodeModel alloc] initWithName:file path:file level:-1 type:0];
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
            [self performSegueWithIdentifier:@"showDetail" sender:nil];
        }
    }];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:scan];
    nav.view.autoresizingMask = UIViewAutoresizingNone;
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
    nav.view.frame = CGRectMake(0, 0, 600, 600);
    nav.view.center = self.view.center;
}

@end
