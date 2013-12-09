//
//  TiCustomwebviewWebViewProxy.m
//  TiCustomWebView
//
//  Created by oisu on 2013/12/06.
//
//

#import "TiCustomwebviewWebViewProxy.h"
#import "TiUtils.h"

@implementation TiCustomwebviewWebViewProxy

-(void)viewDidAttach
{
    [(TiCustomwebviewWebView*)[self view] createView];
}

// The following is to support the new layout in TiSDK
-(CGFloat)contentHeightForWidth:(CGFloat)value
{
    float height = [((TiCustomwebviewWebView*)[self view]) currentContentHeight];
    if (height > 1) {
        return height;
    }
	return 1;
}

// The following is to support the old layout in prior versions of TiSDK
-(CGFloat)autoHeightForWidth:(CGFloat)suggestedWidth
{
    return [self contentHeightForWidth:suggestedWidth];
}

@end
