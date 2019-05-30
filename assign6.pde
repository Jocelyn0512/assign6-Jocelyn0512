PImage title, gameover, gamewin, startNormal, startHovered, restartNormal, restartHovered;
PImage groundhogIdle, groundhogLeft, groundhogRight, groundhogDown;
PImage bg, life, cabbage, soilEmpty, clock, caution, sweethome;
PImage soldier, robot, dinosaur;
PImage[][] soilImages, stoneImages;
PFont font;

final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2, GAME_WIN = 3;
int gameState = 0;

final int GRASS_HEIGHT = 15;
final int SOIL_COL_COUNT = 8;
final int SOIL_ROW_COUNT = 24;
final int SOIL_SIZE = 80;

Soil[][] soils;

final int START_BUTTON_WIDTH = 144;
final int START_BUTTON_HEIGHT = 60;
final int START_BUTTON_X = 248;
final int START_BUTTON_Y = 360;

Player player;
Item[] items;
Enemy[] enemies;

final int GAME_INIT_TIMER = 7200;
int gameTimer = GAME_INIT_TIMER;

final float CLOCK_BONUS_SECONDS = 15f;

boolean leftState = false;
boolean rightState = false;
boolean downState = false;

void setup() {
	size(640, 480, P2D);
	frameRate(60);
	bg = loadImage("img/bg.jpg");
	title = loadImage("img/title.jpg");
	gameover = loadImage("img/gameover.jpg");
	gamewin = loadImage("img/gamewin.jpg");
	startNormal = loadImage("img/startNormal.png");
	startHovered = loadImage("img/startHovered.png");
	restartNormal = loadImage("img/restartNormal.png");
	restartHovered = loadImage("img/restartHovered.png");
	groundhogIdle = loadImage("img/groundhogIdle.png");
	groundhogLeft = loadImage("img/groundhogLeft.png");
	groundhogRight = loadImage("img/groundhogRight.png");
	groundhogDown = loadImage("img/groundhogDown.png");
	life = loadImage("img/life.png");
	soldier = loadImage("img/soldier.png");
	dinosaur = loadImage("img/dinosaur.png");
	robot = loadImage("img/robot.png");
	cabbage = loadImage("img/cabbage.png");
	clock = loadImage("img/clock.png");
	caution = loadImage("img/caution.png");
	sweethome = loadImage("img/sweethome.png");

	soilEmpty = loadImage("img/soils/soilEmpty.png");

	font = createFont("font/font.ttf", 56);
	textFont(font);

	// Load PImage[][] soils
	soilImages = new PImage[6][5];
	for(int i = 0; i < soilImages.length; i++){
		for(int j = 0; j < soilImages[i].length; j++){
			soilImages[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
		}
	}

	// Load PImage[][] stones
	stoneImages = new PImage[2][5];
	for(int i = 0; i < stoneImages.length; i++){
		for(int j = 0; j < stoneImages[i].length; j++){
			stoneImages[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
		}
	}

	// Initialize Game
	initGame();

}

void initGame(){

	gameTimer = GAME_INIT_TIMER;

	// Initialize player
	player = new Player();

	// Initialize soilHealth
	soils = new Soil[SOIL_COL_COUNT][SOIL_ROW_COUNT];

	int[] emptyGridCount = new int[SOIL_ROW_COUNT];

	for(int j = 0; j < SOIL_ROW_COUNT; j++){
		emptyGridCount[j] = ( j == 0 ) ? 0 : floor(random(1, 3));
	}

	for(int i = 0; i < soils.length; i++){
		for (int j = 0; j < soils[i].length; j++) {
			 // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
			soils[i][j] = new Soil(i, j, 0);
			float randRes = random(SOIL_COL_COUNT - i);

			if(randRes < emptyGridCount[j]){
				emptyGridCount[j] --;

			}else{

				soils[i][j].health = 15;

				if(j < 8){

					if(j == i) soils[i][j].health = 2 * 15;

				}else if(j < 16){

					int offsetJ = j - 8;
					if(offsetJ == 0 || offsetJ == 3 || offsetJ == 4 || offsetJ == 7){
						if(i == 1 || i == 2 || i == 5 || i == 6){
							soils[i][j].health = 2 * 15;
						}
					}else{
						if(i == 0 || i == 3 || i == 4 || i == 7){
							soils[i][j].health = 2 * 15;
						}
					}

				}else{

					int offsetJ = j - 16;
					int stoneCount = (offsetJ + i) % 3;
					soils[i][j].health = (stoneCount + 1) * 15;

				}
			}
		}
	}

	// Initialize enemies and their position

	enemies = new Enemy[6];

	for(int i = 0; i < enemies.length; i++){
		float newX = random(0, width - SOIL_SIZE);
		float newY = SOIL_SIZE * ( i * 4 + floor(random(4)));

		switch(i){
			case 0: case 1: enemies[i] = new Soldier(newX, newY);
      break;
			case 2: case 3: enemies[i] = new Dinosaur(newX, newY);// Requirement 4: Create new Dinosaur in row 9 - 16
			break;
      case 4: case 5: enemies[i] = new Robot(newX, newY);// Requirement 5: Create new Robot in row 17 - 25
		  break;
    }


	}

	// Initialize items and their position

	items = new Item[6];

	for(int i = 0; i < items.length; i++){
		float newX = SOIL_SIZE * floor(random(SOIL_COL_COUNT));
		float newY = SOIL_SIZE * ( i * 4 + floor(random(4)));

		// Requirement #3:
		// 	- Randomly decide if a cabbage or a clock should appear in a random soil every 4 rows (6 items in total)
		// 	- Create and store cabbages/clocks in the same items array
		// 	- You can use the above newX/newY to set their position in constructor
    items[i] = (random(1)>0.5)?new Cabbage(newX,newY):new Clock(newX,newY);//1:1 probability
	}
}

void draw() {

	switch (gameState) {

		case GAME_START: // Start Screen
		image(title, 0, 0);
		if(isMouseHit(START_BUTTON_X, START_BUTTON_Y, START_BUTTON_WIDTH, START_BUTTON_HEIGHT)) {

			image(startHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;
			}

		}else{

			image(startNormal, START_BUTTON_X, START_BUTTON_Y);

		}

		break;

		case GAME_RUN: // In-Game
		// Background
		image(bg, 0, 0);

		// Sun
	    stroke(255,255,0);
	    strokeWeight(5);
	    fill(253,184,19);
	    ellipse(590,50,120,120);

	    // CAREFUL!
	    // Because of how this translate value is calculated, the Y value of the ground level is actually 0
		pushMatrix();
		translate(0, max(SOIL_SIZE * -22, SOIL_SIZE * 1 - player.y));

		// Ground

		fill(124, 204, 25);
		noStroke();
		rect(0, -GRASS_HEIGHT, width, GRASS_HEIGHT);

		// Soil

		for(int i = 0; i < SOIL_COL_COUNT; i++){
			for(int j = 0; j < SOIL_ROW_COUNT; j++){

				soils[i][j].display();

			}
		}

		// Soil background past layer 24
		for(int i = 0; i < SOIL_COL_COUNT; i++){
			for(int j = SOIL_ROW_COUNT; j < SOIL_ROW_COUNT + 4; j++){
				image(soilEmpty, i * SOIL_SIZE, j * SOIL_SIZE);
			}
		}

		image(sweethome, 0, SOIL_ROW_COUNT * SOIL_SIZE);

		// Items
		// Requirement #3: Display and check collision with player for each item in Item[] items
    for(int i = 0; i < items.length; i++){
      items[i].display();
      items[i].checkCollision(player);
    }
		// Player

		player.update();

		// Enemies

		for(Enemy e : enemies){
			if(e == null) continue;
			e.update();
			e.display();
			e.checkCollision(player);
		}

		// Caution Sign
		Enemy nextRowEnemy = getEnemyByRow(player.row + 5);
		if(nextRowEnemy != null){
			image(caution, nextRowEnemy.x, nextRowEnemy.y - SOIL_SIZE);
		}

		popMatrix();

		// Layer Count UI
		String depthString = ( player.row + 1 ) + "m";
		textSize(56);
		textAlign(RIGHT, BOTTOM);
		fill(0, 120);
		text(depthString, width + 3, height + 3);
		fill(#ffcc00);
		text(depthString, width, height);

		// Time UI
		textAlign(LEFT, BOTTOM);
		String timeString = convertFrameToTimeString(gameTimer);
		fill(0, 120);
		text(timeString, 3, height + 3);
		fill(getTimeTextColor(gameTimer));
		text(timeString, 0, height);

		gameTimer --;
		if(gameTimer <= 0) gameState = GAME_OVER;

		// Health UI

		for(int i = 0; i < player.health; i++){
			image(life, 10 + i * 70, 10);
		}

		break;

		case GAME_OVER: // Gameover Screen
		image(gameover, 0, 0);
		
		if(isMouseHit(START_BUTTON_X, START_BUTTON_Y, START_BUTTON_WIDTH, START_BUTTON_HEIGHT)) {

			image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;

				initGame();
			}

		}else{

			image(restartNormal, START_BUTTON_X, START_BUTTON_Y);

		}
		break;

		case GAME_WIN: // Gameover Screen
		image(gamewin, 0, 0);
		
		if(isMouseHit(START_BUTTON_X, START_BUTTON_Y, START_BUTTON_WIDTH, START_BUTTON_HEIGHT)){

			image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;
				initGame();
			}

		}else{

			image(restartNormal, START_BUTTON_X, START_BUTTON_Y);

		}
		break;
		
	}
}

void addTime(float seconds){
	gameTimer += round(seconds * 60);
}

boolean isHit(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh){
	return	ax + aw > bx &&    // a right edge past b left
		    ax < bx + bw &&    // a left edge past b right
		    ay + ah > by &&    // a top edge past b bottom
		    ay < by + bh;
}

boolean isMouseHit(float bx, float by, float bw, float bh){
	return	mouseX > bx && 
		    mouseX < bx + bw && 
		    mouseY > by && 
		    mouseY < by + bh;
}

color getTimeTextColor(int frames){
	if(frames >= 7200){
		return #00ffff;
	}else if(frames >= 3600){
		return #ffffff;
	}else if(frames >= 1800){
		return #ffcc00;
	}else if(frames >= 600){
		return #ff6600;
	}

	return #ff0000;
}

String convertFrameToTimeString(int frames){
	String result = "";
	float totalSeconds = float(frames) / 60;
	result += nf(floor(totalSeconds/60), 2);
	result += ":";
	result += nf(floor(totalSeconds%60), 2);
	return result;
}

Enemy getEnemyByRow(int row){
	int areaIndex = floor(row/4);
	return (areaIndex >= 0
		&& areaIndex < enemies.length
		&& enemies[areaIndex] != null
		&& round(enemies[areaIndex].y / SOIL_SIZE) == row) ? enemies[areaIndex] : null;
}

void keyPressed(){
	if(key==CODED){
		switch(keyCode){
			case LEFT:
			leftState = true;
			break;
			case RIGHT:
			rightState = true;
			break;
			case DOWN:
			downState = true;
			break;
		}
	}else if(key == 'r'){
		gameState = GAME_OVER;
	}
}

void keyReleased(){
	if(key==CODED){
		switch(keyCode){
			case LEFT:
			leftState = false;
			break;
			case RIGHT:
			rightState = false;
			break;
			case DOWN:
			downState = false;
			break;
		}
	}
}
