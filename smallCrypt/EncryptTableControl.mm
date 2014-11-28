//
//  EncryptTableControl.m
//  smallCrypt
//
//  Created by Arnaud Crowther on 11/15/13.
//  Copyright (c) 2013 Arnaud Crowther. All rights reserved.
//

#import "EncryptTableControl.h"
#import "QREncoder.h"
#import "DataMatrix.h"



@interface EncryptTableControl ()

@end

@implementation EncryptTableControl

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:@"smallCryptQRbool"]) {
        [defaults setValue:@"YES" forKey:@"smallCryptQRbool"];}
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];//change back button text
    barButton.title = @"Encrypt";//must be in root controller
    self.navigationItem.backBarButtonItem = barButton;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newBG.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    
    UIBarButtonItem *previous = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"prev.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(prevKeyboard)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(nextKeyboard)];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
    
    NSArray *itemsArray = [NSArray arrayWithObjects:previous, space, next, flexButton, doneButton, nil];
    
    [toolbar setItems:itemsArray];
    
    [txtMessage setInputAccessoryView:toolbar];
    [txtCipher setInputAccessoryView:toolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    aTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(count:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [aTimer invalidate];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (IBAction)count:(id)sender {//get character count live
    
    
    NSString *subWord = [NSString stringWithString:txtMessage.text];//these two are used for length
    NSString *subKey = [NSString stringWithString:txtCipher.text];
    
    if (subWord.length >= 1) {//if word is greater then or equal to one, word gets green
        gRingWord.hidden = NO;
        dowork.enabled = YES;//dowork is enabled
    }
    if (subKey.length <= subWord.length) {//if key is less then or equal to word, key gets green
        gRingKey.hidden = NO;
        rRingKey.hidden = YES;
        dowork.enabled = YES;//dowork is enabled
    }
    if (subKey.length > subWord.length) {//if key is greater then word, key gets red
        gRingKey.hidden = YES;
        rRingKey.hidden = NO;
        dowork.enabled = NO;//dowork is disabled
    }
    if (subKey.length == 0) {//if key is equal to zero, key gets red
        gRingKey.hidden = YES;
        rRingKey.hidden = NO;
        dowork.enabled = NO;//dowork is disabled
    }
    if (subKey.length == 0 && subWord.length == 0) {//if they are both equal to zero, both get none
        gRingWord.hidden = YES;
        rRingWord.hidden = YES;
        gRingKey.hidden = YES;
        rRingKey.hidden = YES;
        dowork.enabled = NO;//dowork is disabled
    }
    if (![textView.text isEqual: @""]) {//if output isnt blank, enable clear and send
        dosend.enabled = YES;
    }
    if ([textView.text isEqual: @""]) {//if output is blank, disable clear and send
        dosend.enabled = NO;
    }
    //this is messy and needs to be integrated into above statements. RECURSION MOTHERFUCKER
    if ([txtMessage.text isEqual: @""]) {//if word is empty, disable clear
        docopy.enabled = NO;
    }
    if ([txtMessage.text isEqual: @""]) {//if key is empty, disable clear
        docopy.enabled = NO;
    }
    if (![txtMessage.text isEqual: @""] || ![txtCipher.text isEqual: @""]) {//if key OR word arent empty, enable clear
        docopy.enabled = YES;
    }
    if (![textView.text isEqualToString:@""]) {
        [smallXbutton setHidden:NO];
    }
    else if ([textView.text isEqualToString:@""]) {
        [smallXbutton setHidden:YES];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {//used for email
    
    [self dismissViewControllerAnimated:YES completion:NULL];// Close the Mail Interface
}
- (IBAction)mail:(id)sender {//send button calls this for email
    
    NSString *emailTitle = @"New message from smallCrypt";// Email Subject
    NSString *messageBody = [NSString stringWithFormat:@"Encrypted message:<br /><br />%@",globalWord];// Email Content
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults valueForKey:@"smallCryptQRbool"] isEqualToString:@"YES"]) {
        UIImage *QRimage = [[UIImage alloc] init];
        QRimage = [self generateQR:textView.text];//make the qr and add it to the message if YES
        [mc addAttachmentData:UIImageJPEGRepresentation(QRimage, 1) mimeType:@"image/jpeg" fileName:@"MyFile.jpeg"];
    }
    [self presentViewController:mc animated:YES completion:NULL];// Present mail view controller on screen
    
}
- (IBAction)crunch:(id)sender {//do calculations
    
    NSMutableString *subWord = [[NSMutableString alloc] initWithString:[NSString stringWithString:txtMessage.text]];
    NSMutableString *subKey = [[NSMutableString alloc] initWithString:[NSString stringWithString:txtCipher.text]];
    
    if ([subKey length] > [subWord length] /*|| [subKey length]<[subWord length]*/) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid size" message:@"The key must not be longer than the message." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        
        NSInteger diff = 0;
        NSMutableString *pad = [[NSMutableString alloc] initWithString:@""];
        NSString *lastChar;
        
        for (int y=0;y<[subKey length];y++){//this gets the last character of the key
            NSInteger x = [subKey length];//changed from int to nsint
            lastChar = [subKey substringWithRange:NSMakeRange(x-1, 1)];
        }
        
        if ([subKey length]<[subWord length]) {//pad needs key multiplied to fill space
            diff = [subWord length]-[subKey length];
            for (int x=0;x<diff;x++) {
                [pad appendString: [NSString stringWithFormat:@"%@",lastChar]];
            }
            [subKey appendString:[NSString stringWithFormat:@"%@",pad]];//add pad to the subword
        }
        
        NSMutableArray *wordArr = [NSMutableArray array];//convert word string to array
        NSString *word = [subWord uppercaseString];
        for (int i = 0; i < [word length]; i++) {
            NSString *ch = [word substringWithRange:NSMakeRange(i, 1)];
            [wordArr addObject:ch];
        }
        NSMutableArray *keyArr = [NSMutableArray array];//convert key string to array
        NSString *key = [subKey uppercaseString];
        for (int i = 0; i < [key length]; i++) {
            NSString *ch = [key substringWithRange:NSMakeRange(i, 1)];
            [keyArr addObject:ch];
        }
        NSMutableArray *wordArrInt = [NSMutableArray array];//convert word to ints
        for(int x=0;x<[wordArr count];x++){
            if     ([wordArr[x]  isEqual: @"A"]){[wordArrInt addObject:@"1"];}
            else if([wordArr[x]  isEqual: @"B"]){[wordArrInt addObject:@"2"];}
            else if([wordArr[x]  isEqual: @"C"]){[wordArrInt addObject:@"3"];}
            else if([wordArr[x]  isEqual: @"D"]){[wordArrInt addObject:@"4"];}
            else if([wordArr[x]  isEqual: @"E"]){[wordArrInt addObject:@"5"];}
            else if([wordArr[x]  isEqual: @"F"]){[wordArrInt addObject:@"6"];}
            else if([wordArr[x]  isEqual: @"G"]){[wordArrInt addObject:@"7"];}
            else if([wordArr[x]  isEqual: @"H"]){[wordArrInt addObject:@"8"];}
            else if([wordArr[x]  isEqual: @"I"]){[wordArrInt addObject:@"9"];}
            else if([wordArr[x]  isEqual: @"J"]){[wordArrInt addObject:@"10"];}
            else if([wordArr[x]  isEqual: @"K"]){[wordArrInt addObject:@"11"];}
            else if([wordArr[x]  isEqual: @"L"]){[wordArrInt addObject:@"12"];}
            else if([wordArr[x]  isEqual: @"M"]){[wordArrInt addObject:@"13"];}
            else if([wordArr[x]  isEqual: @"N"]){[wordArrInt addObject:@"14"];}
            else if([wordArr[x]  isEqual: @"O"]){[wordArrInt addObject:@"15"];}
            else if([wordArr[x]  isEqual: @"P"]){[wordArrInt addObject:@"16"];}
            else if([wordArr[x]  isEqual: @"Q"]){[wordArrInt addObject:@"17"];}
            else if([wordArr[x]  isEqual: @"R"]){[wordArrInt addObject:@"18"];}
            else if([wordArr[x]  isEqual: @"S"]){[wordArrInt addObject:@"19"];}
            else if([wordArr[x]  isEqual: @"T"]){[wordArrInt addObject:@"20"];}
            else if([wordArr[x]  isEqual: @"U"]){[wordArrInt addObject:@"21"];}
            else if([wordArr[x]  isEqual: @"V"]){[wordArrInt addObject:@"22"];}
            else if([wordArr[x]  isEqual: @"W"]){[wordArrInt addObject:@"23"];}
            else if([wordArr[x]  isEqual: @"X"]){[wordArrInt addObject:@"24"];}
            else if([wordArr[x]  isEqual: @"Y"]){[wordArrInt addObject:@"25"];}
            else if([wordArr[x]  isEqual: @"Z"]){[wordArrInt addObject:@"0"];}
        }
        NSMutableArray *keyArrInt = [NSMutableArray array];//convert key to ints
        for(int x=0;x<[keyArr count];x++){
            if     ([keyArr[x]  isEqual: @"A"]){[keyArrInt addObject:@"1"];}
            else if([keyArr[x]  isEqual: @"B"]){[keyArrInt addObject:@"2"];}
            else if([keyArr[x]  isEqual: @"C"]){[keyArrInt addObject:@"3"];}
            else if([keyArr[x]  isEqual: @"D"]){[keyArrInt addObject:@"4"];}
            else if([keyArr[x]  isEqual: @"E"]){[keyArrInt addObject:@"5"];}
            else if([keyArr[x]  isEqual: @"F"]){[keyArrInt addObject:@"6"];}
            else if([keyArr[x]  isEqual: @"G"]){[keyArrInt addObject:@"7"];}
            else if([keyArr[x]  isEqual: @"H"]){[keyArrInt addObject:@"8"];}
            else if([keyArr[x]  isEqual: @"I"]){[keyArrInt addObject:@"9"];}
            else if([keyArr[x]  isEqual: @"J"]){[keyArrInt addObject:@"10"];}
            else if([keyArr[x]  isEqual: @"K"]){[keyArrInt addObject:@"11"];}
            else if([keyArr[x]  isEqual: @"L"]){[keyArrInt addObject:@"12"];}
            else if([keyArr[x]  isEqual: @"M"]){[keyArrInt addObject:@"13"];}
            else if([keyArr[x]  isEqual: @"N"]){[keyArrInt addObject:@"14"];}
            else if([keyArr[x]  isEqual: @"O"]){[keyArrInt addObject:@"15"];}
            else if([keyArr[x]  isEqual: @"P"]){[keyArrInt addObject:@"16"];}
            else if([keyArr[x]  isEqual: @"Q"]){[keyArrInt addObject:@"17"];}
            else if([keyArr[x]  isEqual: @"R"]){[keyArrInt addObject:@"18"];}
            else if([keyArr[x]  isEqual: @"S"]){[keyArrInt addObject:@"19"];}
            else if([keyArr[x]  isEqual: @"T"]){[keyArrInt addObject:@"20"];}
            else if([keyArr[x]  isEqual: @"U"]){[keyArrInt addObject:@"21"];}
            else if([keyArr[x]  isEqual: @"V"]){[keyArrInt addObject:@"22"];}
            else if([keyArr[x]  isEqual: @"W"]){[keyArrInt addObject:@"23"];}
            else if([keyArr[x]  isEqual: @"X"]){[keyArrInt addObject:@"24"];}
            else if([keyArr[x]  isEqual: @"Y"]){[keyArrInt addObject:@"25"];}
            else if([keyArr[x]  isEqual: @"Z"]){[keyArrInt addObject:@"0"];}
        }
        int sums=0;
        NSMutableArray *sum = [NSMutableArray array];
        for(int x=0;x<[wordArrInt count];x++){
            sums = ([keyArrInt[x] intValue]+[wordArrInt[x] intValue]) %26;
            sum[x] = [NSString stringWithFormat:@"%d",sums];
        }
        NSMutableArray *sumArr = [NSMutableArray array];//convert key to ints
        for(int x=0;x<[sum count];x++){
            if     ([sum[x]  isEqual: @"1"]){[sumArr addObject:@"A"];}
            else if([sum[x]  isEqual: @"2"]){[sumArr addObject:@"B"];}
            else if([sum[x]  isEqual: @"3"]){[sumArr addObject:@"C"];}
            else if([sum[x]  isEqual: @"4"]){[sumArr addObject:@"D"];}
            else if([sum[x]  isEqual: @"5"]){[sumArr addObject:@"E"];}
            else if([sum[x]  isEqual: @"6"]){[sumArr addObject:@"F"];}
            else if([sum[x]  isEqual: @"7"]){[sumArr addObject:@"G"];}
            else if([sum[x]  isEqual: @"8"]){[sumArr addObject:@"H"];}
            else if([sum[x]  isEqual: @"9"]){[sumArr addObject:@"I"];}
            else if([sum[x]  isEqual: @"10"]){[sumArr addObject:@"J"];}
            else if([sum[x]  isEqual: @"11"]){[sumArr addObject:@"K"];}
            else if([sum[x]  isEqual: @"12"]){[sumArr addObject:@"L"];}
            else if([sum[x]  isEqual: @"13"]){[sumArr addObject:@"M"];}
            else if([sum[x]  isEqual: @"14"]){[sumArr addObject:@"N"];}
            else if([sum[x]  isEqual: @"15"]){[sumArr addObject:@"O"];}
            else if([sum[x]  isEqual: @"16"]){[sumArr addObject:@"P"];}
            else if([sum[x]  isEqual: @"17"]){[sumArr addObject:@"Q"];}
            else if([sum[x]  isEqual: @"18"]){[sumArr addObject:@"R"];}
            else if([sum[x]  isEqual: @"19"]){[sumArr addObject:@"S"];}
            else if([sum[x]  isEqual: @"20"]){[sumArr addObject:@"T"];}
            else if([sum[x]  isEqual: @"21"]){[sumArr addObject:@"U"];}
            else if([sum[x]  isEqual: @"22"]){[sumArr addObject:@"V"];}
            else if([sum[x]  isEqual: @"23"]){[sumArr addObject:@"W"];}
            else if([sum[x]  isEqual: @"24"]){[sumArr addObject:@"X"];}
            else if([sum[x]  isEqual: @"25"]){[sumArr addObject:@"Y"];}
            else if([sum[x]  isEqual: @"0"]){[sumArr addObject:@"Z"];}
            
            
            NSMutableString* alphaSumString = [NSMutableString string];//create string for print
            for(int x=0;x<[sumArr count];x++){
                [alphaSumString appendString:[NSString stringWithFormat:@"%@",[sumArr objectAtIndex:x]]];
            }
            
            textView.text = [NSString stringWithFormat:(@"%@"),alphaSumString];//print to textview
            globalWord = textView.text;//send results to global variable for email
            
            [txtMessage resignFirstResponder];//close keyboards
            [txtCipher resignFirstResponder];
        }
    }
}

