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

// This ui collection view cell need to conforms to this protocol
@protocol CatScrollerCollectionViewCell <NSObject>

@required

/*
 * Purpose:
 * - Will call on this method to populate the cell
 * (OR)
 * - Will call this method if just want to render the height and width
 */
- (UICollectionViewCell *)render:(id)cellModel;

/*
 * Queries the cell for its height.
 */
+ (CGFloat)heightForData:(id)cellModel;

@optional

/*
 * Called when setting the selected state
 */
- (void)setSelected:(BOOL)selected;

/*
 * Called when setting highlighted state
 */
- (void)setHighlighted:(BOOL)highlighted;

@end



@protocol CatScrollerCollectionViewDelegate <UICollectionViewDelegate>

@required

/*
 * Sets items' width. All item can have the same width
 */
- (CGFloat)catScrollerItemsWidth;

@optional

/*
 * Sets section's inset
 */
- (UIEdgeInsets)catScrollerSectionInset;

/*
 * Sets item's vertical spacing
 */
- (CGFloat)catScrollerVerticalItemSpacing;


@end



@protocol CatScrollerCollectionViewDataSource <NSObject>

@required

/*
 * Will be called When collection view is scrolled into the critical range
 */
- (void)catScrollerDidEnterCriticalRange;

/*
 * The Critical number of item left in the collection view
 */
- (NSUInteger)catScrollerCriticalRangeItemCount;

@end



/*
 * Time will the collection view ask for more data after entered the critical range
 */
typedef NS_OPTIONS(NSUInteger, CSDataRequestingPolicy) {// When in Critical Range:
    CSDataRequestingPolicyOnViewWillBeginScroll,        // Notify delegate when a scroll begins
    CSDataRequestingPolicyOnViewEndScroll,              // Notify delegate when a scroll ends
    CSDataRequestingPolicyOnDisplayingNewItem,          // Notify delegate while render last item
    CSDataRequestingPolicyAlways                        // Notify delegate without being blocked by states
};

/*
 * The kind of state current last data request is
 */
typedef NS_OPTIONS(NSUInteger, CSDataRequestingState) { // When in Critical Range:
    CSDataRequestingStateNormal,                        // Notify delegate and wait for data to be added
    CSDataRequestingStateWaitingForAddingData,          // Suppress any notification to the delegate until the data is added
    CSDataRequestingStateNoMoreData                     // Suppress any notification to the delegate
};

/*
 * View type of view will be show when call on setVisableAdditionalViewForType:
 */
typedef NS_OPTIONS(NSUInteger, CSAdditionalViewType) {
    CSAdditionalViewTypeNone,                           // Disable any visable additional view
    CSAdditionalViewTypeBackground,                     // Toggle the background view visibility
    CSAdditionalViewTypeBackgroundOn,                   // Set visible the background view
    CSAdditionalViewTypeBackgroundOff,                  // Hide the background view
    CSAdditionalViewTypeOverhead,                       // toggle the overhead view visibility
    CSAdditionalViewTypeOverheadOn,                     // Set visible the overhead view
    CSAdditionalViewTypeOverheadOff,                    // Hide the overhead view
};



@interface CatScroller : NSObject

/*
 * The container that contains the functionality of the object
 */
@property (nonatomic, strong, readonly) UIView *containerView;

/*
 * updates the collection view's column count
 */
@property (nonatomic) NSUInteger columnCount;

/*
 * array of all indices in internal data
 */
@property (nonatomic, strong, readonly) NSArray *indicesOfAllInternalData;

/*
 * The data, user supplies for the table's contain
 */
@property (strong, readonly) NSArray *data;

/*
 * headerView footerView will be added to the view as a header or footer
 */
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *footerView;

/*
 * overheadView will be added in front of the collection view and centered
 */
@property (strong, nonatomic) UIView *overheadView;

/*
 * backgroundView will be added behind of the collection view and centered
 */
@property (strong, nonatomic) UIView *backgroundView;

/*
 * will appear after all the ui collection view cell
 */
@property (strong, nonatomic) UIView *endOfDataFooter;

/*
 * Collection view refresh control
 * To disable refresh control: just set it to nil
 */
@property (strong, nonatomic) UIRefreshControl * refreshControl;

/*
 * enable multiple selection on ui collection view
 */
@property (nonatomic) BOOL allowsMultipleSelection;


/*
 * Current data update policy
 * Default: CSDataRequestingPolicyOnDisplayingNewItem
 */
@property (nonatomic) CSDataRequestingPolicy currentDataUpdatePloicy;

/*
 * Current data request state
 * Default: CSDataRequestingStateWaitingForAddingData
 */
@property (nonatomic) CSDataRequestingState currentDataRequestState;

/*
 * set the overall animation speed of header and footer speed
 */
@property (nonatomic) CGFloat headerFooterAnimationSpeed;

/*
 * set the over all animation speed of overhead and background animation speed
 */
@property (nonatomic) CGFloat additionalViewAnimationSpeed;

/*
 * View Delegate
 */
@property (weak, nonatomic) id<CatScrollerCollectionViewDelegate> viewDelegate;

/*
 * Data Source
 */
@property (weak, nonatomic) id<CatScrollerCollectionViewDataSource> dataSrouce;



/*
 * Manufactures a CatScroller
 */
+ (id)catScrollerWithFrame:(CGRect)frame withCollectionCellClass:(Class)cellClass withDelegate:(id<CatScrollerCollectionViewDelegate>) delegate;

/*
 * The frame will set the containerView's size of the container frame
 */
- (id)initWithFrame:(CGRect)frame withCollectionCellClass:(Class)cellClass withDelegate:(id<CatScrollerCollectionViewDelegate>) delegate;

/*
 * This tells what kind of cell should the collection view uses.
 *
 * The cell need to implement CatScrollerCollectionViewCell protocol
 * When collection view require new cell. It will call on the methods in 
 * CatScrollerCollectionViewCell protocol to populate new cell
 */
- (void)updateCollectionViewCellClass:(Class)cellClass;


/*
 * For seting header and footer of the Content view with animation
 *
 * For Non-animated setting please call setHeaderView: or setFooterView:
 */
- (void)setHeaderView:(UIView *)headerView withCompletionBlock:(void (^)(BOOL finished))completion;

- (void)setFooterView:(UIView *)footerView withCompletionBlock:(void (^)(BOOL finished))completion;

/*
 * set additional view's visibility
 */
- (void)setVisableAdditionalViewForType:(CSAdditionalViewType) viewType;


/*
 * set additional view's visibility with animation
 */
- (void)setVisableAdditionalViewForType:(CSAdditionalViewType)viewType withCompletionBlock:(void (^)(BOOL finished))completion;
/*
 *  reload indices at location
 */
- (void)reloadDataAtIndices:(NSArray *)arrayOfIndexPath completion:(void (^)(BOOL finished))completion;

/*
 * will add data to the internal data array and a completion block
 */
- (void)pushBackData:(NSArray *)data completion:(void (^)(BOOL finished))completion;

/*
 * Will remove data from the internal data array and a completion block
 */
- (void)removeCellWithArrayOfIndices:(NSArray *)arrayOfIndexPath completion:(void (^)(BOOL finished))completion;

/*
 * Will remove all data from the internal data array and a completion block
 */
- (void)clearAllDataWithcompletion:(void (^)(BOOL finished))completion;

/*
 * get array of selected index paths
 */
- (NSArray *)indexPathsForSelectedItems; // returns nil or an array of selected index paths

@end
