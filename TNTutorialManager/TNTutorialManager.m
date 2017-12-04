//
//  TNTutorialManager.m
//  TNTutorialManagerSample
//
//  Created by Tawa Nicolas on 25/6/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "TNTutorialManager.h"

@implementation TNTutorialEdgeInsets
{
	UIEdgeInsets insets;
}

-(instancetype)initWithEdgeInsets:(UIEdgeInsets)i
{
	self = [super init];
	
	if (self) {
		insets = i;
	}
	
	return self;
}

-(UIEdgeInsets)insets
{
	return insets;
}

@end

@interface TNTutorialManager ()
{
	UIView *tutorialView;
	UIView *tutorialBlurView;
	UIViewPropertyAnimator *animator;
	NSArray <UIView *> *tutorialViewsToMask;
	NSMutableArray <UILabel *> *tutorialLabels;
	UIButton *tutorialSkipButton;
	
	CGFloat blurConstant;
	
	UIWindow *tutorialWindow;
	UIViewController *tutorialViewController;
	UIVisualEffectView *visualEffectView;
}

@end

@implementation TNTutorialManager

@synthesize tutorialView;

-(instancetype)initWithDelegate:(id<TNTutorialManagerDelegate>)delegate blurFactor:(CGFloat)blurFactor
{
	self = [super init];
	
	if (self) {
		self.delegate = delegate;
		
		tutorialSkipButton = nil;
		tutorialView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		[tutorialView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
		
		tutorialBlurView = [[UIView alloc] initWithFrame:tutorialView.bounds];
		[tutorialBlurView setBackgroundColor:[UIColor clearColor]];
		
		[tutorialView insertSubview:tutorialBlurView atIndex:0];
		
		UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
		visualEffectView = [[UIVisualEffectView alloc] init];
		
		animator = [[UIViewPropertyAnimator alloc] initWithDuration:1 curve:UIViewAnimationCurveLinear animations:^{
			visualEffectView.effect = blurEffect;
		}];
		
		visualEffectView.frame = tutorialBlurView.bounds;
		[tutorialBlurView addSubview:visualEffectView];
		
		tutorialLabels = [NSMutableArray array];
		
		blurConstant = blurFactor;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithDelegate:(id<TNTutorialManagerDelegate>)delegate
{
	return [self initWithDelegate:delegate blurFactor:0.05];
}

-(UIView *)tutorialContainer
{
	if ([self.delegate respondsToSelector:@selector(tutorialShouldCoverStatusBar)] &&
		[self.delegate tutorialShouldCoverStatusBar]) {
		if (tutorialViewController == nil) {
			tutorialViewController = [[UIViewController alloc] init];
			tutorialViewController.view.backgroundColor = [UIColor clearColor];
		}
		if (tutorialWindow == nil) {
			tutorialWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
			tutorialWindow.rootViewController = tutorialViewController;
			tutorialWindow.windowLevel = UIWindowLevelStatusBar + 1;
			[tutorialWindow makeKeyAndVisible];
		}
		
		return tutorialViewController.view;
	} else {
		return [self.delegate tutorialMasterView];
	}
}

-(void)highlightViews:(NSArray <UIView *> *)views
{
	[tutorialView setUserInteractionEnabled:YES];
	if (tutorialView.superview == nil) {
		[[self tutorialContainer] addSubview:tutorialView];
	}
	
	UIColor *tintColor = nil;
	if ([self.delegate respondsToSelector:@selector(tutorialTint:)]) {
		tintColor = [self.delegate tutorialTint:[self currentIndex]];
	} else {
		tintColor = [UIColor colorWithWhite:0 alpha:0.5];
	}
	[tutorialView setBackgroundColor:tintColor];
	
	tutorialViewsToMask = views;
	
	if (tutorialSkipButton == nil) {
		tutorialSkipButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[tutorialSkipButton addTarget:self action:@selector(tutorialSkip) forControlEvents:UIControlEventTouchUpInside];
		
		NSString *skipTitle;
		if ([self.delegate respondsToSelector:@selector(tutorialSkipButtonTitle)]) {
			skipTitle = [self.delegate tutorialSkipButtonTitle];
		} else {
			skipTitle = @"Skip";
		}
		UIColor *skipColor;
		if ([self.delegate respondsToSelector:@selector(tutorialButtonsColor)]) {
			skipColor = [self.delegate tutorialButtonsColor];
		} else {
			skipColor = [UIColor whiteColor];
		}
		
		[tutorialSkipButton setTitle:skipTitle forState:UIControlStateNormal];
		[tutorialSkipButton setTitleColor:skipColor forState:UIControlStateNormal];
		
		[[self tutorialContainer] addSubview:tutorialSkipButton];
	}
	
	[self setupLayout];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateTutorial:)];
	[tutorialView addGestureRecognizer:tap];
	
	tutorialView.alpha = 0;
	[tutorialView setHidden:NO];
	[self updateAnimator];
	[UIView animateWithDuration:0.3 animations:^{
		tutorialView.alpha = 1;
	}];
}

-(void)setupLayout
{
	[tutorialLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[tutorialLabels removeAllObjects];
	
	UIGraphicsBeginImageContext(tutorialView.frame.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGRect frame;
	
	NSArray <NSString *> *texts = nil;
	if ([self.delegate respondsToSelector:@selector(tutorialTexts:)]) {
		texts = [self.delegate tutorialTexts:[self currentIndex]];
	}
	NSArray <NSNumber *> *positions = nil;
	if ([self.delegate respondsToSelector:@selector(tutorialTextPositions:)]) {
		positions = [self.delegate tutorialTextPositions:[self currentIndex]];
	}
	NSArray <TNTutorialEdgeInsets *> *edgeInsetsArray = nil;
	if ([self.delegate respondsToSelector:@selector(tutorialViewsEdgeInsets:)]) {
		edgeInsetsArray = [self.delegate tutorialViewsEdgeInsets:[self currentIndex]];
	}
	
	if ([tutorialViewsToMask count] > 0) {
		for (int i = 0; i < [tutorialViewsToMask count]; i++) {
			UIView *view = tutorialViewsToMask[i];
			frame = [[self tutorialContainer] convertRect:[view frame] fromView:view.superview];
			
			if (edgeInsetsArray) {
				UIEdgeInsets edgeInsets = [edgeInsetsArray[i] insets];
				if (edgeInsets.top) {
					frame.origin.y -= edgeInsets.top;
					frame.size.height += edgeInsets.top;
				}
				if (edgeInsets.bottom) {
					frame.size.height += edgeInsets.bottom;
				}
				if (edgeInsets.left) {
					frame.origin.x -= edgeInsets.left;
					frame.size.width += edgeInsets.left;
				}
				if (edgeInsets.right) {
					frame.size.width += edgeInsets.right;
				}
			}
			
			CGContextFillRect(context, frame);
			
			if (texts && [texts count] > i) {
				NSString *text = texts[i];
				if (text && [text length] > 0) {
					UILabel *label = [[UILabel alloc] init];
					[label setTextColor:[UIColor whiteColor]];
					label.layer.masksToBounds = NO;
					label.layer.shadowRadius = 8;
					label.layer.shadowOpacity = 1;
					label.layer.shadowOffset = CGSizeZero;
					label.layer.shouldRasterize = YES;
					label.layer.shadowColor = [[UIColor blackColor] CGColor];
					
					NSArray <UIFont *> *fonts = nil;
					if ([self.delegate respondsToSelector:@selector(tutorialTextFonts:)]) {
						fonts = [self.delegate tutorialTextFonts:[self currentIndex]];
					}
					UIFont *font;
					if (fonts && [fonts count] > i) {
						font = fonts[i];
					} else {
						font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
					}
					[label setFont:font];
					
					NSArray *colors = nil;
					if ([self.delegate respondsToSelector:@selector(tutorialTextColors:)]) {
						colors = [self.delegate tutorialTextColors:[self currentIndex]];
					}
					UIColor *color;
					if (colors && [colors count] > 0) {
						color = colors[i];
					} else {
						color = [UIColor whiteColor];
					}
					[label setTextColor:color];
					
					[label setNumberOfLines:0];
					[label setText:text];
					NSDictionary *attributes = @{NSFontAttributeName: label.font};
					CGFloat width = [UIScreen mainScreen].bounds.size.width - 16.f;
					NSNumber *position = nil;
					if (positions && [positions count] > i) {
						position = positions[i];
					}
					TNTutorialTextPosition pos = position?[position integerValue]:TNTutorialTextPositionTop;
					if (pos == TNTutorialTextPositionLeft) {
						width = frame.origin.y - 16.f;
					} else if (pos == TNTutorialTextPositionRight) {
						width = [UIScreen mainScreen].bounds.size.width - frame.origin.y - frame.size.width - 16.f;
					}
					
					CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
					
					if (pos == TNTutorialTextPositionTop) {
						rect.origin.y = frame.origin.y - rect.size.height - 8;
						rect.origin.x = frame.origin.x + frame.size.width * 0.5f - rect.size.width * 0.5f;
					} else if (pos == TNTutorialTextPositionBottom) {
						rect.origin.y = frame.origin.y + frame.size.height + 8.f;
						rect.origin.x = frame.origin.x + frame.size.width * 0.5f - rect.size.width * 0.5f;
					} else if (pos == TNTutorialTextPositionLeft) {
						rect.origin.y = frame.origin.y + frame.size.height * 0.5f - rect.size.height * 0.5f;
						rect.origin.x = frame.origin.x - 8.f - rect.size.width;
					} else if (pos == TNTutorialTextPositionRight) {
						rect.origin.y = frame.origin.y + frame.size.height * 0.5f - rect.size.height * 0.5f;
						rect.origin.x = frame.origin.x + frame.size.width + 8.f;
					}
					if (rect.origin.x < 8.f) {
						rect.origin.x = 8.f;
					} else if (rect.origin.x + rect.size.width > [UIScreen mainScreen].bounds.size.width - 8.f) {
						rect.origin.x = [UIScreen mainScreen].bounds.size.width - 8.f - rect.size.width;
					}
					[label setFrame:rect];
					[tutorialView addSubview:label];
					[tutorialLabels addObject:label];
				}
			}
		}
	} else if ([texts count] > 0) {
		NSString *text = [texts firstObject];
		UILabel *label = [[UILabel alloc] init];
		[label setTextColor:[UIColor whiteColor]];
		label.layer.masksToBounds = NO;
		label.layer.shadowRadius = 8;
		label.layer.shadowOpacity = 1;
		label.layer.shadowOffset = CGSizeZero;
		label.layer.shouldRasterize = YES;
		label.layer.shadowColor = [[UIColor blackColor] CGColor];

		NSArray <UIFont *> *fonts = nil;
		if ([self.delegate respondsToSelector:@selector(tutorialTextFonts:)]) {
			fonts = [self.delegate tutorialTextFonts:[self currentIndex]];
		}
		UIFont *font;
		if (fonts && [fonts count] > 0) {
			font = fonts[0];
		} else {
			font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		}
		[label setFont:font];
		
		NSArray *colors = nil;
		if ([self.delegate respondsToSelector:@selector(tutorialTextColors:)]) {
			colors = [self.delegate tutorialTextColors:[self currentIndex]];
		}
		UIColor *color;
		if (colors && [colors count] > 0) {
			color = colors[0];
		} else {
			color = [UIColor whiteColor];
		}
		[label setTextColor:color];
		
		[label setNumberOfLines:0];
		[label setText:text];
		[label setTextAlignment:NSTextAlignmentCenter];
		NSDictionary *attributes = @{NSFontAttributeName: label.font};
		
		CGFloat width = [UIScreen mainScreen].bounds.size.width-16.f;
		CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
										 options:NSStringDrawingUsesLineFragmentOrigin
									  attributes:attributes
										 context:nil];
		CGPoint center = CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height*0.5);
		rect.origin.x = center.x-rect.size.width*0.5f;
		rect.origin.y = center.y-rect.size.height*0.5f;
		[label setFrame:rect];
		[tutorialView addSubview:label];
		[tutorialLabels addObject:label];
	}
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	{
		CGSize size = image.size;
		int width = size.width;
		int height = size.height;
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
		CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
		CGColorSpaceRelease(colorSpace);
		
		CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
		
		for (int y = 0; y < height; y++) {
			unsigned char *linePointer = &memoryPool[y * width * 4];
			for (int x = 0; x < width; x++) {
				if (linePointer[3] > 0) {
					linePointer[0] = 0;
					linePointer[1] = 0;
					linePointer[2] = 0;
					linePointer[3] = 0;
				} else {
					linePointer[3] = 255;
				}
				linePointer += 4;
			}
		}
		
		CGImageRef cgImage = CGBitmapContextCreateImage(context);
		UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
		
		CGImageRelease(cgImage);
		CGContextRelease(context);
		free(memoryPool);
		
		image = returnImage;
	}
	
	[tutorialView setNeedsDisplay];
	
	{
		CALayer* maskLayer = [CALayer layer];
		maskLayer.frame = CGRectMake(0, 0, tutorialView.frame.size.width, tutorialView.frame.size.height);
		maskLayer.contents = (__bridge id)[image CGImage];
		
		tutorialView.layer.mask = maskLayer;
	}
	
	if ((![self.delegate respondsToSelector:@selector(tutorialHasSkipButton:)] || [self.delegate tutorialHasSkipButton:[self currentIndex]]) && [self currentIndex] < [self.delegate tutorialMaxIndex]-1) {
		UIFont *font;
		if ([self.delegate respondsToSelector:@selector(tutorialSkipButtonFont)]) {
			font = [self.delegate tutorialSkipButtonFont];
		} else {
			font = [UIFont systemFontOfSize:17.f];
		}
		NSDictionary *attributes = @{NSFontAttributeName:font};
		
		NSString *skipTitle;
		if ([self.delegate respondsToSelector:@selector(tutorialSkipButtonTitle)]) {
			skipTitle = [self.delegate tutorialSkipButtonTitle];
		} else {
			skipTitle = @"Skip";
		}
		frame = [skipTitle boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX)
										options:NSStringDrawingUsesLineFragmentOrigin
									 attributes:attributes
										context:nil];
		frame = CGRectMake(ceil([UIScreen mainScreen].bounds.size.width-frame.size.width)-16, 20, ceil(frame.size.width), 44);
		[tutorialSkipButton.titleLabel setFont:font];
		[tutorialSkipButton setFrame:frame];
		[tutorialSkipButton setHidden:NO];
	} else {
		[tutorialSkipButton setHidden:YES];
	}
}

