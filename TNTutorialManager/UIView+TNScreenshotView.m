//
//  UIView+TNScreenshotView.m
//  TNTutorialManagerSample
//
//  Created by Tawa Nicolas on 27/6/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "UIView+TNScreenshotView.h"

@implementation UIView (TNScreenshotView)

-(UIImage *)toImage
{
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
	
	[self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

@end
