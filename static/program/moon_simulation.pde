PVector moon_position=new PVector();
PVector text_position=new PVector();
float angle = 0.0;
float moon_distance=120;
int colorNumber = 0;
color color1 = color(144,215,236);
color color2 = color(236, 93, 15);
color color3 = color(10, 10, 10);
boolean move_moon=true;

void setup(){
  size(innerWidth-8,innerHeight-34,P3D);
  noStroke();
  hint(ENABLE_DEPTH_TEST);
}

void draw(){
  camera(0,0,0,moon_position.x,moon_position.y,moon_position.z,0,1,0);
  directionalLight(185,205,98,-1,0,0);
  if (colorNumber == 0){
    background(color1);
    ambientLight(red(color1),green(color1),blue(color1));
  }else if(colorNumber == 1){
    background(color2);
    ambientLight(red(color2),green(color2),blue(color2));
  }else{
    background(color3);
    ambientLight(red(color3),green(color3),blue(color3));
  }
  pushMatrix();
  if(move_moon)calcMoonPosition();
  translate(moon_position.x,moon_position.y,moon_position.z);
  fill(255);
  sphere(30);
  popMatrix();
}
void calcMoonPosition(){
  angle+=PI*0.0016;
  moon_position.set(moon_distance*cos(angle),0,moon_distance*sin(angle));
}
void mouseClicked()
{
     colorNumber++;
    if (colorNumber > 2) 
    {
        colorNumber = 0;
    }
}
void keyPressed(){
  if(key==' '){
    move_moon=!move_moon;
  }
}
