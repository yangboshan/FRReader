//
//  FRSearchResultViewController.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/30.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "FRSearchResultViewController.h"
#import "FRNodeTableViewCell.h"
#import "FRMacro.h"


@interface FRSearchResultViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSArray* data;

@property (nonatomic,strong) UIView* headerView;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) UIView* footerView;
@property (nonatomic,copy) UserDidSelectFile block;
@end


static NSString* cellId = @"cellId";
@implementation FRSearchResultViewController

#pragma mark - lifeCycle

-(instancetype)initWithData:(NSArray*)data block:(UserDidSelectFile)block{
    if (self = [super init]) {
        _data = data;
        self.block = block;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tableView delegate & datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* path = self.data[indexPath.row];
    NSRange range = [path rangeOfString:@"Documents"];
    NSString* subPath = [path substringFromIndex:range.location + range.length];
    NSString* showName = [NSString stringWithFormat:@"%@",subPath];

    FRNodeModel* nodeModel = [[FRNodeModel alloc] initWithName:showName
                                                          path:path
                                                         level:1
                                                          type:kFRNodeTypeDocument];
    
    FRNodeTableViewCell* cell =  [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.nodeModel = nodeModel;
    cell.nameLabel.text = nodeModel.nodeName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* path = self.data[indexPath.row];
    self.block(path);
}

#pragma mark - getter

-(UIView*)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 200, 30)];
        [label setText:@"为您检索到下列结果"];
        [label setFont:Lantinghei(18)];
        [label setTextColor:[UIColor darkGrayColor]];
        
        [_headerView addSubview:label];
    }
    return _headerView;
}

-(UIView*)footerView{
    if (!_footerView) {
        
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(170, 100, 200, 30)];
        [button setTitle:@"返回" forState:UIControlStateNormal];
        [button.titleLabel setFont:Lantinghei(20)];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = BorderColor;
        button.layer.cornerRadius = 5.0;
        [_footerView addSubview:button];
    }
    return _footerView;
}

-(UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setTableHeaderView:self.headerView];
        [_tableView setTableFooterView:self.footerView];
        [_tableView registerNib:[UINib nibWithNibName:@"FRNodeTableViewCell" bundle:nil] forCellReuseIdentifier:cellId];
    }
    return _tableView;
}

#pragma mark - 

-(void)back:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
