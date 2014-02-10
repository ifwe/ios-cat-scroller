//
//  CatScroller.h
//  CatScrollerExample
//
//  Created by Yong Xin Dai on 2/6/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"

@protocol CatScrollerCollectionViewCell <NSObject>

@required

/*
 * Purpose:
 * - Will call on this method to populate the cell
 * (OR)
 * - Will call this method if just want to render the height and width
 */
- (UICollectionViewCell *) render:(id) cellModel ForHeightOrWidth:(BOOL) isRenderingForHeightOrWidth;

@optional

@end


@interface CatScroller : NSObject

/*
 * The container that contains the functionality of the project
 */
@property (strong, nonatomic, readonly) UIView *containerView;

/*
 * headerView footerView will be added to the view as a header or footer
 */
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *footerView;


@property (strong, nonatomic) Class collectionViewHeaderViewClass;
@property (strong, nonatomic) Class collectionViewFooterViewClass;


/*
 * Manufactures a CatScroller
 */
+ (id) CatScrollerWithFrame:(CGRect) frame withCollectionCellClass:(Class) cellClass;

/*
 * The frame will set the containerView's size of the container frame
 */
- (id) initWithFrame:(CGRect) frame withCollectionCellClass:(Class) cellClass;

/*
 * This tells what kind of cell should the collection view uses.
 *
 * The cell need to implement CatScrollerCollectionViewCell protocol
 * When collection view require new cell. It will call on the methods in 
 * CatScrollerCollectionViewCell protocol to populate new cell
 */
- (void) updateCollectionViewCellClass:(Class) cellClass;

/*
 * will add data to the internal data array and should animate into the collection view
 */
- (void) addData:(NSArray *) data animated:(BOOL) animated;

@end
