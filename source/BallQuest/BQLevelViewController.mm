//
//  BQLevelViewController.m
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import "BQLevelViewController.h"

@interface BQLevelViewController ()
@property (weak, nonatomic) IBOutlet UIView *hudView;
@property (strong, nonatomic)BQHudService *hudService;

@property (weak, nonatomic) IBOutlet UIView *interactiveView;
@property (strong, nonatomic)BQInteractionService *interationService;

@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;
@end

@implementation BQLevelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

    - (void)viewDidLoad
    {
        [super viewDidLoad];
        
        self.hudService = [[BQHudService alloc] initWithView:self.hudView];
        self.interationService = [[BQInteractionService alloc] initWithView:self.interactiveView];
        
        self.currentLevel = (BQLevel *)[[BQScene alloc]initWithOBJandMTLFilePath:@"board"
                             hudService:self.hudService andInteractiveService:self.interationService];
        
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!self.context) {
            NSLog(@"Failed to create ES context");
        }
        
        GLKView *view = (GLKView *)self.view;
        view.context = self.context;
        
        view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        view.drawableMultisample = GLKViewDrawableMultisample4X;
        
        self.preferredFramesPerSecond = 30;
        
        [self setupGL];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
    
    - (void)setupGL
    {
        [EAGLContext setCurrentContext:self.context];
        
        [self.currentLevel loadShaders];
        [self.currentLevel loadTextures];
        
        glEnable(GL_DEPTH_TEST);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
        
        [self.currentLevel setupGL];
    }
    
    - (void)tap:(UITapGestureRecognizer *)recognizer {
        if (self.currentLevel.currentCameraIndex == 0){
            [self.currentLevel setCurrentCameraIndex:1];
        }
        else if(self.currentLevel.currentCameraIndex == 1){
            [self.currentLevel setCurrentCameraIndex:2];
        }
        else if(self.currentLevel.currentCameraIndex == 2){
            [self.currentLevel setCurrentCameraIndex:3];
        }
        else if(self.currentLevel.currentCameraIndex == 3){
            [self.currentLevel setCurrentCameraIndex:0];
        }
    }
    
#pragma mark - GLKView and GLKViewController delegate methods
    
    - (void)update
    {
        [self.currentLevel updateWithTimeInterval:self.timeSinceLastUpdate];
    }
    
    - (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
    {
        glClearColor(0.25098f, 0.25098f, 0.25098f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        [self.currentLevel drawScene];
    }
    
    - (void)tearDownGL
    {
        [EAGLContext setCurrentContext:self.context];
        
        [self.currentLevel tearDownGL];
    }
    
    - (void)dealloc
    {
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
    }
    
    - (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        NSLog(@"memory error thrown");
        // Dispose of any resources that can be recreated.
        if ([self isViewLoaded] && ([[self view] window] == nil)) {
            self.view = nil;
            
            [self tearDownGL];
            
            if ([EAGLContext currentContext] == self.context) {
                [EAGLContext setCurrentContext:nil];
            }
            self.context = nil;
        }
    }

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
