//
//  DFSViewController.m
//  CatScrollerExample
//
//  Created by Yong Xin Dai on 2/6/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CatScrollerCollectionViewDelegate>

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
    }
    return _cat;
}



- (IBAction)addDataToCollection:(UIBarButtonItem *)sender {
    [self.cat addData:@[@{CELL_HEIGHT_NAME:@(arc4random()%130+5)}, @{CELL_HEIGHT_NAME:@(arc4random()%130+5)}] animated:YES];
}



- (CGFloat) CatScrollerItemsWidth{
    return 150.0f;
}

@end
