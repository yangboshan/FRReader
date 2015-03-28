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


@interface MasterViewController ()

@property NSMutableArray *objects;
@property (nonatomic,strong) UIBarButtonItem* addButton;

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

    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
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
    [self.view setBackgroundColor:RGB(236, 236, 236)];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRNodeTableViewCell" bundle:nil] forCellReuseIdentifier:cellId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods


- (void)insertNewObject:(id)sender {
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    FRNodeModel* selectedModel = self.objects[selectedIndexPath.row];

    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"新建" message:[NSString stringWithFormat:@"点击确定,将在<%@>下新建目录",selectedModel.nodeName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self addFolderAtPath:[[alertView textFieldAtIndex:0] text]];
            break;
        default:
            break;
    }
}

-(void)addFolderAtPath:(NSString*)path{
    NSLog(@"%@",path);
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

    FRNodeModel *nodeModel = self.objects[indexPath.row];
    cell.nodeModel = nodeModel;
    cell.nameLabel.text = nodeModel.nodeName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    FRNodeTableViewCell* cell = (FRNodeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//    FRNodeModel* currentNode = cell.nodeModel;
    
    FRNodeModel* currentNode = self.objects[indexPath.row];
    
    if (currentNode.nodeType == kFRNodeTypeFolder) {
        [self.addButton setEnabled:YES];
    }else{
        [self.addButton setEnabled:NO];
    }
    
    BOOL isExpanded;
    
    NSInteger index = indexPath.row;
    if (currentNode.nodeType != kFRNodeTypeFolder) {
        
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
        
    }else{
        
        NSArray* children = [[FRModel sharedFRModel] getFileTreeByPath:currentNode.nodePath level:currentNode.nodeLevel];
        
        if (currentNode.children) {
            children = currentNode.children;
        }
        
        if (self.objects.count-1 > indexPath.row) {
            
            FRNodeModel* nextNode = self.objects[++index];
            
            for(FRNodeModel* nodeModel in children){
                if ([nodeModel isEqual:nextNode]) {
                    isExpanded = YES;
                    break;
                }
            }
        }
        
        if (!isExpanded) {
            
            index = indexPath.row + 1;
            NSMutableArray* addList = [NSMutableArray array];
            currentNode.children = children;
            
            for(FRNodeModel* nodeModel in children){
                [addList addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                [self.objects insertObject:nodeModel atIndex:index++];
            }
            [tableView insertRowsAtIndexPaths:addList withRowAnimation:UITableViewRowAnimationFade];
            
        }else{
            
            [self shrinkThisRows:children];
        }
    }
}

-(void)shrinkThisRows:(NSArray*)list{
    
    for(FRNodeModel *nodeModel in list ) {
        
        NSUInteger indexToRemove=[self indexOfNode:nodeModel];
        NSArray* children = nodeModel.children;
        
        if (children && children.count) {
            [self shrinkThisRows:children];
        }
        
        NSInteger index = [self indexOfNode:nodeModel];
        if (index!=NSNotFound) {
            
            [self.objects removeObjectAtIndex:index];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToRemove inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(NSInteger)indexOfNode:(FRNodeModel*)node{
    
    for(int i = 0; i < self.objects.count; i++){
        FRNodeModel* nodeModel = self.objects[i];
        if ([nodeModel isEqual:node]) {
            return i;
        }
    }
    
    return NSNotFound;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

@end
