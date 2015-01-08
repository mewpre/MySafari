//
//  ViewController.m
//  MySafari
//
//  Created by Yi-Chin Sun on 1/7/15.
//  Copyright (c) 2015 Yi-Chin Sun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationBarTitle;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonBarConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *URLBarConstraint;

@property CGFloat yPositionIndex;
@property CGFloat originalButtonBarConstant;
@property CGFloat originalURLBarConstant;

@end

@implementation ViewController

#pragma mark - View Loading Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNewWebPage:@"http://google.com"];
    self.navigationBarTitle.title =[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.webView.scrollView.scrollEnabled = YES;
    self.webView.scrollView.delegate = self;
    self.urlTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.originalButtonBarConstant = self.buttonBarConstraint.constant;
    self.originalURLBarConstant = self.URLBarConstraint.constant;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.spinner startAnimating];
    self.spinner.hidden = false;
//    self.navigationBarTitle.title =[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.spinner stopAnimating];
    self.spinner.hidden = true;
    [self updateButtons];
    NSURL *newURL = webView.request.mainDocumentURL;
    self.urlTextField.text = [newURL absoluteString];
    self.navigationBarTitle.title =[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *errorAlertView = [[UIAlertView alloc]init];
    errorAlertView.delegate = self;
    errorAlertView.title = @"Loading Failed";
    errorAlertView.message = error.localizedDescription;
    [errorAlertView addButtonWithTitle: @"Dismiss"];
    [errorAlertView addButtonWithTitle: @"Go Home"];
    [errorAlertView show];
    self.spinner.hidden = true;
    [self.spinner stopAnimating];
}

#pragma mark - Alert View Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) //if "Go Home" button is pressed
    {
        [self loadNewWebPage:@"http://google.com"];
    }
    self.urlTextField.text = @"";

}

#pragma mark - Text Field Method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text hasPrefix:@"http://"])
    {
        textField.text = [NSString stringWithFormat:@"http://%@", textField.text];
    }
    [self loadNewWebPage:textField.text];
    [textField resignFirstResponder];
    return true;
}

#pragma mark - Scrolling Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //When scrolling down
    if (self.yPositionIndex < scrollView.contentOffset.y)
    {
        //If
        if (self.buttonBarConstraint.constant > -40)
        {
            self.buttonBarConstraint.constant = self.buttonBarConstraint.constant -8;
        }
         if (self.URLBarConstraint.constant > -33)
        {
            self.URLBarConstraint.constant = self.URLBarConstraint.constant -8;
        }
    }
    //When scrolling up
    else
    {
        //
        if (self.buttonBarConstraint.constant < self.originalButtonBarConstant)
        {
            self.buttonBarConstraint.constant = self.buttonBarConstraint.constant +8;
        }
        if (self.URLBarConstraint.constant < self.originalURLBarConstant)
        {
            self.URLBarConstraint.constant = self.URLBarConstraint.constant +8;
        }
    }
    self.yPositionIndex = scrollView.contentOffset.y;

}

#pragma mark - Button IBActions
- (IBAction)onBackButtonPressed:(id)sender
{
    [self.webView goBack];
}
- (IBAction)onForwardButtonPressed:(id)sender
{
    [self.webView goForward];
}
- (IBAction)onStopLoadingButtonPressed:(id)sender
{
    [self.webView stopLoading];
    [self.spinner stopAnimating];
    self.spinner.hidden = true;
    [self updateButtons];
}

- (IBAction)onReloadButtonPressed:(id)sender
{
    [self.webView reload];
}

- (IBAction)onUpdatesButtonPressed:(id)sender
{
    UIAlertView *updatesAlertView = [[UIAlertView alloc]init];
    updatesAlertView.delegate = self;
    updatesAlertView.title = @"Coming Soon!";
    [updatesAlertView addButtonWithTitle: @"OK"];
    [updatesAlertView show];
}

#pragma mark - Helper Methods
//Helper Method - loads new web page
- (void)loadNewWebPage:(NSString *)urlString
{
    NSString *addressString = urlString;
    NSURL *addressURL = [NSURL URLWithString:addressString];
    NSURLRequest *addressRequest = [NSURLRequest requestWithURL:addressURL];
    [self.webView loadRequest:addressRequest];
}

//Helper Method - updates the states of navigation buttons
-(void)updateButtons
{
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
}


@end
