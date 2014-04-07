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
#import <objc/runtime.h>

#define HEADER_IDENTIFIER (@"WaterfallHeader")
#define FOOTER_IDENTIFIER (@"WaterfallFooter")

#define DEFAULT_SECTION_INSET (UIEdgeInsetsMake(9, 9, 9, 9))
#define DEFAULT_ITEM_VERTICAL_HEIGHT (5.0f)

#define DEFAULT_HEADER_FOOTER_ANIMATION_SPEED (0.1f)
#define DEFAULT_OVERHEAD_BACKGROUND_ANIMATION_SPEED (0.1f)

@implementation NSObject (CatScroller)

- (UIEdgeInsets)catScrollerSectionInset {
    return DEFAULT_SECTION_INSET;
}

- (CGFloat)catScrollerVerticalItemSpacing {
    return DEFAULT_ITEM_VERTICAL_HEIGHT;
}

// Forwarding defaults
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{}

@end


@interface CatScroller() <UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>
/*
 * The container that contains the functionality of the object
 */
@property (strong, nonatomic) UIView *containerView;
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
@property (strong, nonatomic) UIView *headerViewContainer;
@property (strong, nonatomic) UIView *footerViewContainer;

/*
 * View container that's in front of the UICollectionView
 */
@property (strong, nonatomic) UIView * overheadViewContainer;

/*
 * View container that's behind the UICollectionView
 */
@property (strong, nonatomic) UIView * backgroundViewContainer;

/*
 * The data, user supplies for the table's contain
 */
@property (strong, nonatomic) NSMutableArray *internalData;

/*
 * The cell will be use by the collection view
 */
@property (strong, nonatomic) Class collectionViewCellClass;

/*
 * Collection view's section header and footer class
 */
@property (strong, nonatomic) Class collectionViewHeaderViewClass;
@property (strong, nonatomic) Class collectionViewFooterViewClass;
@property (weak, nonatomic) UICollectionReusableView *endOfDataFooterContainer;

@end


@implementation CatScroller

#pragma mark - init functions
+ (id)catScrollerWithFrame:(CGRect)frame withCollectionCellClass:(Class)cellClass withDelegate:(id<CatScrollerCollectionViewDelegate>)delegate {
    return [[[self class] alloc] initWithFrame:frame withCollectionCellClass:cellClass withDelegate:delegate];
}

- (id)initWithFrame:(CGRect) frame withCollectionCellClass:(Class)cellClass withDelegate:(id<CatScrollerCollectionViewDelegate>)delegate {
    if (self = [super init]) {
        self.containerFrame = frame;
        self.viewDelegate = delegate;
        
        [self valueInit];
        
        [self updateCollectionViewCellClass:cellClass];
        self.collectionViewHeaderViewClass = [CatScrollerDefaultHeaderView class];
        self.collectionViewFooterViewClass = [CatScrollerDefaultFooterView class];
        
        [self.containerView addSubview:self.backgroundViewContainer];
        [self.containerView addSubview:self.collectionView];
        [self.containerView addSubview:self.overheadViewContainer];
        [self.containerView addSubview:self.headerViewContainer];
        [self.containerView addSubview:self.footerViewContainer];
        
        [self setupLayout];
    }
    return self;
}


- (void)valueInit {
    self.currentDataRequestState = CSDataRequestingStateWaitingForAddingData;
    self.currentDataUpdatePloicy = CSDataRequestingPolicyOnDisplayingNewItem;
    self.headerFooterAnimationSpeed = DEFAULT_HEADER_FOOTER_ANIMATION_SPEED;
    self.additionalViewAnimationSpeed = DEFAULT_OVERHEAD_BACKGROUND_ANIMATION_SPEED;
}


