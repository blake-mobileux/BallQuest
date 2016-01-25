//
//  BQInteractionService.h
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface BQInteractionService : UIViewController
@property (strong, nonatomic)UIView *interactionView;
@property (strong, nonatomic)CMMotionManager *motionManager;
@property (strong, nonatomic)CMAttitude *attitude;
@property (nonatomic)CMRotationRate rotationRate;
@property (strong, nonatomic)CMDeviceMotion *deviceMotion;
@property (strong, nonatomic)NSOperationQueue *operationQueue;

- (id)initWithView:(UIView *)view;

-(void)updateUserInteractionData;
@end
