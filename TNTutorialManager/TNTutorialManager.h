//
//  TNTutorialManager.h
//  TNTutorialManagerSample
//
//  Created by Tawa Nicolas on 25/6/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNTutorialEdgeInsets : NSObject

-(instancetype)initWithEdgeInsets:(UIEdgeInsets)insets;

@end

#define TNTutorialEdgeInsetsMake(top,left,bottom,right) [[TNTutorialEdgeInsets alloc] initWithEdgeInsets:UIEdgeInsetsMake(top, left, bottom, right)]


typedef NS_ENUM(NSInteger, TNTutorialTextPosition) {
	TNTutorialTextPositionNone,
	TNTutorialTextPositionTop,
	TNTutorialTextPositionBottom,
	TNTutorialTextPositionLeft,
	TNTutorialTextPositionRight
};

@protocol TNTutorialManagerDelegate <NSObject>

@required
/**
 This required method is used to clean up after the tutorial. Ideally used to set the the TNTutorialManager pointer to nil, and sometimes re-enable UserInteraction for the UI.
 */
-(void)tutorialWrapUp;

/**
 This method should return the max index of the tutorial. The index should be the number of steps the tutorial has.
 */
-(NSInteger)tutorialMaxIndex;

/**
 The tutorialMasterView is the UIView that will add the tutorialView as a subview.
 */
-(UIView *)tutorialMasterView;

@optional
/**
 Perform actions for a tutorial step, example: Tap a certain button.
 */
-(void)tutorialPerformAction:(NSInteger)index;

/**
 Actions that need to be done before the highlight is done. Example, scroll to a certain UITableViewCell.
 */
-(void)tutorialPreHighlightAction:(NSInteger)index;

/**
 This optional method should return the delay in seconds that the tutorialManager should wait before performing the next highlight, it is used in case there's a UI update that needs to be done.
 */
-(CGFloat)tutorialPreActionDelay:(NSUInteger)index;

/**
 This optional method should return NO in case the tutorial shouldn't update for a certain index. Example: If the UI pushes a new UIViewController and you need to start a new tutorial from inside the new UIViewController.
 */
-(BOOL)tutorialWaitAfterAction:(NSInteger)index;

/**
 Methods used for building Tutorial UI.
 */
-(NSArray <UIView *> *)tutorialViewsToHighlight:(NSInteger)index;
-(NSArray <NSString *> *)tutorialTexts:(NSInteger)index;
-(NSArray <TNTutorialEdgeInsets *> *)tutorialViewsEdgeInsets:(NSInteger)index;
-(NSArray <NSNumber *> *)tutorialTextPositions:(NSInteger)index;
-(NSArray <UIFont *> *)tutorialTextFonts:(NSInteger)index;
-(NSArray <UIColor *> *)tutorialTextColors:(NSInteger)index;
-(UIColor *)tutorialTint:(NSInteger)index;

// Implement this method in case you wish to force the user to go through tutorial.
-(BOOL)tutorialHasSkipButton:(NSInteger)index;

// Default values are "Next" and "Skip". Implement those methods in case you wish to Localize your application or use different titles.
-(UIFont *)tutorialSkipButtonFont;
-(NSString *)tutorialSkipButtonTitle;

// Default value is [UIColor whiteColor].
-(UIColor *)tutorialButtonsColor;

// Identifier used in NSUserDefaults to save the progress of the tutorial for the specific view controllers. The default value is the class name of the delegate. Implement only in case the same UIViewController class will be used multiple times in your UI and need a different identifier for each time it is used.
-(NSString *)tutorialIdentifier;

@end

@interface TNTutorialManager : NSObject

@property (strong, nonatomic) UIView *tutorialView;

@property (weak, nonatomic) id<TNTutorialManagerDelegate> delegate;

-(instancetype)initWithDelegate:(id<TNTutorialManagerDelegate>)delegate;

-(instancetype)initWithDelegate:(id<TNTutorialManagerDelegate>)delegate blurFactor:(CGFloat)blurFactor;

-(NSInteger)currentIndex;

-(void)updateTutorial;

+(BOOL)shouldDisplayTutorial:(id<TNTutorialManagerDelegate>)delegate;

@end