#pragma mark - getter & setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        
        layout.sectionInset = [self.viewDelegate catScrollerSectionInset];
        layout.verticalItemSpacing = [self.viewDelegate catScrollerVerticalItemSpacing];
        layout.itemWidth = [self.viewDelegate catScrollerItemsWidth];
        layout.footerHeight = 0.0f;
        
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
        
        [_collectionView registerClass:[CatScrollerDefaultFooterView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter withReuseIdentifier:FOOTER_IDENTIFIER];
        
        _collectionView.clipsToBounds = NO;
        _collectionView.alwaysBounceVertical = YES;
        
        // added Key value observing
        [_collectionView addObserver:_collectionView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        
        
        
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.containerFrame];
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

- (UIView *)headerViewContainer {
    if (!_headerViewContainer) {
        
        CGRect headerframe = self.containerView.bounds;
        headerframe.size.height = 0.0f;
        
        _headerViewContainer = [[UIView alloc] initWithFrame:headerframe];
        
        _headerViewContainer.clipsToBounds = YES;
        
        _headerViewContainer.backgroundColor = [UIColor clearColor];
    }
    return _headerViewContainer;
}

- (UIView *)footerViewContainer {
    if (!_footerViewContainer) {
        
        CGRect footerViewFrame = self.containerView.bounds;
        footerViewFrame.origin.y = footerViewFrame.size.height;
        footerViewFrame.size.height = 0.0f;
        
        _footerViewContainer = [[UIView alloc] initWithFrame:footerViewFrame];
        
        _footerViewContainer.clipsToBounds = YES;
        
        _footerViewContainer.backgroundColor = [UIColor clearColor];
        
    }
    return _footerViewContainer;
}

- (NSMutableArray *)internalData {
    if (!_internalData) {
        _internalData = [[NSMutableArray alloc] init];
    }
    return _internalData;
}

- (NSArray *)indicesOfAllInternalData{
    NSMutableArray *arrayOfIndices = [[NSMutableArray alloc] init];
    NSUInteger indexSize = self.internalData.count;
    while (indexSize != 0) {
        indexSize --;
        [arrayOfIndices addObject:[NSIndexPath indexPathForRow:indexSize inSection:0]];
    }
    return arrayOfIndices;
}

- (NSArray *)data {
    return self.internalData;
}

- (void)setCollectionViewHeaderViewClass:(Class)collectionHeaderViewClass {
    _collectionViewHeaderViewClass = collectionHeaderViewClass;
    [self.collectionView registerClass:_collectionViewHeaderViewClass forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:HEADER_IDENTIFIER];
}

- (void)setCollectionViewFooterViewClass:(Class)collectionViewFooterViewClass {
    _collectionViewFooterViewClass = collectionViewFooterViewClass;
    [self.collectionView registerClass:_collectionViewFooterViewClass forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter withReuseIdentifier:FOOTER_IDENTIFIER];
}

- (void)setRefreshControl:(UIRefreshControl *)refreshControl {
    [_refreshControl removeFromSuperview];
    _refreshControl = refreshControl;
    if (_refreshControl) {
        [self.collectionView addSubview:_refreshControl];
    }
}

- (BOOL)allowsMultipleSelection {
    return self.collectionView.allowsMultipleSelection;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    self.collectionView.allowsMultipleSelection = allowsMultipleSelection;
}

- (void)setHeaderView:(UIView *)headerView {
    // 4 cases in total:
    if (_headerView == nil && headerView == nil) {
        return;
    } else if (_headerView == nil && headerView != nil) {
        _headerView = headerView;
        _headerView.frame = _headerView.bounds;
        
        [self.headerViewContainer addSubview:_headerView];
        
        [self restoreFramesForHeader:NO];
        
    } else if (_headerView != nil && headerView == nil) {
        
        [self restoreFramesForHeader:YES];
        
        [_headerView removeFromSuperview];
        
        _headerView = headerView;
        
    } else if (_headerView != nil && headerView != nil){
        
        [self restoreFramesForHeader:YES];
        
        self.headerViewContainer.bounds = headerView.bounds;
        
        [_headerView removeFromSuperview];
        
        _headerView = headerView;
        _headerView.frame = _headerView.bounds;
        
        [self.headerViewContainer addSubview:_headerView];
        
        [self restoreFramesForHeader:NO];
    }
}

- (void)setFooterView:(UIView *)footerView {
    // 4 cases in total:
    if (_footerView == nil && footerView == nil) {
        return;
    } else if (_footerView == nil && footerView != nil) {
        _footerView = footerView;
        _footerView.frame = footerView.bounds;
        
        [self.footerViewContainer addSubview:_footerView];
        
        [self restoreFramesForFooter:NO];
    } else if (_footerView != nil && footerView == nil) {
        
        [self restoreFramesForFooter:YES];
        
        [_footerView removeFromSuperview];
        
        _footerView = footerView;
    } else if (_footerView != nil && footerView != nil){
        
        [self restoreFramesForFooter:YES];
        
        [_footerView removeFromSuperview];
        
        _footerView = footerView;
        _footerView.frame = footerView.bounds;
        
        [self.footerViewContainer addSubview:_footerView];
        
        [self restoreFramesForFooter:NO];
    }
}


- (UIView *)backgroundViewContainer {
    if (!_backgroundViewContainer) {
        _backgroundViewContainer = [[UIView alloc] initWithFrame:self.collectionView.frame];
        _backgroundViewContainer.userInteractionEnabled = NO;
        _backgroundViewContainer.layer.opacity = 0.0f;
    }
    return _backgroundViewContainer;
}

- (UIView *)overheadViewContainer {
    if (!_overheadViewContainer) {
        _overheadViewContainer = [[UIView alloc] initWithFrame:self.collectionView.frame];
        _overheadViewContainer.layer.opacity = 0.0f;
        _overheadViewContainer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3f];
        _overheadViewContainer.userInteractionEnabled = NO;
    }
    return _overheadViewContainer;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    [_backgroundView removeFromSuperview];
    _backgroundView = backgroundView;
    [self.backgroundViewContainer addSubview:_backgroundView];
    [_backgroundView setCenter:self.backgroundViewContainer.center];
}

