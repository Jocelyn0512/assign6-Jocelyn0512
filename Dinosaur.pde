class Dinosaur extends Enemy{
	// Requirement #4: Complete Dinosaur Class
  float speed = 2f;
  final float TRIGGERED_SPEED_MULTIPLIER = 5;
  
  void display(){
    int direction = (speed > 0) ? RIGHT : LEFT;
    
    pushMatrix();
    translate(x, y);
    if (direction == RIGHT) {
      scale(1, 1);
      image(dinosaur, 0, 0, w, h); 
    } else {
      scale(-1, 1);
      image(dinosaur, -w, 0, w, h); 
    }
    popMatrix();
  }
  
  
  void update(){
    move();
  }
  
  void checkCollision(Player player){
    if(player.health > 0
      && isHit(x, y, w, h, player.x, player.y, w, h)){
        player.hurt();
        x = y = -1000;
      }
  }
  
  void move(){
    x += speed;
    
    if (x < 0 || x > width - w) { 
      speed *= -1 ;
    }
   
  }
  
  Dinosaur(float x, float y){
    super(x, y);
  }
  
	// HINT: Player Detection in update()
	/*
	float currentSpeed = speed
	If player is on the same row with me AND (it's on my right side when I'm going right OR on my left side when I'm going left){
		currentSpeed *= TRIGGERED_SPEED_MULTIPLIER
	}
	*/
}
