//
//  FirstViewController.m
//  TNTutorialManagerSample
//
//  Created by Tawa Nicolas on 25/6/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "FirstViewController.h"
#import "TNTutorialManager.h"

@interface FirstViewController () <TNTutorialManagerDelegate>
{
	TNTutorialManager *tutorialManager;
}

@end

@implementation FirstViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	if ([TNTutorialManager shouldDisplayTutorial:self]) {
		tutorialManager = [[TNTutorialManager alloc] initWithDelegate:self blurFactor:0.1];
	} else {
		tutorialManager = nil;
	}
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (tutorialManager) {
		[tutorialManager updateTutorial];
	}
}

-(NSArray<UIView *> *)tutorialViewsToHighlight:(NSInteger)index
{
	if (index == 1) {
		return @[_label1];
	} else if (index == 2) {
		return @[_label2];
	}
	
	return nil;
}

-(NSArray<NSString *> *)tutorialTexts:(NSInteger)index
{
	if (index == 0) {
		return @[@"Welcome to the tutorial!"];
	} else if (index == 1) {
		return @[@"This is _label1"];
	} else if (index == 2) {
		return @[@"This is _label2"];
	}
	
	return nil;
}

-(NSArray<TNTutorialEdgeInsets *> *)tutorialViewsEdgeInsets:(NSInteger)index
{
	if (index == 1) {
		return @[TNTutorialEdgeInsetsMake(8, 8, 8, 8)];
	}

	return nil;
}

-(NSArray<NSNumber *> *)tutorialTextPositions:(NSInteger)index
{
	return @[@(TNTutorialTextPositionTop)];
}

-(CGFloat)tutorialDelay:(NSInteger)index
{
	return 0;
}

-(BOOL)tutorialShouldCoverStatusBar
{
	return YES;
}

-(void)tutorialWrapUp
{
	tutorialManager = nil;
}

-(NSInteger)tutorialMaxIndex
{
	return 3;
}

-(UIFont *)tutorialSkipButtonFont
{
	return [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
}

-(NSArray<UIFont *> *)tutorialTextFonts:(NSInteger)index
{
	if (index == 0) {
		return @[[UIFont systemFontOfSize:35.f weight:UIFontWeightBold]];
	}
	
	return @[[UIFont systemFontOfSize:17.f]];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
