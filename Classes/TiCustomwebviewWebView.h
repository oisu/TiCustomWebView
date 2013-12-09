//
//  TiCustomwebviewWebView.h
//  TiCustomWebView
//
//  Created by oisu on 2013/12/06.
//
//

#import "TiUIView.h"

@interface TiCustomwebviewWebView : TiUIView<UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIWebView* _web;
    NSString* _html;
    float _contentHeight;
    BOOL _horizontalScrollEnabled;
}

-(void)setHtml_:(NSString *)html;
-(void)createView;
-(float)currentContentHeight;

@end
