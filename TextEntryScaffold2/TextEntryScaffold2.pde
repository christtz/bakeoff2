import java.util.Arrays;
import java.util.Collections;
import java.lang.Math;

String[] phrases; //contains all of the phrases
int totalTrialNum = 4; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 294; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
                                      //http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

String[] alphabet = {"abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz", "<", "done"};
float keyHeight = sizeOfInputArea/6;
float keyWidth = sizeOfInputArea/4;
float keyTop = keyHeight*2;
boolean letterClicked = false;
int currentBoxRow = -1;
int currentBoxCol = -1;  
// For the Cursor
int blinkTime;
float cursorPos;
int cursorIdx = 0; 
boolean blinkOn;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases
    
  orientation(PORTRAIT); //can also be LANDSCAPE -- sets orientation on android device
  size(1000, 1000); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
  
  // Cursor Setup
  strokeWeight(2);
  blinkTime = millis();
  blinkOn = true;
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(0); //clear background

 // image(watch,-200,200);
  fill(100);
  rect(200, 200, sizeOfInputArea, sizeOfInputArea); //input area should be 2" by 2"

  if (finishTime!=0)
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(255);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered: " + currentTyped, 70, 140); //draw what the user has entered thus far 
    if (blinkOn) {
      cursorPos = 70 + textWidth("Entered: " + currentTyped.substring(0, cursorIdx));
      stroke(255);
      line(cursorPos, 125, cursorPos, 140);
    }
    if (millis() - 500 > blinkTime) {
      blinkTime = millis();
      blinkOn = !blinkOn;
    }
    //my draw code
    textAlign(CENTER);
    
    //Draw the letters, left arrow, and done buttons
    for (int i = 0; i < 10; i++) {
      int col = i % 3;
      int row = i / 3;
      float xco = 200+col*keyWidth;
      float yco = 200+keyTop+(row*keyHeight);
      if (letterClicked)
        fill(102, 102, 102, 0.8);
      else
        fill(102);
      stroke(0);
      rect(xco, yco, keyWidth, keyHeight); //draw left red button
      noStroke();
      if (letterClicked)
        fill(255, 255, 255);
      else
        fill(0, 0, 0);
      textAlign(CENTER);
      text(alphabet[i], xco+keyWidth/2, yco+keyHeight/2+10);
    }
    
    //Draw backspace
    fill(255, 255, 255);
    stroke(0);
    rect(200+3*keyWidth, 200+keyTop, keyWidth, 2*keyHeight); 
    noStroke();
    fill(0, 0, 0);
    textAlign(CENTER);
    text("del", 200+3*keyWidth+keyWidth/2, 200+keyTop+keyHeight+10); 
    
    //Draw space
    fill(255, 255, 255);
    stroke(0);
    rect(200+keyWidth, 200+keyTop+(3*keyHeight), 3*keyWidth, keyHeight); 
    noStroke();
    fill(0, 0, 0);
    textAlign(CENTER);
    text("space", 200+2.5*keyWidth, 200+keyTop+3.5*keyHeight+10); 

    //Draw forward arrow
    fill(255, 255, 255);
    stroke(0);
    rect(200+3*keyWidth, 200+keyTop+(2*keyHeight), keyWidth, keyHeight); 
    noStroke();
    fill(0, 0, 0);
    textAlign(CENTER);
    text(">", 200+3.5*keyWidth, 200+keyTop+(2.5*keyHeight)+10); 
    textSize(50);
    text("" + currentLetter, 200+sizeOfInputArea/2, 200+sizeOfInputArea/5); //draw current letter
    textSize(20);
    if (letterClicked) drawLetters();  
  }
}

