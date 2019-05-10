private ArrayList<Body> _bodies = new ArrayList<Body>(); //<>// //<>//
private final color _backgroundColour = GreyscaleColor(20);
private final color _sunColour = GreyscaleColor(240);
private final color _glowColour = GreyscaleColor(40);
private final color _minPlanetColour = GreyscaleColor(55);
private final color _maxPlanetColour = GreyscaleColor(100);
private final float _minPlanetSize = 5;
private final float _maxPlanetSize = 15;
private final String[] _names = {"anathema", "imperium", "golgotha", "hyperion", "balthazer", "sephiroth", "pelinnor", "jezebel", "babylon"
  , "imperator", "nova roma", "terra nova", "ilus", "ilium", "tumultum", "bifrost", "asgard", "niflheim", "azazel", "nergal", "sebek", "tiamat", "cerberus", 
  "dionysus", "pliosteces", "mephistopheles", "vanta", "argent"};

private final String[] _numbers = {"", "", "", "", "", "", "i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x"};

private String _currentName;
private float _xCenter;
private float _yCenter;
private float _sunWidth;
private PImage _glow;

public void setup() {
  fullScreen(P2D);
  pixelDensity(2);
  noStroke();
  Initialise();
}

void mouseClicked() {
  Initialise();
}

private void Initialise() {
  _bodies.clear();
  _xCenter = width / 2f;
  _yCenter = height / 2f;
  _sunWidth = random(30, 50);
  float _currentRadius = random(_sunWidth + 20, _sunWidth + 60);
  int beltCount = 0;
  int maxPlanets = (int)random(3, 9);
  float maxPlanetsNormalised = (maxPlanets - 3f) / 6f;
  float planetGapMult = ((1 - maxPlanetsNormalised) + 1) * _maxPlanetSize;
  while (maxPlanets > 0 && _currentRadius < _yCenter - 150) {
    float size = random(_minPlanetSize, _maxPlanetSize);
    float speed = random(size / _currentRadius, size / _currentRadius * 2);
    float beltChance =(beltCount + 1) * 4;
    if (random(0, beltChance) < 1) {
      ++beltCount;
      CreateBelt(_currentRadius, size);
      size *= 2f;
    } else {
      _bodies.add(new Planet(new Vector2(_xCenter, _yCenter), size, speed, _currentRadius));
    }
    _currentRadius += random(planetGapMult, planetGapMult * 5f);
    --maxPlanets;
  }
  CreateGlow();
  String name = _names[(int)random(0, _names.length)];
  name += " " + _numbers[(int)random(0, _numbers.length)];
  _currentName = name.replace("", " ").trim().toUpperCase();
}

private color GreyscaleColor(int value) {
  return color(value, value, value, 255);
}

private color GreyscaleColor(int value, int alpha) {
  return color(value, value, value, alpha);
}

private void CreateBelt(float currentRadius, float size) {
  float beltWidth = random(size / 3f, size);
  int beltCount = (int)random(beltWidth * 5, beltWidth * 10);
  for (int i = 0; i < beltCount; ++i) {
    float orbitRadius = currentRadius + random(-beltWidth, beltWidth);
    float bodySize = random(1, 2);
    float bodySpeed = random(0.01f, 0.03f);
    Body body = new Body(new Vector2(_xCenter, _yCenter), bodySize, bodySpeed, orbitRadius);
    body.PlanetColour = GreyscaleColor((int)random(180, 200));
    _bodies.add(body);
  }
}

public void draw() {
  clear();
  DrawSun();
  for (Body body : _bodies) {
    body.Draw();
  }
  DrawText();
}

private void DrawText() {
  fill(_sunColour);
  stroke(_sunColour);
  float xWidth = (_currentName.length() * 20) / 2f;
  line(_xCenter - xWidth, height - 100, _xCenter + xWidth, height - 100);
  textSize(40);
  textAlign(CENTER, TOP);
  text(_currentName, _xCenter, height - 85);
}

private void DrawSun() {
  image(_glow, 0, 0);
  fill(_sunColour);
  noStroke();
  circle(_xCenter, _yCenter, _sunWidth);
}

void CreateGlow() {
  _glow = createImage(width, height, ARGB);
  for (int x = 0; x < width; ++x) {
    for (int y = 0; y < height; ++y) {
      float xDiff = x - _xCenter;
      float yDiff = y - _yCenter;
      float distance = xDiff * xDiff + yDiff * yDiff;
      distance = sqrt(distance);
      float lerpVal = distance / 300f;
      if (lerpVal > 1) lerpVal = 1;
      color bgColour = lerpColor(_glowColour, _backgroundColour, lerpVal);
      _glow.set(x, y, bgColour);
    }
  }
}

