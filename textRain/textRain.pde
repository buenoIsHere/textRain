import processing.video.*;

Capture cam;
float brightnessThresh;
String [] quotes;
ArrayList <LetterDrop> letters;
int letterGap;

//Our raindrops!
public class LetterDrop
{ 
  public float velocity;
  public float lx;
  public float ly;
  public char letter;
  public color clr;
  
  public LetterDrop(float xcoord, float ycoord,  char l, color c)
  {
    lx = xcoord;
    ly = ycoord;
    velocity = .6 + random(0.0, 0.07);  
    letter = l;
    clr = c;
  }
}

void setup() {
  size(640, 480);
  
  quotes = new String [2];
  quotes[0] = "Humanity i love you because you are perpetually putting the";
  quotes[1] = "secret of life in your pants and forgetting it’s there";

  //SETTING UP WEBCAM CAPTURE
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } 
  else {
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
  
  noStroke();
  brightnessThresh = 120;
  
  // CREATE THE FONT
  textFont(createFont("Georgia", 22));
  textAlign(CENTER, BOTTOM);
  
  
  letters = new ArrayList<LetterDrop>();
  spawnLetters();
}


//Helper function for setup. Populates our array of letters.
//Note that I was inspired by ~Kamen and I give credit to him for
//the idea to have the next text lines "waiting" offscreen.
void spawnLetters()
{
  
   //GRAB A LINE FROM THE POEM
   for (int l = 0; l < quotes.length; l++) 
   {
     
    String phrase = quotes[l];
    int len = phrase.length();
    
    //FOR EACH NONSPACE CHAR IN PHRASE, MAKE A NEW LETTER OBJECT
    for (int i=0; i < len; i++) 
    {
      char ch = phrase.charAt(i);
     
      if (ch != ' ')
      {
        letters.add(new LetterDrop(10 * i + 30, -l * 500 + 20, ch, color(255, 255, 255)));
      }
    }
  } 
}

void draw() {
  
  update();
  
  image(cam, 0, 0);
  // The following does the same, and is faster when just drawing the image
  // without any additional resizing, transformations, or tint.
  //set(0, 0, cam);  
    
  for (int k = 0; k < letters.size(); k++) 
  {
    LetterDrop drop = letters.get(k);
    if (drop.ly >= 0) 
    {
      stroke(drop.clr);
      text(drop.letter, drop.lx, drop.ly);
    }
  }
  
}

void update()
{
  
  // DRAW CAPTURED WEBCAM IMAGE TO WINDOW  
  if (cam.available() == true) {
    cam.read();
  } 
  
  loadPixels();
  
  //RECOLOR IMAGE BASED ON PIXEL BRIGHTNESS
  for(int i = 0; i < cam.height; i++)
  {
    for(int j = 0; j < cam.width; j++)
    {
        int index = (i * cam.width) + j;
        
        if(brightness(cam.pixels[index]) > brightnessThresh)
        {
          cam.pixels[index] = 0x5F7485;  

        }
        else
        {
          cam.pixels[index] = 0x4B556C;
        }
    }
  }
  
  updatePixels();
  
  //CHECK EACH LETTER FOR COLLISION
  for(int k = 0; k < letters.size(); k ++)
  {
    LetterDrop drop = letters.get(k);
    
    if(!collision(drop))
    {
      drop.ly += drop.velocity;
    }
    else if(collision(drop) && (drop.ly > 15))
    {
      int aboveIndex = floor(drop.lx) + floor(drop.ly-1) * width;
      if(brightness(pixels[aboveIndex]) < brightnessThresh)
      {
        drop.ly -= 5;
      }
    }
    
    if(drop.ly > height)
    {
      drop.ly -= height + 500; 
    }   
  }
}

boolean collision(LetterDrop drop)
{

    if(drop.ly > 0)
    {
      int index = floor(drop.lx) + floor(drop.ly) * width;
      color pC = pixels[index];
    
      if(brightness(pC) < brightnessThresh)
      {
        return true;  
      }
      else
      {
        return false;  
      }
    }
    else
    {
      return false;  
    }
}
