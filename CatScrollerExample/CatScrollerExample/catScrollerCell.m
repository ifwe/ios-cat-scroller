//
//  catScrollerCell.m
//  CatScrollerExample
//
//  Created by Yong Xin Dai on 2/6/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "CatScrollerCell.h"

@implementation CatScrollerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (void)layoutSubviews
{
}

- (UICollectionViewCell *)render:(id)cellModel ForHeightOrWidth:(BOOL)isRenderingForHeightOrWidth
{
    NSDictionary *dict = ([cellModel isKindOfClass:[NSDictionary class]])?cellModel:nil;
    
    NSUInteger cellHeight = [dict[CELL_HEIGHT_NAME] integerValue];
    
    self.bounds = CGRectMake(0, 0, 135.0, cellHeight);
    
    CGRect contentFrame = self.contentView.frame;
    contentFrame.origin.x = 3.0f;
    contentFrame.origin.y = 3.0f;
    contentFrame.size.width = 135.0 - 3.0f * 2.0f;
    contentFrame.size.height = cellHeight - 2.0f * 3.0f;
    
    self.contentView.frame = contentFrame;
    self.contentView.backgroundColor = [UIColor blueColor];
//    self.contentView.center = self.center;
    
    if (!self.backgroundColor){
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [UIColor brownColor];
    }
    
    if (!self.selectedBackgroundView) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
}


- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
}

@end