- (void)setOverheadView:(UIView *)overheadView {
    [_overheadView removeFromSuperview];
    _overheadView = overheadView;
    [self.overheadViewContainer addSubview:_overheadView];
    [_overheadView setCenter:self.overheadViewContainer.center];
}

- (void)setEndOfDataFooter:(UIView *)endOfDataFooter {
    [_endOfDataFooter removeFromSuperview];
    _endOfDataFooter = endOfDataFooter;
    
    if (self.endOfDataFooterContainer) {
        [self updateDateEndOfDataFooterView];
        [self.endOfDataFooterContainer addSubview:_endOfDataFooter];
    }
}

- (void)setColumnCount:(NSUInteger)columnCount {
    if (_columnCount == columnCount) {
        return;
    }
    if ([self.collectionView.collectionViewLayout isKindOfClass:[CHTCollectionViewWaterfallLayout class]]) {
        
        _columnCount = columnCount;
        
        ((CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout).columnCount = columnCount;
        [((CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout) invalidateLayout];
    }
}

#pragma mark - view functions
- (void)updateCollectionViewCellClass:(Class)cellClass {
    assert([cellClass conformsToProtocol:@protocol(CatScrollerCollectionViewCell)]);
    self.collectionViewCellClass = cellClass;
    
    [self.collectionView reloadData];
}

- (void)setHeaderView:(UIView *)headerView withCompletionBlock:(void (^)(BOOL finished))completion {
    CGRect headerContainerFrame = self.headerViewContainer.frame;
    headerContainerFrame.size.height = 0.0f;
    self.headerViewContainer.frame = headerContainerFrame;
    
    [UIView animateWithDuration:self.headerFooterAnimationSpeed animations:^{
        [self setHeaderView:headerView];
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}

- (void)setFooterView:(UIView *)footerView withCompletionBlock:(void (^)(BOOL finished))completion {
    CGRect footerContainerFrame = self.footerViewContainer.frame;
    footerContainerFrame.origin.y = self.containerView.frame.size.height;
    self.footerViewContainer.frame = footerContainerFrame;
    
    [UIView animateWithDuration:self.headerFooterAnimationSpeed animations:^{
        [self setFooterView:footerView];
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
    
}

- (void)setVisableAdditionalViewForType:(CSAdditionalViewType)viewType {
    self.overheadViewContainer.userInteractionEnabled = NO;
    
    switch (viewType) {
        case CSAdditionalViewTypeNone:
        {
            self.backgroundViewContainer.layer.opacity = 0.0f;
            self.overheadViewContainer.layer.opacity = 0.0f;
        }
            break;
        case CSAdditionalViewTypeBackground:
        {
            self.backgroundViewContainer.layer.opacity = (self.backgroundViewContainer.layer.opacity == 1.0f)?0.0f:1.0f;
        }
            break;
        case CSAdditionalViewTypeBackgroundOn:
        {
            self.backgroundViewContainer.layer.opacity = 1.0f;
        }
            break;
        case CSAdditionalViewTypeBackgroundOff:
        {
            self.backgroundViewContainer.layer.opacity = 0.0f;
        }
            break;
        case CSAdditionalViewTypeOverhead:
        {
            self.overheadViewContainer.layer.opacity = (self.overheadViewContainer.layer.opacity == 1.0f)?0.0f:1.0f;
            self.overheadViewContainer.userInteractionEnabled = (self.overheadViewContainer.userInteractionEnabled)?NO:YES;
        }
            break;
        case CSAdditionalViewTypeOverheadOn:
        {
            self.overheadViewContainer.layer.opacity = 1.0f;
            self.overheadViewContainer.userInteractionEnabled = YES;
        }
            break;
        case CSAdditionalViewTypeOverheadOff:
        {
            self.overheadViewContainer.layer.opacity = 0.0f;
            self.overheadViewContainer.userInteractionEnabled = NO;
        }
            break;
        default:
            break;
    }
}

- (void)setVisableAdditionalViewForType:(CSAdditionalViewType)viewType withCompletionBlock:(void (^)(BOOL))completion {
    [UIView animateWithDuration:self.additionalViewAnimationSpeed animations:^{
        [self setVisableAdditionalViewForType:viewType];
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}

- (void)pushBackData:(NSArray *)data completion:(void (^)(BOOL finished))completion {
    if (data.count == 0) {
        self.currentDataRequestState = CSDataRequestingStateNoMoreData;
        return;
    }
    
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

- (void)removeCellWithArrayOfIndices:(NSArray *) arrayOfIndices completion:(void (^)(BOOL finished))completion {
    if (arrayOfIndices.count == 0) {
        return;
    }
    __block NSMutableIndexSet *aSetOfindices = [[NSMutableIndexSet alloc] init];
    [arrayOfIndices enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        [aSetOfindices addIndex:obj.row];
    }];
    [self.internalData removeObjectsAtIndexes:aSetOfindices];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:arrayOfIndices];
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}

- (void)clearAllDataWithcompletion:(void (^)(BOOL finished))completion {
    [self removeCellWithArrayOfIndices:self.indicesOfAllInternalData completion:completion];
}

- (NSUInteger)findLargestIndexFromVisibleCells {
    __block NSUInteger largestIndex = 0;
    
    [self.collectionView.indexPathsForVisibleItems
     enumerateObjectsWithOptions:NSEnumerationReverse
     usingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        largestIndex = MAX(obj.row, largestIndex);
    }];
    return largestIndex;
}

- (void)setupLayout {
    self.headerViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    self.footerViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)notifyDelegateIfReachedCriticalRange:(NSUInteger)largestIndex updateFromPolicy:(CSDataRequestingPolicy)policy {
    if ((self.internalData.count - largestIndex) >= [self.dataSrouce catScrollerCriticalRangeItemCount]) {
        return;
    }
    if (self.currentDataUpdatePloicy == policy && self.currentDataRequestState == CSDataRequestingStateNormal) {
        self.currentDataRequestState = CSDataRequestingStateWaitingForAddingData;
        
        [self.dataSrouce catScrollerDidEnterCriticalRange];
        
    } else if (policy == CSDataRequestingPolicyAlways) {
        [self.dataSrouce catScrollerDidEnterCriticalRange];
    }
}

- (void)restoreFramesForHeader:(BOOL)shouldRestore {
    CGFloat oldHeaderHeight = self.headerView.frame.size.height;
    CGFloat oldHeaderWidth = self.headerView.frame.size.width;
    
    CGRect newHeaderContainerFrame = CGRectZero;
    newHeaderContainerFrame.size.width = oldHeaderWidth;
    
    self.headerViewContainer.frame = (shouldRestore)?newHeaderContainerFrame:self.headerView.bounds;
    
    CGFloat newHeaderHeight = self.headerViewContainer.frame.size.height;
    
    CGRect collectionViewFrame = self.collectionView.frame;
    
    
    collectionViewFrame.origin.y = (shouldRestore)?0:oldHeaderHeight;
    collectionViewFrame.size.height += (shouldRestore)?(oldHeaderHeight):(-1.0f * newHeaderHeight);
    
    self.collectionView.frame = collectionViewFrame;
}

- (void)restoreFramesForFooter:(BOOL)shouldRestore {
    CGFloat oldFooterHeight = self.footerViewContainer.frame.size.height;
    CGRect footerContinerFrame = self.footerView.bounds;
    CGFloat collectionHeight = self.containerView.frame.size.height;
    CGFloat footerContinerHeight = (shouldRestore)?0:footerContinerFrame.size.height;
    CGFloat newYPos = collectionHeight - footerContinerHeight;
    footerContinerFrame.origin.y = newYPos;
    self.footerViewContainer.frame = footerContinerFrame;
    
    CGFloat newFooterHeight = self.footerViewContainer.frame.size.height;
    
    CGRect collectionViewFrame = self.collectionView.frame;
    
    collectionViewFrame.size.height += (shouldRestore)?oldFooterHeight:(-1.0f * newFooterHeight);
    
    self.collectionView.frame = collectionViewFrame;
}

- (NSArray *)indexPathsForSelectedItems {
    return [self.collectionView indexPathsForSelectedItems];
}

- (void) updateDateEndOfDataFooterView {
    if ([self.collectionView.collectionViewLayout isKindOfClass:[CHTCollectionViewWaterfallLayout class]]) {
        [((CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout) setFooterHeight:0.0f];
    }
    
    // End of data footer container is empty. We are done.
    if (!self.endOfDataFooterContainer) {
        return;
    }
    // Footer is not set yet. We are done as well
    if (!self.endOfDataFooter) {
        return;
    }
    // otherwise update to footerView's size;
    CGFloat fHeight = self.endOfDataFooter.frame.size.height;
    
    if ([self.collectionView.collectionViewLayout isKindOfClass:[CHTCollectionViewWaterfallLayout class]]) {
        [((CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout) setFooterHeight:fHeight];
    }
    
    CGRect footerViewContainerFrame = self.endOfDataFooterContainer.frame;
    footerViewContainerFrame.size.height = fHeight;
    self.endOfDataFooterContainer.frame = footerViewContainerFrame;
    
    self.endOfDataFooter.frame = self.endOfDataFooter.bounds;
    
    CGPoint centerOnX = self.endOfDataFooterContainer.center;
    centerOnX.y = self.endOfDataFooter.center.y;
    self.endOfDataFooter.center = centerOnX;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.internalData.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<CatScrollerCollectionViewCell> *aCell =
    [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(self.collectionViewCellClass) forIndexPath:indexPath];
    [self notifyDelegateIfReachedCriticalRange:indexPath.row updateFromPolicy:CSDataRequestingPolicyOnDisplayingNewItem];
    
    return [aCell render:self.internalData[indexPath.row]];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:HEADER_IDENTIFIER
                                                         forIndexPath:indexPath];
    } else if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:FOOTER_IDENTIFIER
                                                         forIndexPath:indexPath];
        self.endOfDataFooterContainer = reusableView;
        self.endOfDataFooterContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (self.endOfDataFooter) {
            [self updateDateEndOfDataFooterView];
        }
    }
    return reusableView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self notifyDelegateIfReachedCriticalRange:[self findLargestIndexFromVisibleCells] updateFromPolicy:CSDataRequestingPolicyOnViewWillBeginScroll];
    
    // Forward the scrollViewWillBeginDragging call
    [self.viewDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self notifyDelegateIfReachedCriticalRange:[self findLargestIndexFromVisibleCells] updateFromPolicy:CSDataRequestingPolicyOnViewEndScroll];
    
    // Forward the scrollViewDidEndDecelerating call
    [self.viewDelegate scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionViewCellClass heightForData:self.internalData[indexPath.row]];
}

#pragma mark - Message Forwarding
- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL result = [super respondsToSelector:aSelector];
    if (result) {
        return YES;
    }
    
    // Is it part of UICollectionViewDelegate, UIScrollViewDelegate, NSObject protocol?
    struct objc_method_description aDescription = protocol_getMethodDescription(@protocol(UICollectionViewDelegate), aSelector, NO, YES);
    if (aDescription.name == NULL || aDescription.types == NULL) {
        // Not part of the protocal
        return NO;
    }
    
    // Does the view delegate responds to the selector ?
    if ([self.viewDelegate respondsToSelector:aSelector]) {
        // I'm lying and planning to forward the call the the view delegate
        return YES;
    }
        return NO;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    // Check if view delegate conforms to CatScrollerCollectionViewDelegate protocol forward all the call view delegate response to
    if ([self.viewDelegate conformsToProtocol:@protocol(CatScrollerCollectionViewDelegate)]
        && [self.viewDelegate respondsToSelector:anInvocation.selector])
    {
        // Forward the call
        [anInvocation invokeWithTarget:self.viewDelegate];
    }
}

#pragma mark - NSKeyValueObserving 
// For setting background and overhead view
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.overheadViewContainer.frame = self.collectionView.frame;
    self.backgroundViewContainer.frame = self.collectionView.frame;
}

@end
