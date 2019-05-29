class Cabbage extends Item{
	// Requirement #1: Complete Cabbage Class
  void display(){
    image(cabbage,x,y);
  }
  
  void checkCollision(Player player){
    if(player.health < player.PLAYER_MAX_HEALTH
      && isHit(x, y, w, h, player.x, player.y, w, h)){
        player.health ++;
        x = y = -1000;
      }
  }
  
  Cabbage(float x, float y){
    super(x, y);
  }
	/*
	Code for Reference:

		for(int i = 0; i < cabbageX.length; i++){

			// Display Cabbage
			image(cabbage, cabbageX[i], cabbageY[i]);

			// Check collision with player
			if(player.health < player.PLAYER_MAX_HEALTH
			&& isHit(cabbageX[i], cabbageY[i], SOIL_SIZE, SOIL_SIZE, player.x, player.y, player.w, player.h)){

				player.health ++;
				cabbageX[i] = cabbageY[i] = -1000; // Now that they're objects, toggle isAlive instead of throwing them away from screen

			}

		}

	*/
}
