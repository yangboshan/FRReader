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
    
    [self.bgImageView setImage:[UIImage imageNamed:@"copymove-cell-bg.png"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
            [self.iconImageView setImage:[UIImage imageNamed:@"word_icon2"]];
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