void drawLetters() {
  int i = currentBoxRow*3 + currentBoxCol;
  //Up
  fill(0, 0, 255);
  rect(200+currentBoxCol*keyWidth, 200+keyTop+((currentBoxRow-1)*keyHeight), keyWidth, keyHeight);
  fill(0, 0, 0);
  textAlign(CENTER);
  text(alphabet[i].charAt(0), 200+currentBoxCol*keyWidth+keyWidth/2, 200+keyTop+((currentBoxRow-1)*keyHeight)+keyHeight/2+10);

  //Down
  fill(0, 0, 255);
  rect(200+currentBoxCol*keyWidth, 200+keyTop+((currentBoxRow+1)*keyHeight), keyWidth, keyHeight);
  fill(0, 0, 0);
  textAlign(CENTER);
  text(alphabet[i].charAt(2), 200+currentBoxCol*keyWidth+keyWidth/2, 200+keyTop+((currentBoxRow+1)*keyHeight)+keyHeight/2+10);

  //Right
  fill(0, 0, 255);
  rect(200+(currentBoxCol+1)*keyWidth, 200+keyTop+(currentBoxRow*keyHeight), keyWidth, keyHeight);
  fill(0, 0, 0);
  textAlign(CENTER);
  text(alphabet[i].charAt(1), 200+(currentBoxCol+1)*keyWidth+keyWidth/2, 200+keyTop+(currentBoxRow*keyHeight)+keyHeight/2+10);

  //Left (if four letters)
  if (alphabet[i].length() > 3) {
    fill(0, 0, 255);
    rect(200+(currentBoxCol-1)*keyWidth, 200+keyTop+(currentBoxRow*keyHeight), keyWidth, keyHeight);
    fill(0, 0, 0);
    textAlign(CENTER);
    text(alphabet[i].charAt(3), 200+(currentBoxCol-1)*keyWidth+keyWidth/2, 200+keyTop+(currentBoxRow*keyHeight)+keyHeight/2+10);    
  }
}


boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


void mousePressed()
{
  //If trying to delete 
  if (didMouseClick(200+3*keyWidth, 200+keyTop, keyWidth, 2*keyHeight) && currentTyped.length()>0) {
    currentTyped = currentTyped.substring(0, cursorIdx-1) + currentTyped.substring(cursorIdx);
    cursorIdx = Math.max(cursorIdx-1, 0);
  }
  //If trying to click on any letters (this doesn't include ">" or "<" obvi)
  if (didMouseClick(200, 200+keyTop, 3*keyWidth, 3*keyHeight) && !didMouseClick(200+2*keyWidth, 200+keyTop+2*keyHeight, keyWidth, keyHeight)) {
    letterClicked = true;
    //Figure out which textbox the click belongs to (assigns value 0-7)
    int col = (int) ((mouseX-200) / keyWidth);
    int row = (int) ((mouseY-(200+keyTop)) / keyHeight);
    currentBoxRow = row;
    currentBoxCol = col;
  }
  //if (didMouseClick(200, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in left button
  //{
  // currentLetter --;
  // if (currentLetter<'_') //wrap around to z
  //   currentLetter = 'z';
  //}

  //if (didMouseClick(200+sizeOfInputArea/2, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in right button
  //{
  // currentLetter ++;
  // if (currentLetter>'z') //wrap back to space (aka underscore)
  //   currentLetter = '_';
  //}
  
  //if (didMouseClick(200, 200, sizeOfInputArea, sizeOfInputArea/2)) //check if click occured in letter area
  //{
  // if (currentLetter=='_') //if underscore, consider that a space bar
  //   currentTyped+=" ";
  // else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
  //   currentTyped = currentTyped.substring(0, currentTyped.length()-1);
  // else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
  //   currentTyped+=currentLetter;
  //}

  //You are allowed to have a next button outside the 2" area
  
  //If clicked on the space button
  if (didMouseClick(200+keyWidth, 200+keyTop+(3*keyHeight), 3*keyWidth, keyHeight)) {
     currentTyped+=" ";
     currentLetter = ' ';
     cursorIdx++;
  }

  //If clicked on the done button
  if (didMouseClick(200, 200+keyTop+(3*keyHeight), keyWidth, keyHeight)) //check if click is in done button
  {
    nextTrial(); //if so, advance to next trial
  }
  
  //If clicked on the < button
  if (didMouseClick(200+2*keyWidth, 200+keyTop+(2*keyHeight), keyWidth, keyHeight)) {
     currentLetter = ' ';
     cursorIdx = Math.max(cursorIdx-1, 0);
  }
  
  //If clicked on the > button
  if (didMouseClick(200+3*keyWidth, 200+keyTop+(2*keyHeight), keyWidth, keyHeight)) {
     currentLetter = ' ';
     cursorIdx = Math.min(cursorIdx+1, currentTyped.length());
  }

}

void mouseMoved() {
  letterClicked = false;
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

    if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.length();
    lettersEnteredTotal+=currentTyped.length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output
    System.out.println("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f)); //output
    System.out.println("==================");
    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  }
  else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  cursorIdx = 0; 
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}




//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
