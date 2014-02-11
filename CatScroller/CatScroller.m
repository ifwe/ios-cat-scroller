//
//  CatScroller.m
//  CatScrollerExample
//
//  Created by Yong Xin Dai on 2/6/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "CatScroller.h"
#import "CatScrollerDefaultHeaderView.h"
#import "CatScrollerDefaultFooterView.h"



#define HEADER_IDENTIFIER (@"WaterfallHeader")
#define FOOTER_IDENTIFIER (@"WaterfallFooter")

#define DEFAULT_SECTION_INSET (UIEdgeInsetsMake(9, 9, 9, 9))
#define DEFAULT_ITEM_VERTICAL_HEIGHT (5.0f)


@implementation NSObject (CatScroller)


- (UIEdgeInsets) CatScrollerSectionInset{
    return DEFAULT_SECTION_INSET;
}


- (CGFloat) CatScrollerVerticalItemSpacing{
    return DEFAULT_ITEM_VERTICAL_HEIGHT;
}

@end



@interface CatScroller ()<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>
/*
 * The frame of container
 */
@property (nonatomic) CGRect containerFrame;

/*
 * The collection view that display the data
 */
@property (strong, nonatomic) UICollectionView *collectionView;

/*
 * The view that contain the the header view or footer view
 */
@property (strong, nonatomic, readonly) UIView *headerViewContainer;
@property (strong, nonatomic, readonly) UIView *footerViewContainer;

/*
 * The data, user supplies for the table's contain
 */
@property (strong, nonatomic) NSMutableArray *internalData;

/*
 * The cell will be use by the collection view
 */
@property (strong) Class collectionViewCellClass;


/*
 * Collection view's section header and footer class
 */
@property (strong, nonatomic) Class collectionViewHeaderViewClass;
@property (strong, nonatomic) Class collectionViewFooterViewClass;


@end


@implementation CatScroller
@synthesize containerView = _containerView;
@synthesize headerViewContainer = _headerViewContainer;
@synthesize footerViewContainer = _footerViewContainer;
@synthesize collectionViewHeaderViewClass = _collectionViewHeaderViewClass;
@synthesize collectionViewFooterViewClass = _collectionViewFooterViewClass;

#pragma mark - init functions

+ (id) CatScrollerWithFrame:(CGRect) frame withCollectionCellClass:(Class) cellClass withDelegate:(id<CatScrollerCollectionViewDelegate>)delegate
{
    return [[[self class] alloc] initWithFrame:frame withCollectionCellClass:cellClass withDelegate:delegate];
}


- (id) initWithFrame:(CGRect) frame withCollectionCellClass:(Class) cellClass withDelegate:(id<CatScrollerCollectionViewDelegate>)delegate
{
    if (self = [super init]) {
        _containerFrame = frame;
        _viewDelegate = delegate;
        
        _currentDataRequestState = CSDataRequestingStateWaitingForAddingData;
        _currentDataUpdatePloicy = CSDataRequestingPolicyOnDisplayingNewItem;
        
        [self updateCollectionViewCellClass:cellClass];
        
        [self.containerView addSubview:self.collectionView];
        
        
        [self.containerView addSubview:self.headerViewContainer];
        [self.containerView addSubview:self.footerViewContainer];
        
        [self setupLayoutConstraint];
        
    }
    return self;
}




#pragma mark - getter & setter

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        
        layout.sectionInset = [self.viewDelegate CatScrollerSectionInset];
        layout.verticalItemSpacing = [self.viewDelegate CatScrollerVerticalItemSpacing];
        layout.itemWidth = [self.viewDelegate CatScrollerItemsWidth];
        
        
        
        CGRect collectionFrame = self.containerView.frame;
        // shift by header view stuff
        collectionFrame.origin.y = self.headerViewContainer.frame.size.height;
        collectionFrame.size.height -= self.headerViewContainer.frame.size.height;
        
        // shift by footer view stuff
        collectionFrame.size.height -= self.footerViewContainer.frame.size.height;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        
        [_collectionView registerClass:self.collectionViewCellClass
                forCellWithReuseIdentifier:NSStringFromClass(self.collectionViewCellClass)];
        
        [_collectionView registerClass:[CatScrollerDefaultHeaderView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:HEADER_IDENTIFIER];
        
        [_collectionView registerClass:[CatScrollerDefaultHeaderView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter withReuseIdentifier:FOOTER_IDENTIFIER];
        
        _collectionView.backgroundColor = [UIColor lightGrayColor];
    }
    return _collectionView;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.containerFrame];
    }
    return _containerView;
}

- (UIView *)headerViewContainer
{
    if (!_headerViewContainer) {
        CGRect headerframe = self.containerView.frame;
        headerframe.size.height = 10.0f;
        
        _headerViewContainer = [[UIView alloc] initWithFrame:headerframe];
        
        _headerViewContainer.backgroundColor = [UIColor yellowColor];
    }
    return _headerViewContainer;
}

- (UIView *)footerViewContainer
{
    if (!_footerViewContainer) {
        
        CGRect footerViewFrame = self.containerView.frame;
        footerViewFrame.origin.y = footerViewFrame.size.height - 10.0f;
        footerViewFrame.size.height = 10.0f;
        
        _footerViewContainer = [[UIView alloc] initWithFrame:footerViewFrame];
        
        _footerViewContainer.backgroundColor = [UIColor yellowColor];
        
    }
    return _footerViewContainer;
}

