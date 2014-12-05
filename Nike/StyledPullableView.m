
#import "StyledPullableView.h"
#import "BarcodeScannerViewController.h"

@implementation StyledPullableView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linen"]];
        back.frame = self.frame;
        [self addSubview:back];
    }
    return self;
}

@end
