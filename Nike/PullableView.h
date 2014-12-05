
#import <UIKit/UIKit.h>

@class PullableView;

@protocol PullableViewDelegate <NSObject>

- (void)pullableView:(PullableView *)pView didChangeState:(BOOL)opened;

@end

@interface PullableView : UIView {
    
    CGPoint closedCenter;
    CGPoint openedCenter;
    
    UIView *handleView;
    UIDynamicAnimator *animator;
    UIPanGestureRecognizer *dragRecognizer;
    UITapGestureRecognizer *tapRecognizer;
    
    CGPoint startPos;
    CGPoint minPos;
    CGPoint maxPos;
    
    BOOL opened;
    BOOL verticalAxis;
    
    BOOL toggleOnTap;
    
    BOOL animate;
    float animationDuration;
    
    id<PullableViewDelegate> pvdelegate;
}

@property (nonatomic, strong) UIDynamicAnimator *animator;

/**
 The view that is used as the handle for the PullableView. You
 can style it, add subviews or set its frame at will.
 */
@property (nonatomic,readonly) UIView *handleView;

/**
 The point that defines the center of the view when in its closed
 state. You must set this before using the PullableView.
 */
@property (readwrite,assign) CGPoint closedCenter;

/**
 The point that defines the center of the view when in its opened
 state. You must set this before using the PullableView.
 */
@property (readwrite,assign) CGPoint openedCenter;

/**
 Gesture recognizer responsible for the dragging of the handle view.
 It is exposed as a property so you can change the number of touches
 or created dependencies to other recognizers in your views.
 */
@property (nonatomic,readonly) UIPanGestureRecognizer *dragRecognizer;

/**
 Gesture recognizer responsible for handling tapping of the handle view.
 It is exposed as a property so you can change the number of touches
 or created dependencies to other recognizers in your views.
 */
@property (nonatomic,readonly) UITapGestureRecognizer *tapRecognizer;

/**
 If set to YES, tapping the handle view will toggle the PullableView.
 Default value is YES.
 */
@property (readwrite,assign) BOOL toggleOnTap;

/**
 If set to YES, the opening or closing of the PullableView will
 be animated. Default value is YES.
 */
@property (readwrite,assign) BOOL animate;

/**
 Duration of the opening/closing animation, if enabled. Default
 value is 0.2.
 */
@property (readwrite,assign) float animationDuration;

/**
 Delegate that will be notified when the PullableView changes state.
 If the view is set to animate transitions, the delegate will be
 called only when the animation finishes.
 */
@property (readwrite,assign) id<PullableViewDelegate> delegate;

/**
 The current state of the `PullableView`.
 */
@property (readonly, assign) BOOL opened;

//handles dragging action
- (void)handleDrag:(UIPanGestureRecognizer *)sender;

//handles tapping action
- (void)handleTap:(UITapGestureRecognizer *)sender;

- (void)setToggleOnTap:(BOOL)tap;
/**
 Toggles the state of the PullableView
 @param op New state of the view
 @param anim Flag indicating if the transition should be animated
 */
- (void)setOpened:(NSNumber *)op1 animated:(NSNumber *)anim1;

/** Called to make bounce when menu item added 
 */
- (void)menuItemAdded;


@end
