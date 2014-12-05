

#import "PullableView.h"

@implementation PullableView

@synthesize handleView;
@synthesize closedCenter;
@synthesize openedCenter;
@synthesize dragRecognizer;
@synthesize tapRecognizer;
@synthesize animate;
@synthesize animationDuration;
//@synthesize pvdelegate;
@synthesize opened;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        animate = YES;
        animationDuration = 0.7;
        
        toggleOnTap = YES;
        
        // Creates the handle view. Subclasses should resize, reposition and style this view
        handleView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 40, frame.size.width, 40)];
        [self addSubview:handleView];
        
        dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        dragRecognizer.minimumNumberOfTouches = 1;
        dragRecognizer.maximumNumberOfTouches = 1;
        
        [handleView addGestureRecognizer:dragRecognizer];
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        
        [handleView addGestureRecognizer:tapRecognizer];
        
        opened = NO;
    }
    return self;
}

- (void)handleDrag:(UIPanGestureRecognizer *)sender {
    //printf("I was dragged\n");
    
    if ([sender state] == UIGestureRecognizerStateBegan) {
        
        startPos = self.center;
        
        // Determines if the view can be pulled in the x or y axis
        verticalAxis = closedCenter.x == openedCenter.x;
        
        // Finds the minimum and maximum points in the axis
        if (verticalAxis) {
            minPos = closedCenter.y < openedCenter.y ? closedCenter : openedCenter;
            maxPos = closedCenter.y > openedCenter.y ? closedCenter : openedCenter;
        } else {
            minPos = closedCenter.x < openedCenter.x ? closedCenter : openedCenter;
            maxPos = closedCenter.x > openedCenter.x ? closedCenter : openedCenter;
        }
        
    } else if ([sender state] == UIGestureRecognizerStateChanged) {
                
        CGPoint translate = [sender translationInView:self.superview];
        
        CGPoint newPos;
        
        // Moves the view, keeping it constrained between openedCenter and closedCenter
        if (verticalAxis) {
            
            newPos = CGPointMake(startPos.x, startPos.y + translate.y);
            
            if (newPos.y < minPos.y) {
                newPos.y = minPos.y;
                translate = CGPointMake(0, newPos.y - startPos.y);
            }
            
            if (newPos.y > maxPos.y) {
                newPos.y = maxPos.y;
                translate = CGPointMake(0, newPos.y - startPos.y);
            }
        } else {
            
            newPos = CGPointMake(startPos.x + translate.x, startPos.y);
            
            if (newPos.x < minPos.x) {
                newPos.x = minPos.x;
                translate = CGPointMake(newPos.x - startPos.x, 0);
            }
            
            if (newPos.x > maxPos.x) {
                newPos.x = maxPos.x;
                translate = CGPointMake(newPos.x - startPos.x, 0);
            }
        }
        
        [sender setTranslation:translate inView:self.superview];
        
        self.center = newPos;
        
    } else if ([sender state] == UIGestureRecognizerStateEnded) {
        
        // Gets the velocity of the gesture in the axis, so it can be
        // determined to which endpoint the state should be set.
        
        CGPoint vectorVelocity = [sender velocityInView:self.superview];
        CGFloat axisVelocity = verticalAxis ? vectorVelocity.y : vectorVelocity.x;
        
        CGPoint target = axisVelocity < 0 ? minPos : maxPos;
        BOOL op = CGPointEqualToPoint(target, openedCenter);
        
        [self setOpened:[NSNumber numberWithBool:op] animated:[NSNumber numberWithBool:animate]];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateEnded) {
        [self setOpened:[NSNumber numberWithBool:opened] animated:[NSNumber numberWithBool:animate]];
    }
}

- (void)setToggleOnTap:(BOOL)tap {
    toggleOnTap = tap;
    tapRecognizer.enabled = tap;
}

- (BOOL)toggleOnTap {
    return toggleOnTap;
}

- (void)setOpened:(NSNumber *)op1 animated:(NSNumber *)anim1 {
    bool op = [op1 boolValue];
    bool anim = [anim1 boolValue];
    opened = op;
    if (op) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BAR-OPEN" object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BAR-CLOSE" object:self];

    }
    
    if (anim) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
       /* [UIView animateWithDuration:0.5 animations:^{
            self.center = opened ? openedCenter : closedCenter;
            dragRecognizer.enabled = NO;
            tapRecognizer.enabled = NO;
        }];*/
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    }
    
    self.center = opened ? openedCenter : closedCenter;
    
    if (anim) {
        
        dragRecognizer.enabled = NO;
        tapRecognizer.enabled = NO;
        
        [UIView commitAnimations];
        
    } else {
        
        if ([pvdelegate respondsToSelector:@selector(pullableView:didChangeState:)]) {
            [pvdelegate pullableView:self didChangeState:opened];
        }
    }
}

-(void)finishMenuItemAdded{
    if (opened) return;
    
    [UIView animateWithDuration: .5
                          delay: 0
                        options: (UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction )
                     animations:^{ self.center = CGPointMake(160, self.frame.size.height + 200); }
                     completion:^(BOOL finished) { }
     ];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
}

-(void)menuItemAdded{
    if (opened) return;
    
    CGPoint newCenter = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 10 * 15);
    
    [UIView animateWithDuration: .5
                          delay: 0
                        options: (UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat)
                     animations:^{
                         [UIView setAnimationRepeatCount:3.5];
                         self.center = newCenter; }
                     completion:^(BOOL finished) { [self finishMenuItemAdded]; }
     ];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if (finished) {
        // Restores interaction after the animation is over
        dragRecognizer.enabled = YES;
        tapRecognizer.enabled = toggleOnTap;
        
        if ([pvdelegate respondsToSelector:@selector(pullableView:didChangeState:)]) {
            [pvdelegate pullableView:self didChangeState:opened];
        }
    }
}

@end
