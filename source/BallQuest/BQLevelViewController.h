//
//  BQLevelViewController.h
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "glm.hpp"
#import "ext.hpp"
#import "BQLevel.h"
#import "BQGeometry.h"
#import "BQHudService.h"
#import "BQInteractionService.h"
#import "BQGameConstants.h"

@interface BQLevelViewController : GLKViewController
<GLKViewDelegate>

@property (strong, nonatomic)BQLevel *currentLevel;
@end