class Vector2 {
  public float X;
  public float Y;
  public Vector2(float x, float y) {
    SetXY(x, y);
  }

  public void SetXY(float x, float y) {
    X = x;
    Y = y;
  }
}

class Ring {
  public Vector2 Origin;
  public color Colour;
  protected Vector2 Position = new Vector2(0, 0);
  protected final float _size;
  protected final float _radius;

  public Ring(Vector2 origin, float size, float radius) {
    Origin = origin;
    _size = size;
    _radius = radius;
  }

  public void Draw() {
    stroke(Colour);
    strokeWeight(_size);
    noFill();
    circle(Origin.X, Origin.Y, _radius);
  }
}

class Body {
  public Vector2 Origin;
  public color PlanetColour;
  protected Vector2 Position = new Vector2(0, 0);
  protected final float _size;
  protected final float _speed;
  protected final float _orbitRadius;
  protected float _currentAngle;

  public Body(Vector2 origin, float size, float speed, float orbitRadius) {
    Origin = origin;
    _size = size;
    _speed = speed;
    _orbitRadius = orbitRadius;
    _currentAngle = random(0, 360);
  }

  public void Draw() {
    _currentAngle += _speed;
    if (_currentAngle > 360) _currentAngle -= 360;
    Position.SetXY(GetX(_currentAngle), GetY(_currentAngle));
    DrawBody();
  }

  private void DrawBody() {
    noStroke();
    fill(PlanetColour);
    circle(Position.X, Position.Y, _size);
  }

  protected float GetX(float angle) {
    return cos(radians(angle)) * _orbitRadius + Origin.X;
  }

  protected float GetY(float angle) {
    return sin(radians(angle)) * _orbitRadius + Origin.Y;
  }
}

class Planet extends Body {
  private final color _fadedRingColour;
  private float _pathLength;
  private ArrayList<Ring> _rings = new ArrayList<Ring>();

  public Planet(Vector2 origin, float size, float speed, float orbitRadius) {
    super(origin, size, speed, orbitRadius);
    float lerpVal = (size - _minPlanetSize) / (_maxPlanetSize - _minPlanetSize);
    if (lerpVal > 1) lerpVal = 1;
    PlanetColour = lerpColor(_minPlanetColour, _maxPlanetColour, 1 - lerpVal);
    int colourVal = (int)lerp(120, 180, lerpVal);
    _fadedRingColour = GreyscaleColor(colourVal, 0);
    _pathLength = random(45, 360);
    CheckToCreateSatellites();
  }

  private void CheckToCreateSatellites() {
    boolean satelliteChance = random(0, 3) < 1f;
    if (!satelliteChance) return;
    boolean createMoon = random(0, 3) < 2f;
    if (createMoon) CreateMoons();
    else CreateRings();
  }

  private void CreateMoons() {
    int moonCount = (int)floor(random(1, 4));
    float radius = _size / 2f + random(2, 4);
    for (int i = 0; i < moonCount; ++i) {
      float size = random(2, 4);
      float speed = random(-0.5f, 0.5f);
      radius += random(size + 1, size + 3);
      Body moon = new Body(Position, size, speed, radius);
      moon.PlanetColour = PlanetColour; 
      _bodies.add(moon);
    }
  }

  private void CreateRings() {
    int ringCount = (int)floor(random(1, 5));
    float maxWidth = 25 / ringCount;
    float radius = _size / 2f + random(2, 5);
    for (int i = 0; i < ringCount; ++i) {
      float size = maxWidth;
      if(size > 3) size = 3;
      size = random(1, size);
      radius += random(size + 3, size + 5);
      Ring ring = new Ring(Position, size, radius);
      ring.Colour = PlanetColour; 
      _rings.add(ring);
    }
  }

  public void Draw() {
    DrawOrbitPath();
    for(Ring ring : _rings){
      ring.Draw();
    }
    super.Draw();
  }

  private void DrawOrbitPath() {
    noFill();
    strokeWeight(1);
    beginShape();
    for (float angleOffset = 0; angleOffset < _pathLength; ++angleOffset) {
      float currentX = GetX(_currentAngle - angleOffset);
      float currentY = GetY(_currentAngle - angleOffset);
      float lerpVal = angleOffset / _pathLength;
      color lineColour = lerpColor(PlanetColour, _fadedRingColour, lerpVal);
      stroke(lineColour);
      vertex(currentX, currentY);
    }
    endShape();
  }
}