-(void)handleOrientationChange:(NSNotification *)notification
{
	tutorialView.frame = [UIScreen mainScreen].bounds;
	tutorialBlurView.frame = [UIScreen mainScreen].bounds;
	visualEffectView.frame = tutorialBlurView.bounds;

	[self performHighlight];
}

-(void)startTutorial
{
	[self performHighlight];
}

-(void)updateTutorial
{
	[self updateTutorial:nil];
}

-(void)updateHighlights
{
	CGFloat delay = 0;
	if ([self.delegate respondsToSelector:@selector(tutorialPreActionDelay:)]) {
		delay = [self.delegate tutorialPreActionDelay:[self currentIndex]];
	}
	if ([self.delegate respondsToSelector:@selector(tutorialPreHighlightAction:)]) {
		[self.delegate tutorialPreHighlightAction:[self currentIndex]];
	}
	[self performSelector:@selector(performHighlight) withObject:nil afterDelay:delay];
}

-(void)updateTutorial:(UITapGestureRecognizer *)sender
{
	if (sender && [self.delegate respondsToSelector:@selector(tutorialAcceptTapsOnHighlightsOnly:)]) {
		NSArray <UIView *> *viewsToHighlight;
		if ([self.delegate respondsToSelector:@selector(tutorialViewsToHighlight:)]) {
			BOOL acceptTapsOnHighlightsOnly = [self.delegate tutorialAcceptTapsOnHighlightsOnly:[self currentIndex]];
			viewsToHighlight = [self.delegate tutorialViewsToHighlight:[self currentIndex]];
			CGPoint tapLocation = [sender locationInView:sender.view];
			BOOL shouldAcceptTaps = NO;
			if (acceptTapsOnHighlightsOnly && viewsToHighlight && [viewsToHighlight count] > 0) {
				for (UIView *view in viewsToHighlight) {
					CGRect frame = [[self tutorialContainer] convertRect:[view frame] fromView:view.superview];
					if (CGRectContainsPoint(frame, tapLocation)) {
						shouldAcceptTaps = YES;
						break;
					}
				}
			} else {
				shouldAcceptTaps = YES;
			}
			if (!shouldAcceptTaps) {
				return;
			}
		}
	}
	
	BOOL update = YES;
	BOOL wrapUp = NO;
	if ([self.delegate respondsToSelector:@selector(tutorialWaitAfterAction:)]) {
		update = ![self.delegate tutorialWaitAfterAction:[self currentIndex]];
	}
	if (sender) {
		if ([self.delegate respondsToSelector:@selector(tutorialPerformAction:)]) {
			[self.delegate tutorialPerformAction:[self currentIndex]];
		}
		[self increaseIndex];
		if ([self currentIndex] >= [self.delegate tutorialMaxIndex]) {
			update = NO;
			wrapUp = YES;
		}
	} else if ([self currentIndex] >= [self.delegate tutorialMaxIndex]) {
		update = NO;
		wrapUp = YES;
	}
	if (tutorialSkipButton) {
		[tutorialSkipButton removeFromSuperview];
		tutorialSkipButton = nil;
	}
	if (tutorialView.superview != nil) {
		[UIView animateWithDuration:0.3 animations:^{
			tutorialView.alpha = 0;
		} completion:^(BOOL finished) {
			[tutorialView setHidden:YES];
			if (update) {
				[self updateHighlights];
			}
			if (wrapUp) {
				[self wrapUp];
			}
		}];
	} else {
		if (update) {
			[self updateHighlights];
		}
	}
}