- (NSMutableArray *)internalData
{
    if (!_internalData) {
        _internalData = [[NSMutableArray alloc] init];
    }
    return _internalData;
}


- (Class)collectionViewHeaderViewClass
{
    if (!_collectionViewHeaderViewClass) {
        _collectionViewHeaderViewClass = [CatScrollerDefaultHeaderView class];
    }
    return _collectionViewHeaderViewClass;
}

- (void) setCollectionViewHeaderViewClass:(Class)collectionHeaderViewClass
{
    _collectionViewHeaderViewClass = collectionHeaderViewClass;
    [self.collectionView registerClass:_collectionViewHeaderViewClass forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:HEADER_IDENTIFIER];
}

- (Class) collectionViewFooterViewClass
{
    if (!_collectionViewFooterViewClass) {
        _collectionViewFooterViewClass = [CatScrollerDefaultFooterView class];
    }
    return _collectionViewFooterViewClass;
}


- (void) setCollectionViewFooterViewClass:(Class)collectionViewFooterViewClass
{
    _collectionViewFooterViewClass = collectionViewFooterViewClass;
    [self.collectionView registerClass:_collectionViewFooterViewClass forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter withReuseIdentifier:FOOTER_IDENTIFIER];
}



- (void)setRefreshControl:(UIRefreshControl *)refreshControl
{
    [_refreshControl removeFromSuperview];
    _refreshControl = refreshControl;
    if (_refreshControl) {
        [self.collectionView addSubview:_refreshControl];
    }
}


#pragma mark - view functions

- (void)updateCollectionViewCellClass:(Class)cellClass
{
    assert([cellClass conformsToProtocol:@protocol(CatScrollerCollectionViewCell)]);
    self.collectionViewCellClass = cellClass;
    
}

- (void) pushBackData:(NSArray *) data completion:(void (^)(BOOL finished))completion
{
    // return to normal state only if it's in CSDataRequestingStateWaitingForAddingData
    if (self.currentDataRequestState == CSDataRequestingStateWaitingForAddingData)
    {
        self.currentDataRequestState = CSDataRequestingStateNormal;
    }
    
    NSMutableArray * indices = [[NSMutableArray alloc] init];
    
    NSUInteger startValue = self.internalData.count;
    NSUInteger endingValue = startValue + data.count;
    
    for (NSUInteger i = startValue; i < endingValue; i++) {
        [indices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.internalData addObjectsFromArray:data];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:indices];
    } completion:^(BOOL finished) {
        if (self.currentDataUpdatePloicy != CSDataRequestingPolicyOnDisplayingNewItem) {
            [self notifyDelegateIfReachedCriticalRange:[self findLargestIndexFromVisibleCells] updateFromPolicy:CSDataRequestingPolicyAlways];
        }
        if (completion) completion(finished);
    }];
}

- (NSUInteger)findLargestIndexFromVisibleCells {
    __block NSUInteger largestIndex = 0;
    
    [self.collectionView.indexPathsForVisibleItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        largestIndex = MAX(obj.row, largestIndex);
    }];
    return largestIndex;
}

- (void) setupLayoutConstraint
{
    self.headerViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.footerViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void) notifyDelegateIfReachedCriticalRange:(NSUInteger) largestIndex updateFromPolicy: (CSDataRequestingPolicy) policy
{
    if ((self.internalData.count - largestIndex) >= [self.dataSrouce CatScrollerCriticalRangeItemCount]) {
        return;
    }
    if (self.currentDataUpdatePloicy == policy && self.currentDataRequestState == CSDataRequestingStateNormal) {
        self.currentDataRequestState = CSDataRequestingStateWaitingForAddingData;
        
        [self.dataSrouce CatScrollerDidEnterCriticalRange];
        
    }else if (policy == CSDataRequestingPolicyAlways) {
        [self.dataSrouce CatScrollerDidEnterCriticalRange];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.internalData.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell<CatScrollerCollectionViewCell> *aCell =
    [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(self.collectionViewCellClass)
                                                   forIndexPath:indexPath];
    [self notifyDelegateIfReachedCriticalRange:indexPath.row updateFromPolicy:CSDataRequestingPolicyOnDisplayingNewItem];
    
    return [aCell render:self.internalData[indexPath.row] ForHeightOrWidth:NO];
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:HEADER_IDENTIFIER
                                                         forIndexPath:indexPath];
    } else if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:FOOTER_IDENTIFIER
                                                         forIndexPath:indexPath];
    }
    return reusableView;
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self notifyDelegateIfReachedCriticalRange:[self findLargestIndexFromVisibleCells] updateFromPolicy:CSDataRequestingPolicyOnViewWillBeginScroll];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self notifyDelegateIfReachedCriticalRange:[self findLargestIndexFromVisibleCells] updateFromPolicy:CSDataRequestingPolicyOnViewEndScroll];
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout


- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell<CatScrollerCollectionViewCell> *aCell = [[self.collectionViewCellClass alloc] init];
    [aCell render:self.internalData[indexPath.row] ForHeightOrWidth:YES];
    return aCell.frame.size.height;
}


@end
