//
//  BQHudService.m
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import "BQHudService.h"

@interface BQHudService ()
@end

@implementation BQHudService

- (id)initWithView:(UIView *)view{
    self = [super init];
    
    if(self){
        _hudView = view;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
