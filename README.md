# TNTutorialManager

## Summary
TNTutorialManager is an easy to implement library that helps you create interactive On Boarding and Tutorials inside your iOS Apps!

![](https://thumbs.gfycat.com/RectangularCalculatingJackal-size_restricted.gif)
> Full resolution gif <a href="https://gfycat.com/RectangularCalculatingJackal" target="_blank">here</a>.

## Installation

#### Manual install
Download the folder 'TNTutorialManager' and add the files to your project.
> Objective-C only

#### Cocoapods
Add the following line to your Podfile
```ruby
pod 'TNTutorialManager'
```
> The pod supports both Objective-C and Swift

## Integration
In order to add a tutorial for your specific ViewController all you need to do is `#import <TNTutorialManager.h>` (Objective-C) or `import TNTutorialManager` (Swift), make your ViewController conform to the protocol `TNTutorialManagerDelegate`, and implement the following required methods:
#### Objective-C
```objective-c
-(UIView *)tutorialMasterView;
-(BOOL)tutorialShouldCoverStatusBar;
-(void)tutorialWrapUp;
-(NSInteger)tutorialMaxIndex;
```
#### Swift
```swift
func tutorialMasterView() -> UIView!
func tutorialShouldCoverStatusBar() -> Bool
func tutorialWrapUp()
func tutorialMaxIndex() -> Int
```

The method `tutorialMasterView` should return the UIView that will add the tutorial view as a subview.
The method `tutorialShouldCoverStatusBar` if implemented and returns `YES` or `true`, makes the manager ignore `tutorialMasterView` and create its own window that will be displayed over the status bar.
The method `tutorialWrapUp` should do the code that takes care of ending the tutorial, like setting the `tutorialManager` to nil and re-enabling UserInteraction.
The method `tutorialMaxIndex` should return how many steps the tutorial have.

Creating your TNTutorialManager object is as easy as:
* **Objective-C:** `tutorialManager = [[TNTutorialManager alloc] initWithDelegate:self];`

* **Swift:** `let tm: TNTutorialManager = TNTutorialManager(delegate: self)`

Or, also specifying the Blur intensity, instead use:

* **Objective-C:** `-(instancetype)initWithDelegate:(id<TNTutorialManagerDelegate>)delegate blurFactor:(CGFloat)blurFactor;`

* **Swift:** `let tm: TNTutorialManager = TNTutorialManager(delegate: self, blurFactor: 0.1)`

...where `blurFactor` is a value between `0` and `1`. The default value is `0.1`.

The other optional methods will help you easily make an interactive tutorial.

#### Objective-C

```objective-c
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
 Implementing this gives you the ability to force the user to tap on highlighted views instead of anywhere.
 If there are no views highlighted in a certain tutorial step, this will be ignored, and the user will be able to tap anywhere.
 */
-(BOOL)tutorialAcceptTapsOnHighlightsOnly:(NSInteger)index;

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
```

#### Swift

```Swift
/**
 Perform actions for a tutorial step, example: Tap a certain button.
 */
func tutorialPerformAction(_ index: Int)

/**
 Actions that need to be done before the highlight is done. Example, scroll to a certain UITableViewCell.
 */
func tutorialPreHighlightAction(_ index: Int)

/**
 This optional method should return the delay in seconds that the tutorialManager should wait before performing
 the next highlight, it is used in case there's a UI update that needs to be done.
 */
func tutorialPreActionDelay(_ index: UInt) -> CGFloat

/**
 This optional method should return NO in case the tutorial shouldn't update for a certain index. Example: If 
 the UI pushes a new UIViewController and you need to start a new tutorial from inside the new UIViewController.
 */
func tutorialWait(afterAction index: Int) -> Bool

/**
 Methods used for building Tutorial UI.
 */
func tutorialViews(toHighlight index: Int) -> [UIView]!
func tutorialTexts(_ index: Int) -> [String]!
func tutorialViewsEdgeInsets(_ index: Int) -> [TNTutorialEdgeInsets]!
func tutorialTextPositions(_ index: Int) -> [NSNumber]!
func tutorialTextFonts(_ index: Int) -> [UIFont]!
func tutorialTextColors(_ index: Int) -> [UIColor]!
func tutorialTint(_ index: Int) -> UIColor!

// Implement this method in case you wish to force the user to go through tutorial.
func tutorialHasSkipButton(_ index: Int) -> Bool

/**
 Default values are "Next" and "Skip". Implement those methods in case you wish to Localize your application
 or use different titles.
 */
func tutorialSkipButtonFont() -> UIFont!
func tutorialSkipButtonTitle() -> String!

// Default value is UIColor.white.
func tutorialButtonsColor() -> UIColor!

/**
 Identifier used in NSUserDefaults to save the progress of the tutorial for the specific view controllers.
 The default value is the class name of the delegate. Implement only in case the same UIViewController class
 will be used multiple times in your UI and need a different identifier for each time it is used.
 */
func tutorialIdentifier() -> String!
```

The repository comes with a sample Objective-C project that gives you an example of how to implement different capabilities of the manager.

## Notes

Feel free to use 'TNTutorialManager' in any way you like. An attribution is not required, but is highly appreciated.
