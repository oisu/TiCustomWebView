//
//  TiCustomwebviewWebView.m
//  TiCustomWebView
//
//  Created by oisu on 2013/12/06.
//
//

#import "TiCustomwebviewWebView.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiUtils.h"

@interface TiCustomwebviewWebView (Private)

-(void)updateTextViewsHtml;

@end

@implementation TiCustomwebviewWebView

#pragma mark -
#pragma mark Initialization and Memory Management

- (id)init {
	if ((self = [super init])) {
	}
	return self;
}

-(void)dealloc
{
    RELEASE_TO_NIL(_html);
    RELEASE_TO_NIL(_web);
	[super dealloc];
}

#pragma mark -
#pragma mark View management

-(UIWebView*)web {
    if (!_web) {
        _web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        _web.delegate = self;
        _web.scrollView.delegate = self;
        
        if (![self isHorizontalScrollEnabled]) {
            
            // swipe left
            UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
            swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
            [_web addGestureRecognizer:swipeLeftGesture];
        
            // swipe right
            UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)];
            swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
            [_web addGestureRecognizer:swipeRightGesture];
        
        
            [_web.scrollView.panGestureRecognizer requireGestureRecognizerToFail:swipeRightGesture];
            [_web.scrollView.panGestureRecognizer requireGestureRecognizerToFail:swipeLeftGesture];
        
            [swipeLeftGesture release];
            [swipeRightGesture release];
        }
        
        [self addSubview:_web];
    }
    return _web;
}
- (BOOL) isHorizontalScrollEnabled {
    // property
    NSDictionary *prop = [self.proxy allProperties];
    return [[prop valueForKey:@"horizontalScrollEnabled"] boolValue];
}

- (void)setHorizontalScrollEnabled_:(id)value
{
}

- (void) handleSwipeLeftGesture:(UISwipeGestureRecognizer *)sender {
    [self.proxy fireEvent:@"swipeLeft"];
}
- (void) handleSwipeRightGesture:(UISwipeGestureRecognizer *)sender {
    [self.proxy fireEvent:@"swipeRight"];
}

-(void)createView
{
    [self web];
}


-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:[self web] positionRect:bounds];
    if (_html != nil) {
        [[self web] loadHTMLString:_html baseURL:nil];
    }
    [super frameSizeChanged:frame bounds:bounds];
}

-(CGFloat)autoHeightForWidth:(CGFloat)value
{
	return _contentHeight;
}

-(CGFloat)autoWidthForWidth:(CGFloat)value
{
	return value;
}


#pragma mark -
#pragma mark Public APIs

-(float)currentContentHeight
{
    return _contentHeight;
}

-(void)setHtml_:(NSString *)html
{
    NSString* head =
    @"<meta name=viewport content=\"user-scalable=0\" />";
    
    NSString* onload =
    @"<br clear=all/><script type=text/javascript>\
    window.onload = function() { window.location.href = 'ready://' + document.body.offsetHeight; };\
    </script>";
    
    RELEASE_TO_NIL(_html);
    _html = [[NSString stringWithFormat:@"%@%@%@", head, html, onload] retain];
    
    [[self web] loadHTMLString:_html baseURL:nil];
}

#pragma mark -
#pragma mark Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        id args = [NSDictionary dictionaryWithObjectsAndKeys: url, @"url", nil];
        [self.proxy fireEvent:@"linkClicked" withObject:args];
        
    } else if (navigationType == UIWebViewNavigationTypeOther) {
        if ([[url scheme] isEqualToString:@"ready"]) {
            _contentHeight = [[url host] floatValue];
            [((TiViewProxy*)[self proxy]) willEnqueue];
            [[((TiViewProxy*)[self proxy]) parent] willChangeSize];
            return NO;
		} else if ([[url scheme] isEqualToString:@"about"]) {
            return YES;
        }
    }
    return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGPoint currentPoint = [scrollView contentOffset];
    id args = [self pointToStringArgs: currentPoint];
    
    [self.proxy fireEvent:@"scrollStart" withObject:args];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentPoint = [scrollView contentOffset];
    id args = [self pointToStringArgs: currentPoint];
    
    [self.proxy fireEvent:@"scroll" withObject:args];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    id currArgs = [self pointToStringArgs: scrollView.contentOffset];
    id veloArgs = [self pointToStringArgs: velocity];
    id willArgs = [self pointToStringArgs: *targetContentOffset];
    
    id args = [NSDictionary dictionaryWithObjectsAndKeys: currArgs, @"current", veloArgs, @"velocity", willArgs, @"willEnd",nil];
    
    [self.proxy fireEvent:@"scrollEnd" withObject:args];
}

- (id)pointToStringArgs:(CGPoint)point
{
    NSString *pointX = [NSString stringWithFormat:@"%f", point.x];
    NSString *pointY = [NSString stringWithFormat:@"%f", point.y];
    id args = [NSDictionary dictionaryWithObjectsAndKeys: pointX, @"x", pointY, @"y", nil];
    return args;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (![self isHorizontalScrollEnabled]) {
        // disable horizontal scroll
        [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

@end

