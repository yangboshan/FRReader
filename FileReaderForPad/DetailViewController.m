//
//  DetailViewController.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "DetailViewController.h"
#import "PureLayout.h"

@interface DetailViewController ()

@property(nonatomic,strong) QLPreviewController* previewController;
@end

@implementation DetailViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"浏览";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        [self configureView];
    }
}

- (void)configureView {
    
    if (self.detailItem) {
        
        if (self.previewController) {
            [self.previewController.view removeFromSuperview];
            self.previewController = nil;
        }
        
        self.previewController = [QLPreviewController new];
        self.previewController.delegate = self;
        self.previewController.dataSource = self;
        self.previewController.currentPreviewItemIndex = 0;
        [self addChildViewController:self.previewController];
        [self.view addSubview:self.previewController.view];
        [self.previewController.view autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [self.previewController.view autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [self.previewController.view autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
        [self.previewController.view autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
        [self.previewController didMoveToParentViewController:self];
 
        
    }
}

#pragma mark - QLPreviewController delegate

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx{
 
    NSInteger level = [[self.detailItem valueForKey:@"nodeLevel"] integerValue];
    if (level>=0) {
        return [NSURL fileURLWithPath:[self.detailItem valueForKey:@"nodePath"]];
    }else{
        return [NSURL fileURLWithPath:[self.detailItem valueForKey:@"nodeName"]];
    }
}

@end
