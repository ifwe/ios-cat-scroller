//
//  DFSViewController.m
//  CatScrollerExample
//
//  Created by Yong Xin Dai on 2/6/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CatScrollerCollectionViewDelegate, CatScrollerCollectionViewDataSource>

@property (nonatomic, strong) CatScroller *cat;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong , nonatomic) NSMutableArray * selectedIndices;

@property (weak, nonatomic) IBOutlet UISwitch *multiSelectionSwitch;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.containerView addSubview:self.cat.containerView];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CatScroller *)cat
{
    if (!_cat) {
        _cat = [[CatScroller alloc] initWithFrame:self.containerView.bounds
                          withCollectionCellClass:[CatScrollerCell class] withDelegate:self];
        _cat.dataSrouce = self;
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor grayColor];
        [refreshControl addTarget:self action:@selector(refershControlAction:) forControlEvents:UIControlEventValueChanged];
        _cat.refreshControl = refreshControl;
        
    }
    return _cat;
}

- (NSMutableArray *)selectedIndices
{
    if (!_selectedIndices) {
        _selectedIndices = [[NSMutableArray alloc] init];
    }
    return _selectedIndices;
}

- (IBAction)addDataToCollection:(UIBarButtonItem *)sender {
    [self.cat pushBackData:@[@{CELL_HEIGHT_NAME:@(arc4random()%130+5)}, @{CELL_HEIGHT_NAME:@(arc4random()%130+5)}] completion:nil];
}


- (IBAction)switchToMultiSelection:(UISwitch *)sender forEvent:(UIEvent *)event {
    self.cat.allowsMultipleSelection = sender.isOn;
}

- (IBAction)removeObjectInCollectionView:(UIBarButtonItem *)sender {
    [self.cat removeCellWithArrayOfIndices:self.selectedIndices completion:nil];
    [self.selectedIndices removeAllObjects];
}

- (IBAction)HeaderSwitch:(UISwitch *)sender {
    
    if (sender.isOn) {
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cat.containerView.frame.size.width, 30)];
        headerView.backgroundColor = [UIColor colorWithWhite:((arc4random()%250) / 250.0f) alpha:1.0f];
        [self.cat setHeaderView:headerView withCompletionBlock:nil];
    }else{
        [self.cat setHeaderView:nil withCompletionBlock:nil];
    }
}
- (IBAction)FooterSwitch:(UISwitch *)sender {
    if (sender.isOn) {
        UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cat.containerView.frame.size.width, 30)];
        footerView.backgroundColor = [UIColor colorWithWhite:((arc4random()%250) / 250.0f) alpha:1.0f];
        [self.cat setFooterView:footerView withCompletionBlock:nil];
    }else{
        [self.cat setFooterView:nil withCompletionBlock:nil];
    }
}

- (CGFloat) CatScrollerItemsWidth{
    return 135.0f;
}

- (void) refershControlAction: (UIRefreshControl *)sender{
    [self.cat.refreshControl endRefreshing];
}



- (void) CatScrollerDidEnterCriticalRange
{
    [[[UIAlertView alloc] initWithTitle:@"I'm hungry for more data" message:@"" delegate:nil cancelButtonTitle:@"Data!" otherButtonTitles:nil] show];
}

- (NSUInteger) CatScrollerCriticalRangeItemCount
{
    return 5;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (!self.multiSelectionSwitch.isOn) {
        [self.selectedIndices removeAllObjects];
    }
    [self.selectedIndices addObject:indexPath];
    
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.selectedIndices enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        if ([indexPath compare:obj] == NSOrderedSame)
        {
            [self.selectedIndices removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
}


//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    
//}


@end
