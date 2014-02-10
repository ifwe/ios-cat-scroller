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
        // Initialization code
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}


- (void)layoutSubviews
{
}

- (UICollectionViewCell *)render:(id)cellModel ForHeightOrWidth:(BOOL)isRenderingForHeightOrWidth
{
//    NSDictionary *dict = ([cellModel isKindOfClass:[NSDictionary class]])?cellModel:nil;
    
    self.bounds = CGRectMake(0, 0, 10, 150);
    return self;
}

@end