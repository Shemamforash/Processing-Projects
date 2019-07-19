private ArrayList<Body> _bodies = new ArrayList<Body>(); //<>// //<>//
private final color _backgroundColour = GreyscaleColor(20);
private final color _sunColour = GreyscaleColor(240);
private final color _glowColour = GreyscaleColor(40);
private final color _minPlanetColour = GreyscaleColor(55);
private final float _minPlanetSize = 5;
private final float _maxPlanetSize = 15;
private final String[] _names = {"anathema", "imperium", "golgotha", "hyperion", "balthazer", "sephiroth", "pelinnor", "jezebel", "babylon"
  , "imperator", "nova roma", "terra nova", "ilus", "ilium", "tumultum", "bifrost", "asgard", "niflheim", "azazel", "nergal", "sebek", "tiamat", "cerberus", 
  "dionysus", "pliosteces", "mephistopheles", "vanta", "argent"};

private final String[] _numbers = {"", "", "", "", "", "", "i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x"};

private String _currentName;
private float _systemWidth;
private float _xCenter;
private float _yCenter;
private float _sunWidth;
private PImage _glow;
private float[] _orbitWidths;

public void setup() {
  fullScreen(P2D);
  smooth(4);
  pixelDensity(2);
  noStroke();
  Initialise();
  CalculateOrbitWidths();
}

void mouseClicked() {
  Initialise();
}

private color GetBodyColor(float distance){
  float normalisedDistance = distance / _systemWidth;
  if(normalisedDistance > 1) normalisedDistance = 1;
  return lerpColor(_sunColour, _minPlanetColour, normalisedDistance);
}

private void CalculateOrbitWidths() {
  int planetCount = (int)random(3, 10);
  int widthIntervals =  planetCount * 5;
  _orbitWidths = new float[planetCount];
  for (int i = 0; i < widthIntervals; ++i) {
    int selectedPlanet = (int)random(0, planetCount);
    _orbitWidths[selectedPlanet]++;
  }
  float startOrbit = 50;
  float endOrbit = random(_systemWidth - 200, _systemWidth);
  if (endOrbit < startOrbit) endOrbit = startOrbit + 50;
  float actualSystemWidth = endOrbit - startOrbit;
  for (int i = 0; i < planetCount; ++i) {
    _orbitWidths[i] /= widthIntervals;
    _orbitWidths[i] *= actualSystemWidth;
  }
}

private void Initialise() {
  _bodies.clear();
  _xCenter = width / 2f;
  _yCenter = height / 2f;
  _systemWidth = min(_xCenter, _yCenter) - 150;
  _sunWidth = random(30, 75);
  CalculateOrbitWidths();
  float currentRadius = _sunWidth + random(10, 30);
  int beltCount = 0;
  for (int i = 0; i < _orbitWidths.length; ++i) {
    float orbitWidth = currentRadius + _orbitWidths[i];
    float orbitRadius = currentRadius + _orbitWidths[i]/2f;
    float size = random(orbitWidth / 30f, orbitWidth / 20f);
    float speed = random(size / currentRadius, size / currentRadius * 2);
    float beltChance =(beltCount + 1) * 4;
    if (random(0, beltChance) < 1) {
      ++beltCount;
      CreateBelt(orbitRadius, size);
      size *= 2f;
    } else {
      Planet planet = new Planet(new Vector2(_xCenter, _yCenter), size, speed, orbitRadius, true);
      _bodies.add(planet);
    }
    currentRadius = orbitWidth;
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
    float randomNormalised = random(0, 1);
    randomNormalised *= randomNormalised;
    randomNormalised *= beltWidth;
    float orbitRadius = currentRadius + random(-randomNormalised, randomNormalised);
    float bodySize = random(1, 2);
    float bodySpeed = random(0.01f, 0.03f);
    Body body = new Body(new Vector2(_xCenter, _yCenter), bodySize, bodySpeed, orbitRadius);
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
  float textScale = height / 1080f;
  float textSize = textScale * 40;
  float xWidth = (_currentName.length() * textSize) / 2.5f;
  float lineOffset = 100 * textScale;
  float textOffset = 85 * textScale;
  line(_xCenter - xWidth, height - lineOffset, _xCenter + xWidth, height - lineOffset);
  textSize(textSize);
  textAlign(CENTER, TOP);
  text(_currentName, _xCenter, height - textOffset);
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
      float lerpVal = distance / _systemWidth;
      lerpVal += random(-0.02f, 0.02f);
      if(lerpVal < 0) lerpVal = 0;
      else if (lerpVal > 1) lerpVal = 1;
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
     PlanetColour = GetBodyColor(_orbitRadius);
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

  public Planet(Vector2 origin, float size, float speed, float orbitRadius, boolean createSatellites) {
    super(origin, size, speed, orbitRadius);
    float lerpVal = (size - _minPlanetSize) / (_maxPlanetSize - _minPlanetSize);
    if (lerpVal > 1) lerpVal = 1;
    int colourVal = (int)lerp(120, 180, lerpVal);
    _fadedRingColour = GreyscaleColor(colourVal, 0);
    _pathLength = random(45, 360);
    if(!createSatellites) return;
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
      Planet moon = new Planet(Position, size, speed, radius, false);
      moon.PlanetColour = PlanetColour; 
      _bodies.add(moon);
    }
  }

  private void CreateRings() {
    int ringCount = (int)floor(random(1, 3));
    float radius = _size + random(5, 10);
    for (int i = 0; i < ringCount; ++i) {
      float size = random(1, 2);
      radius += random(size + 5, size + 10);
      Ring ring = new Ring(Position, size, radius);
      ring.Colour = PlanetColour; 
      _rings.add(ring);
    }
  }

  public void Draw() {
    super.Draw();
    DrawOrbitPath();
    for (Ring ring : _rings) {
      ring.Draw();
    }
  }

  private void DrawOrbitPath() {
    noFill();
    strokeWeight(1);
    beginShape();
    for (float angleOffset = 0; angleOffset < _pathLength; ++angleOffset) {
      float angle = _currentAngle;
      if(_speed < 0) angle += angleOffset;
      else angle -= angleOffset;
      float currentX = GetX(angle);
      float currentY = GetY(angle);
      float lerpVal = angleOffset / _pathLength;
      color lineColour = lerpColor(PlanetColour, _fadedRingColour, lerpVal);
      stroke(lineColour);
      vertex(currentX, currentY);
    }
    endShape();
  }
}
