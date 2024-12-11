import processing.sound.*;
SoundFile sonidoFondo, sonidoDisp, sonidoCol, sonidoGO;
PFont letras;
PImage ciudad, colision, GO;

ArrayList<Dispara> disparos = new ArrayList<Dispara>();
ArrayList<Robot> objects = new ArrayList<Robot>();

int lastDrawTime = 0, intervalo = 5000, maxObjetos = 5, anotaciones = 0, tiempoInicio, tiempoTranscurrido = 0;
boolean gameOver = false, repro = false, temporizador = true;


void setup(){
  size(1024,768);
  frameRate(100);
  
  ciudad = loadImage("Ciudad.jpg");
  colision = loadImage("Colision.gif");
  GO = loadImage("GameOver2.png");
  
  sonidoDisp = new SoundFile(this, "Laser.wav");
  sonidoFondo = new SoundFile(this, "File.wav");
  sonidoCol = new SoundFile(this, "Colision.wav");
  sonidoGO = new SoundFile(this, "GameOver3.wav");
  
  letras = createFont("8-bit-hud.ttf",33);
  
  tiempoInicio = millis();
  sonidoFondo.loop();
} 


float inc_x, inc_y, distancia, distancia2, vel = 3, minima = 50; 


void draw(){
  image(ciudad, 0, 0, width, height);
  
  if(gameOver){ // Muestra el Game Over
    image(GO, 50, 0, width-100, 568);
    if(!repro){
      sonidoGO.play();
      repro = true;
    }
    
    fill(255, 255, 255);
    textFont(letras);
    textSize(50);
    text("Puntuacion: "+anotaciones, 165, 620);  
    text("Tiempo: " + (int)(tiempoTranscurrido/1000) + "s", 165, 720);
    
    temporizador  = false;
    return;
  }
  
  int tiempoActual = millis();
  if(!gameOver){
    if(objects.size() >= 5 && (tiempoActual-lastDrawTime) >= 5000){
      gameOver = true;
    }
    if(temporizador){
      tiempoTranscurrido = millis() - tiempoInicio; //Tiempo transcurrido
    }
  }
  
  if(tiempoActual-lastDrawTime >= intervalo && objects.size() < maxObjetos){
    objects.add(new Robot("Robot.png", 80, 80,-0.5));
    lastDrawTime = tiempoActual;
  }

  for (Robot obj : objects){
    obj.display();
  }
  
  for (Robot obj : objects){
    obj.move();
  }

  for(int i = disparos.size() - 1; i >= 0; i--){
    Dispara disparo = disparos.get(i);
    disparo.display();
    if(disparo.rebote()) {
      disparos.remove(i); //Elimina el disparo si reboto 3 veces
    }else{// Comprobueba si hay colisión de un disparo y un robot
      for(int j = objects.size() - 1; j >= 0; j--){
        Robot robot = objects.get(j);
        distancia = dist(disparo.posx + disparo.tamx/2, disparo.posy + disparo.tamy/2, robot.posx + robot.tamx/2, robot.posy + robot.tamy/2);
        if(distancia < (disparo.tamx + robot.tamx)/2) {//Elimina el disparo y el robot
          disparos.remove(i);
          objects.remove(j);
          anotaciones++;
          if(!sonidoCol.isPlaying()){
            sonidoCol.play();
          }
          image(colision, robot.posx-5, robot.posy-5, robot.tamx+5, robot.tamy+5);
          break;
        }
      }
    }
  }

  strokeWeight(0.5);
  fill(50, 200, 255);//Suma
  rect(800, 50, 50, 50, 5);
  fill(255, 0, 0);
  rect(823, 55, 6, 40, 2);
  fill(255, 0, 0);
  rect(805, 71, 40, 6, 2);
    
  fill(50, 200, 255);//Resta
  rect(860, 50, 50, 50,5);
  fill(0, 255, 0);
  rect(865, 71, 40, 6, 2);
    
  fill(50, 200, 255);//Velocidad
  rect(800, 110, 110, 50, 5);
  fill(255);
  textSize(33);
  text("Vel: "+int(vel), 812, 147); 
    
  fill(50, 200, 255);//Puntuacion
  rect(650, 50, 140, 50, 5);
  fill(255);
  textSize(30);
  text("Puntos: "+anotaciones, 656, 87); 
    
  fill(50, 200, 255);//Cronometro
  rect(460, 50, 180, 50, 5);
  fill(255);
  textSize(33);
  text("Tiempo: " + (int)(tiempoTranscurrido/1000) + "s", 470, 88);// Tiempo en segundos
}

void mouseClicked(){  
  if (!gameOver){
    
    if(mouseX>=800 && mouseX<=850 && mouseY>=50 && mouseY<=100 && vel<10)vel++;
    if(mouseX>=860 && mouseX<=910 && mouseY>=50 && mouseY<=100 && vel>1)vel--;
  
    if(disparos.size() < 40){
      if(!sonidoDisp.isPlaying()){
        sonidoDisp.play();
      }
      
      distancia2 = dist(20, 354, mouseX, mouseY);
      inc_x = (mouseX-20) / distancia2;
      inc_y = (mouseY-354) / distancia2;
      disparos.add(new Dispara("Laser.png", vel, 50, 50, inc_x, inc_y));
      loop();
    }
  }
}

void mouseMoved(){
  if (!gameOver){
    strokeWeight(2);
    line(20, 384, mouseX, mouseY);
  }  
}


class Robot{
  PImage robot;
  float vel, posx, posy, tamx, tamy;
  int dir;
  
  Robot(String imagePath, float x, float y, float tempXspeed){
    robot = loadImage(imagePath);
    posx = random(width/2 ,width); 
    posy = random(height-50);
    tamx = x;
    tamy = y;
    vel = tempXspeed;
    dir = 1;
  }

  void display(){
    image(robot, posx, posy, tamx, tamy);
  }

  void move(){
    if(posx <= 1 || posx >= width){
      dir *= -1;
    }
    posx += dir * 2;
  }
}


class Dispara{
  PImage disparo;
  float incx, incy, posx, posy, tamx, tamy, vel;
  int rebotes = 0;
  
  Dispara(String imagePath, float tempXspeed, float x, float y, float incrementox, float incrementoy){
    disparo = loadImage(imagePath);
    posx = 20; 
    posy = 354;
    tamx = x;
    tamy = y;
    vel = tempXspeed;
    incx = incrementox;
    incy = incrementoy;
  }

  void display(){
    posx += incx * vel;
    posy += incy * vel;
    image(disparo, posx, posy, tamx, tamy);
    
    // Verificar rebotes
    if(posx >= width - tamx || posx <= 0){
      incx = -incx;
      rebotes++;
    }
    if(posy >= height - tamy || posy <= 0){
      incy = -incy;
      rebotes++;
    }
  }
  
  boolean rebote(){
    return rebotes >= 3; //Regresa verdadero si reboto 3 veces o más
  }

  void disparar(float incrementox, float incrementoy){
    incx = incrementox;
    incy = incrementoy;
  }
}
