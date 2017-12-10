//
//  SecondViewController.m
//  TNTutorialManagerSample
//
//  Created by Tawa Nicolas on 25/6/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "SecondViewController.h"
#import "TNTutorialManager.h"

@interface SecondViewController () <TNTutorialManagerDelegate>
{
	TNTutorialManager *tutorialManager;
}

@end

@implementation SecondViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	if ([TNTutorialManager shouldDisplayTutorial:self]) {
		tutorialManager = [[TNTutorialManager alloc] initWithDelegate:self];
		[tutorialManager updateTutorial];
		[self.tableView setUserInteractionEnabled:NO];
	} else {
		tutorialManager = nil;
	}
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (self.tableView.indexPathForSelectedRow) {
		[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
	}
	if (tutorialManager) {
		[tutorialManager updateTutorial];
	}
}

-(void)tutorialWrapUp
{
	[self.tableView setUserInteractionEnabled:YES];
	tutorialManager = nil;
}

-(UIView *)tutorialMasterView
{
	return self.tabBarController.view;
}

-(CGFloat)tutorialPreActionDelay:(NSUInteger)index
{
	if (index > 1) {
		return 0.4;
	}
	return 0.0;
}

-(void)tutorialPreHighlightAction:(NSInteger)index
{
	if (index == 2) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:49 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	} else if (index == 3) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:99 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	} else if (index == 4) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

-(void)tutorialPerformAction:(NSInteger)index
{
	if (index == 4) {
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
		
		[self performSegueWithIdentifier:@"gotoDetails" sender:self];
	}
}

-(BOOL)tutorialWaitAfterAction:(NSInteger)index
{
	if (index == 4) {
		return YES;
	}
	
	return NO;
}

-(NSArray<UIView *> *)tutorialViewsToHighlight:(NSInteger)index
{
	if (index == 0) {
		return @[[self.navigationItem.leftBarButtonItem valueForKey:@"view"], [self.navigationItem.rightBarButtonItem valueForKey:@"view"]];
	} else if (index == 1 || index == 4) {
		for (UITableViewCell *cell in [self.tableView visibleCells]) {
			NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
			if (indexPath.row == 0) {
				return @[cell];
			}
		}
	} else if (index == 2) {
		for (UITableViewCell *cell in [self.tableView visibleCells]) {
			NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
			if (indexPath.row == 49) {
				return @[cell];
			}
		}
	} else if (index == 3) {
		for (UITableViewCell *cell in [self.tableView visibleCells]) {
			NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
			if (indexPath.row == 99) {
				return @[cell];
			}
		}
	}
	
	return nil;
}

-(NSArray<NSString *> *)tutorialTexts:(NSInteger)index
{
	if (index == 0) {
		return @[@"This is where you add", @"This is where you're mad"];
	} else if (index == 1) {
		return @[@"This is the first cell"];
	} else if (index == 2) {
		return @[@"This is the 50th cell"];
	} else if (index == 3) {
		return @[@"This is the last cell"];
	} else if (index == 4) {
		return @[@"Tap this cell!"];
	} else if (index == 5) {
		return @[@"That's all folks!"];
	}
	
	return nil;
}

-(BOOL)tutorialAcceptTapsOnHighlightsOnly:(NSInteger)index
{
	if (index == 4) {
		return YES;
	}
	return NO;
}


-(UIColor *)tutorialTint:(NSInteger)index
{
	if (index == 0) {
		return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
	} else if (index == 1) {
		return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
	} else if (index == 2) {
		return [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
	} else if (index == 3) {
		return [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
	} else if (index == 4) {
		return [UIColor colorWithRed:1 green:0 blue:1 alpha:0.5];
	} else if (index == 5) {
		return [UIColor colorWithRed:0 green:1 blue:1 alpha:0.5];
	}
	
	return nil;
}

-(NSArray<UIColor *> *)tutorialTextColors:(NSInteger)index
{
	if (index == 0) {
		return @[[UIColor greenColor], [UIColor blueColor]];
	}
	return nil;
}

-(NSArray<UIFont *> *)tutorialTextFonts:(NSInteger)index
{
	if (index == 5) {
		return @[[UIFont systemFontOfSize:30 weight:UIFontWeightBold]];
	}
	
	return nil;;
}

-(NSArray<NSNumber *> *)tutorialTextPositions:(NSInteger)index
{
	if (index == 0) {
		return @[@(TNTutorialTextPositionRight),
				 @(TNTutorialTextPositionBottom)];
	} else if (index == 3) {
		return @[@(TNTutorialTextPositionTop)];
	}
	return @[@(TNTutorialTextPositionBottom)];
}

-(BOOL)tutorialHasSkipButton:(NSInteger)index
{
	return index > 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row+1];
	
	return cell;
}

-(NSInteger)tutorialMaxIndex
{
	return 6;
}

@end
