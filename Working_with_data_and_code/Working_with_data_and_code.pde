/**
 * Arctangent. 
 * 
 * Move the mouse to change the direction of the eyes. 
 * The atan2() function computes the angle from each eye 
 * to the cursor. 
 */
 
ArrayList<Star> stars = new ArrayList<Star>();
ArrayList<Planet> planets = new ArrayList<Planet>();
PImage planetImage1, planetImage2, planetImage3, planetImage4, planetImage5, planetImage6;

void setup() {
  size(1080, 700);
  noStroke();

  // Load your planet images
  planetImage1 = loadImage("Planets/Planet1.png");
  planetImage2 = loadImage("Planets/Planet2.png");
  planetImage3 = loadImage("Planets/Planet3.png");
  planetImage4 = loadImage("Planets/Planet4.png");
  planetImage5 = loadImage("Planets/Planet5.png");
  planetImage6 = loadImage("Planets/Planet6.png");

  // Initialize stars
  for (int i = 0; i < 50; i++) {
    stars.add(new Star(random(width), random(height), random(5, 15), random(TWO_PI), random(0.005, 0.02)));
  }

  // Initialize planets
  planets.add(new Planet(840, 200, 120 * 5, planetImage1));
  planets.add(new Planet(164, 285, 100 * 5, planetImage2));
  planets.add(new Planet(620, 230, 220 * 2, planetImage3));
  planets.add(new Planet(400, 340, 420 * 1, planetImage4));
  planets.add(new Planet(900, 540, 220 * 2, planetImage5));
  planets.add(new Planet(600, 540, 520 * 1, planetImage6));
}

void draw() {
  // Create a simple gradient background
  background(10, 20); // Dark color at the top (R:10, G:10, B:10), Light color at the bottom (R:20, G:20, B:20)

  // Update and display stars
  for (Star star : stars) {
    star.update();
    star.display();
    for (Star other : stars) {
      if (star != other) {
        star.checkCollisionWithStar(other);
      }
    }
  }

  // Update and display planets
  for (Planet planet : planets) {
    planet.update(mouseX, mouseY);
    planet.display();
  }
}

void mouseMoved() {
  float forceFieldRadius = 100;  // Adjust the forcefield radius as needed

  // Check forcefield with stars when the mouse is moved
  for (Star star : stars) {
    star.checkForceField(mouseX, mouseY, forceFieldRadius);
  }
}

class Star {
  float x, y;
  float size;
  float speedX, speedY;
  float angle;
  float angleSpeed;

  Star(float tx, float ty, float ts, float initialAngle, float rotationSpeed) {
    x = tx;
    y = ty;
    size = ts;
    speedX = random(-1, 1);
    speedY = random(-1, 1);
    angle = initialAngle;
    angleSpeed = rotationSpeed;
  }

  void update() {
    x += speedX;
    y += speedY;

    if (x > width || x < 0) {
      speedX *= -1;
    }
    if (y > height || y < 0) {
      speedY *= -1;
    }

    angle += angleSpeed;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);
    fill(255);
    noStroke();
    beginShape();
    float angleOff = PI / 10.0;
    for (int i = 0; i < 5; i++) {
      float angle = angleOff + TWO_PI / 5 * i;
      float xVertex = cos(angle) * size;
      float yVertex = sin(angle) * size;
      vertex(xVertex, yVertex);
      angle += PI / 5.0;
      xVertex = cos(angle) * size / 2;
      yVertex = sin(angle) * size / 2;
      vertex(xVertex, yVertex);
    }
    endShape(CLOSE);
    popMatrix();
  }

  void checkCollisionWithStar(Star other) {
    float distance = dist(x, y, other.x, other.y);
    if (distance < size / 2 + other.size / 2) {
      float angle = atan2(other.y - y, other.x - x);
      float targetX = x + cos(angle) * (size / 2 + other.size / 2);
      float targetY = y + sin(angle) * (size / 2 + other.size / 2);

      float ax = (targetX - x) * 0.1;
      float ay = (targetY - y) * 0.1;
      speedX -= ax;
      speedY -= ay;

      angle += PI;
      targetX = other.x + cos(angle) * (size / 2 + other.size / 2);
      targetY = other.y + sin(angle) * (size / 2 + other.size / 2);

      ax = (targetX - other.x) * 0.1;
      ay = (targetY - other.y) * 0.1;
      other.speedX -= ax;
      other.speedY -= ay;
    }
  }

  void checkForceField(float mx, float my, float forceFieldRadius) {
    float distance = dist(x, y, mx, my);

    if (distance < forceFieldRadius) {
      float angle = atan2(y - my, x - mx);
      float force = map(distance, 0, forceFieldRadius, 0.05, 0);  // Adjust force based on distance

      // Apply force to move the star away from the mouse
      speedX += cos(angle) * force;
      speedY += sin(angle) * force;
    }
  }
}

class Planet {
  float x, y;
  float size;
  float angle = 0.0;
  float targetX, targetY;
  PImage planetImage;

  Planet(float tx, float ty, float ts, PImage img) {
    x = targetX = tx;
    y = targetY = ty;
    size = ts;
    planetImage = img;
  }

  void update(float mx, float my) {
    targetX = lerp(targetX, mx, 0.05);
    targetY = lerp(targetY, my, 0.05);

    float angleToTarget = atan2(targetY - y, targetX - x);
    angle = angleToTarget;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);

    // Display the planet image instead of ellipse
    imageMode(CENTER);
    image(planetImage, 0, 0, size / 2, size / 2);

    popMatrix();
  }
}
