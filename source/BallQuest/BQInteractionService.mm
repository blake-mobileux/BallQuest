//
//  BQInteractionViewController.m
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import "BQInteractionService.h"

@implementation BQInteractionService

- (id)initWithView:(UIView *)view{
    self = [super init];
    
    if(self){
        _interactionView = view;
        
        // Do any additional setup after loading the view.
        self.motionManager = [[CMMotionManager alloc]init];
        self.motionManager.deviceMotionUpdateInterval = 1.0f / 3000.0f;
    
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:
                             CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
        
        [self updateUserInteractionData];
    }
    
    return self;
}

-(void)updateUserInteractionData{
    self.deviceMotion = self.motionManager.deviceMotion;
    self.attitude = self.deviceMotion.attitude;
    self.rotationRate = self.deviceMotion.rotationRate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
