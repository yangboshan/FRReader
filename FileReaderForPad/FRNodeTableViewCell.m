//
//  FRNodeTableViewCell.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "FRNodeTableViewCell.h"
#import "PureLayout.h"
#import "FRMacro.h"


@implementation FRNodeTableViewCell

- (void)awakeFromNib {
    [self.contentView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [self.contentView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.contentView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.contentView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
 }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setNodeModel:(FRNodeModel *)nodeModel{
    _nodeModel = nodeModel;
    
    self.leadingSpace.constant = 20 * (nodeModel.nodeLevel - 1);
    
    switch (nodeModel.nodeType) {
        case kFRNodeTypeFolder:
            [self.nameLabel setFont:Lantinghei(17)];
            [self.nameLabel setTextColor:[UIColor darkGrayColor]];
            [self.iconImageView setImage:[UIImage imageNamed:@"folder_icon"]];
            break;
        case kFRNodeTypeDocFile:
            [self.nameLabel setFont:Lantinghei(15)];
            [self.nameLabel setTextColor:[UIColor grayColor]];
            [self.iconImageView setImage:[UIImage imageNamed:@"word_icon1"]];
            break;
            
        case kFRNodeTypePDFFile:
            [self.nameLabel setFont:Lantinghei(15)];
            [self.nameLabel setTextColor:[UIColor grayColor]];
            [self.iconImageView setImage:[UIImage imageNamed:@"pdf_icon"]];
            break;
        default:
            break;
    }
}

@end
