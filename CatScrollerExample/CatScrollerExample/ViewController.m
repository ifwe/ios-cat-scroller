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



- (IBAction)addDataToCollection:(UIBarButtonItem *)sender {
    [self.cat pushBackData:@[@{CELL_HEIGHT_NAME:@(arc4random()%130+5)}, @{CELL_HEIGHT_NAME:@(arc4random()%130+5)}] completion:nil];
}


- (IBAction)switchToMultiSelection:(UISwitch *)sender forEvent:(UIEvent *)event {
    self.cat.allowsMultipleSelection = sender.isOn;
}



- (CGFloat) CatScrollerItemsWidth{
    return 150.0f;
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
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    
//}


@end
