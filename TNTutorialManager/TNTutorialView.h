//
//  TNTutorialView.h
//  HelloMetal
//
//  Created by Tawa Nicolas on 29/6/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#define TN_DISABLE_METAL YES

#import <UIKit/UIKit.h>

@interface TNTutorialView : UIView

@property (copy, nonatomic) UIImage *overlay;
@property (copy, nonatomic) UIImage *image;

@property (assign, nonatomic) NSUInteger animationIndex;

+(instancetype)instance;

@end