- (void)resignKeyboard
{
    [txtMessage resignFirstResponder];
    [txtCipher resignFirstResponder];
}

- (void)prevKeyboard
{
    if (txtMessage.isFirstResponder) {
        [txtMessage resignFirstResponder];
    }
    else
        [txtMessage becomeFirstResponder];
    
}

- (void)nextKeyboard
{
    if (txtMessage.isFirstResponder) {
        [txtCipher becomeFirstResponder];
    }
    else
        [txtCipher resignFirstResponder];
}
- (UIImage *)generateQR: (NSString *)message
{
    int qrcodeImageDimension = 300;
    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:message];
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    
    return qrcodeImage;
}

- (IBAction)copy:(id)sender {
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString: textView.text];
}

- (IBAction)qrButton:(id)sender
{
    UIBarButtonItem * button = ((UIBarButtonItem*)sender);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults valueForKey:@"smallCryptQRbool"] isEqualToString:@"YES"]) {
        [defaults setValue:@"NO" forKey:@"smallCryptQRbool"];
        [button setTintColor:[UIColor lightGrayColor]];
    }
    else if ([[defaults valueForKey:@"smallCryptQRbool"] isEqualToString:@"NO"]) {
        [defaults setValue:@"YES" forKey:@"smallCryptQRbool"];
        [button setTintColor:[UIColor colorWithRed:0.0f/255 green:122.0f/255 blue:255.0f/255 alpha:1.0f]];
    }
}

- (IBAction)clearTextView:(id)sender
{
    textView.text = nil;
}

@end
