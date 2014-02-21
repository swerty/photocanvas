//
//  SCViewController.m
//  StampChatDeluxe
//
//  Created by Sean Wertheim on 2/19/14.
//  Copyright (c) 2014 Sean Wertheim. All rights reserved.
//

#import "SCViewController.h"

@interface SCViewController () <UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) NSArray *fontNameArray;
@property (strong, nonatomic) NSArray *fontArray;
@property (nonatomic, assign) BOOL loadedOnce;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGFloat red;
@property (nonatomic, assign) CGFloat green;
@property (nonatomic, assign) CGFloat blue;
@property (nonatomic, assign) CGFloat brush;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) BOOL mouseSwiped;
@property (strong, nonatomic) UIImageView *editingImageView;
@property (strong, nonatomic) UIImage* originalImage;
@property (strong, nonatomic) UIImage* tempImage;
@property (strong, nonatomic) UISwipeGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITableView *fontNameTableView;
@property (strong, nonatomic) IBOutlet UITextField *theTextField;
@property (strong, nonatomic) UIButton *buttonRed;
@property (strong, nonatomic) UIButton *buttonGreen;
@property (strong, nonatomic) UIButton *buttonBlue;
@property (assign, nonatomic) CGPoint oldTouchPoint;
@property (strong, nonatomic) UITableView *fontTableView;
@property (strong, nonatomic) IBOutlet UIButton *stampButton;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImage;
@property (strong, nonatomic) IBOutlet UIImageView *textImage;