-(void)performHighlight
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSArray <UIView *> *viewsToHighlight;
		if ([self.delegate respondsToSelector:@selector(tutorialViewsToHighlight:)]) {
			viewsToHighlight = [self.delegate tutorialViewsToHighlight:[self currentIndex]];
		} else {
			viewsToHighlight = nil;
		}
		[self highlightViews:viewsToHighlight];
	});
}

-(void)tutorialSkip
{
	[self maximizeIndex];
	[self updateTutorial:nil];
}

-(void)updateAnimator
{
	animator.fractionComplete = blurConstant;
}

-(void)wrapUp
{
	[animator stopAnimation:YES];
	animator = nil;
	[tutorialView removeFromSuperview];
	[tutorialWindow removeFromSuperview];
	tutorialWindow = nil;
	tutorialViewController = nil;
	
	[self.delegate tutorialWrapUp];
}

+(BOOL)shouldDisplayTutorial:(id<TNTutorialManagerDelegate>)delegate
{
	NSString *identifier;
	if ([delegate respondsToSelector:@selector(tutorialIdentifier)]) {
		identifier = [delegate tutorialIdentifier];
	} else {
		identifier = NSStringFromClass([delegate class]);
	}
	
	identifier = [NSString stringWithFormat:@"TNTutorial%@", identifier];
	NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:identifier];

	return index < [delegate tutorialMaxIndex];
}

-(NSString *)identifier
{
	NSString *identifier;
	if ([self.delegate respondsToSelector:@selector(tutorialIdentifier)]) {
		identifier = [self.delegate tutorialIdentifier];
	} else {
		identifier = NSStringFromClass([self.delegate class]);
	}
	
	return [NSString stringWithFormat:@"TNTutorial%@", identifier];
}

-(NSInteger)currentIndex
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:[self identifier]];
}

-(void)resetIndex
{
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[self identifier]];
}

-(void)increaseIndex
{
	[[NSUserDefaults standardUserDefaults] setInteger:[self currentIndex]+1 forKey:[self identifier]];
}

-(void)maximizeIndex
{
	[[NSUserDefaults standardUserDefaults] setInteger:[self.delegate tutorialMaxIndex] forKey:[self identifier]];
}

@end
