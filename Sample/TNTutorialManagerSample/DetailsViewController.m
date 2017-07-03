//
//  DetailsViewController.m
//  TNTutorialManagerSample
//
//  Created by Tawa Nicolas on 2/7/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "DetailsViewController.h"
#import "TNTutorialManager.h"

@interface DetailsViewController () <TNTutorialManagerDelegate>
{
	TNTutorialManager *tutorialManager;
}

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	if ([TNTutorialManager shouldDisplayTutorial:self]) {
		tutorialManager = [[TNTutorialManager alloc] initWithDelegate:self];
	} else {
		tutorialManager = nil;
	}
}

-(void)tutorialWrapUp
{
	tutorialManager = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
	if (tutorialManager) {
		[tutorialManager updateTutorial];
	}
}

-(UIView *)tutorialMasterView
{
	return self.tabBarController.view;
}

-(NSInteger)tutorialMaxIndex
{
	return 2;
}

-(NSArray<UIView *> *)tutorialViewsToHighlight:(NSInteger)index
{
	if (index == 0) {
		return @[self.detailLabel];
	}
	
	return nil;
}

-(BOOL)tutorialHasSkipButton:(NSInteger)index
{
	return NO;
}

-(NSArray<NSString *> *)tutorialTexts:(NSInteger)index
{
	if (index == 0) {
		return @[@"Some info"];
	} else if (index == 1) {
		return @[@"Now go back"];
	}
	
	return nil;
}

-(void)tutorialPerformAction:(NSInteger)index
{
	if (index == 1) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