@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //initialize an array with the font names (for display in the table view cells)
    self.fontNameArray = [[NSArray alloc] initWithObjects:@"AppleGothic",
                          @"HelveticaNeue-UltraLight",
                          @"MarkerFelt-Thin",
                          @"Georgia",
                          @"Courier",
                          @"Verdana-Bold",
                          nil];
    
    //initiazlize and array of fonts for use in setting the font of the textField
    int fontSize = 20;    UIFont *appleGothic = [UIFont fontWithName:@"AppleGothic" size:fontSize];
    UIFont *ultraLight = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:fontSize];
    UIFont *markerFelt = [UIFont fontWithName:@"MarkerFelt-Thin" size:fontSize];
    UIFont *georgia = [UIFont fontWithName:@"Georgia" size:fontSize];
    UIFont *courier = [UIFont fontWithName:@"Courier" size:fontSize];
    UIFont *verdana = [UIFont fontWithName:@"Verdana-Bold" size:fontSize];
    self.fontArray = [[NSArray alloc]initWithObjects:appleGothic,ultraLight,markerFelt,georgia,courier,verdana, nil];
    
    //add gesture recognizer to the text field
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDidDrag:)];
    [self.theTextField addGestureRecognizer:panGestureRecognizer];
    
    //make the text field and stamp button invisible
    [self.theTextField setHidden:YES];
    [self.stampButton setHidden:YES];
    
    //initialize right swipe gesture recognizer
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeFontTableView)];
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
	// Do any additional setup after loading the view, typically from a nib.
    
    //set default draw color to black
    self.red = 0.0/255.0;
    self.green = 0.0/255.0;
    self.blue = 0.0/255.0;
    self.brush = 6.0;
    self.opacity = 1.0;
    
    //instantiate the picker
    if (!self.loadedOnce) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;//note that we have declared <UIImagePickerControllerDelegate, UINavigationControllerDelegate> above
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;//pick from camera, not saved photos or photo roll
        
        //    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
        //                         UIImagePickerControllerSourceTypeCamera];//allow for video or still
        
        [self presentViewController:picker animated:NO completion:nil];
    }
    
    self.loadedOnce = YES;
    
    //bring text indicator images to front
    [self.view bringSubviewToFront:self.textImage];
    [self.view bringSubviewToFront:self.arrowImage];
    
    [self.view layoutSubviews];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker{//one of the two required delegate methods
    NSLog(@"canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {//the other of the two required delegate methods
    NSLog(@"picked");
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];//was it photo or video?
    
    if ([mediaType isEqualToString:@"public.image"]) {//if it was photo, add the photo
        
        UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //resize the pic so it fits on the screen nicely
        UIGraphicsBeginImageContext( CGSizeMake(320, 480) );
        [image drawInRect:CGRectMake(0,0,320,480)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.editingImageView = [[UIImageView alloc] initWithImage:newImage];
//        self.imageView = [[UIImageView alloc] initWithImage:newImage];
        
//        [self.view insertSubview:self.imageView atIndex:0];
        [self.view insertSubview:self.editingImageView atIndex:0];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    CGSize screenSize = screenBounds.size;
    CGFloat buttonWidth = screenSize.width/3.0;
    CGFloat buttonHeight = screenSize.height - 480.0;
    
    NSLog(@"%f", buttonHeight);
    
    self.buttonRed = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.buttonGreen = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.buttonBlue = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [self.buttonRed addTarget:self action:@selector(redPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonGreen addTarget:self action:@selector(greenPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBlue addTarget:self action:@selector(bluePressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonRed setBackgroundImage:[UIImage imageNamed:@"red2"] forState:UIControlStateNormal];
    [self.buttonGreen setBackgroundImage:[UIImage imageNamed:@"green2"] forState:UIControlStateNormal];
    [self.buttonBlue setBackgroundImage:[UIImage imageNamed:@"blue2"] forState:UIControlStateNormal];
    
    self.buttonRed.frame = CGRectMake(0, 480, buttonWidth, buttonHeight);
    self.buttonGreen.frame = CGRectMake(buttonWidth, 480, buttonWidth, buttonHeight);
    self.buttonBlue.frame = CGRectMake(2.0*buttonWidth, 480, buttonWidth, buttonHeight);
    
    self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(addFontTableView)];
    self.gestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.buttonRed addGestureRecognizer:self.gestureRecognizer];
    [self.buttonGreen addGestureRecognizer:self.gestureRecognizer];
    [self.buttonBlue addGestureRecognizer:self.gestureRecognizer];
    
    [self.view addSubview:self.buttonRed];
    [self.view addSubview:self.buttonGreen];
    [self.view addSubview:self.buttonBlue];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //dismiss the keyboard
    [self.view endEditing:YES];
    
    self.mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    self.lastPoint = [touch locationInView:self.editingImageView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.editingImageView];
    UIGraphicsBeginImageContext(self.editingImageView.frame.size);
    [self.editingImageView.image drawInRect:CGRectMake(0, 0, self.editingImageView.frame.size.width, self.editingImageView.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.editingImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempImage = self.editingImageView.image;
    [self.editingImageView setAlpha:self.opacity];
    UIGraphicsEndImageContext();
    self.lastPoint = currentPoint;
}

- (void) redPressed{
    self.red = 120.0/255.0;
    self.green = 30.0/255.0;
    self.blue = 25.0/255.0;
}

- (void) greenPressed{
    self.red = 65.0/255.0;
    self.green = 145.0/255.0;
    self.blue = 60.0/255.0;
}

- (void) bluePressed{
    self.red = 25.0/255.0;
    self.green = 35.0/255.0;
    self.blue = 70.0/255.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //boilerplate for table views
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //add the appropriate font name to the cell
    cell.textLabel.text = [self.fontNameArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MAX(self.fontArray.count, self.fontNameArray.count);//note that this allows for easily adding more fonts. a better way to set things up might have been an array of dictionaries so you don't have to worry about matching the two arrays as you expand to add more fonts.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //change the font of the text field
    self.theTextField.font = [self.fontArray objectAtIndex:indexPath.row];
}

- (void)addFontTableView{
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    CGSize screenSize = screenBounds.size;
    CGFloat buttonHeight = screenSize.height - 480.0;
    
    self.fontTableView = [[UITableView alloc] initWithFrame:CGRectMake(320, 480, 320, buttonHeight)];
    [self.fontTableView addGestureRecognizer: self.rightSwipeGestureRecognizer];
    [self.view addSubview:self.fontTableView];
    
    [self.fontTableView setDelegate:self];
    [self.fontTableView setDataSource:self];

    [UIView beginAnimations:@"animateTableView" context:nil];
    [UIView setAnimationDuration:0.4];
    [self.fontTableView setFrame:CGRectMake(0, 480, 320, buttonHeight)]; //notice this is ON screen!
    [UIView commitAnimations];
    
    //make the text field and stamp visible
    [self.theTextField setHidden:NO];
    [self.stampButton setHidden:NO];
    
    //make text indicator icons invisible
    [self.arrowImage setHidden:YES];
    [self.textImage setHidden:YES];
}

- (void)removeFontTableView{
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    CGSize screenSize = screenBounds.size;
    CGFloat buttonHeight = screenSize.height - 480.0;
    
    [UIView beginAnimations:@"animateRemoveTableView" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    [self.fontTableView setFrame:CGRectMake(320, 480, 320, buttonHeight)];
    [UIView commitAnimations];
    
    //make the text field and stamp invisible
    [self.theTextField setHidden:YES];
    [self.stampButton setHidden:YES];
    
    //make text indicator icons invisible
    [self.arrowImage setHidden:NO];
    [self.textImage setHidden:NO];
}

- (void) panGestureDidDrag: (UIPanGestureRecognizer *) sender{
    
    //get the touch point from the sender
    CGPoint newTouchPoint = [sender locationInView:self.view];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            //initialize oldTouchPoint for this drag
            self.oldTouchPoint = newTouchPoint;
            break;
        }
        case UIGestureRecognizerStateChanged:{
            //calculate the change in position since last call of panGestureDidDrag (for this drag)
            float dx = newTouchPoint.x - self.oldTouchPoint.x;
            float dy = newTouchPoint.y - self.oldTouchPoint.y;
            
            //move the center of the text field and stamp button by the same amount that the finger moved
            self.theTextField.center = CGPointMake(self.theTextField.center.x + dx, self.theTextField.center.y + dy);
            self.stampButton.center = CGPointMake(self.stampButton.center.x + dx, self.stampButton.center.y + dy);
            
            //set oldTouchPoint
            self.oldTouchPoint = newTouchPoint;
            break;
        }
        default:
            break;
    }
}

- (UIImage *) burnText: (NSString *) text intoImage: (UIImage *) image{
    
    //boilerplate for beginning an image context
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 0.0);
    
    //draw the image in the image context
    CGRect aRectangle = CGRectMake(0,0, image.size.width, image.size.height);
    [image drawInRect:aRectangle];
    
    //draw the text in the image context
    NSDictionary *attributes = @{ NSFontAttributeName: self.theTextField.font,
                                  NSForegroundColorAttributeName: [UIColor blackColor]};
    CGSize size = [self.theTextField.text sizeWithAttributes:attributes];//get size of text
    CGPoint center = self.theTextField.center;//get the center
    CGRect rect = CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);//create the rect for the text
    [text drawInRect:rect withAttributes:attributes];
    
    //get the image to be returned before ending the image context
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
    
    //boilerplate for ending an image context
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (IBAction)textFieldDidEndOnExit:(id)sender {
    [sender resignFirstResponder];    //hide the keyboard
}

- (IBAction)stampButtonPressed:(id)sender {
    //get the new image, with the latest text burned into the latest position
    UIImage *image = [self burnText:self.theTextField.text intoImage:self.editingImageView.image];
    
    //show the new image
    self.editingImageView.image = image;
}

- (IBAction)saveButtonPressed:(id)sender {
    //save the image to the photo roll. note that the middle two parameters could have been left nil if we didn't want to do anything particular upon the save completing.
    UIImageWriteToSavedPhotosAlbum(self.editingImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo{
    //this method is being called once saving to the photoroll is complete.
    NSLog(@"photo saved!");
    
}


@end
