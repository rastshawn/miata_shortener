class RowToRemove {
  int shiftDirection;
  int column;

  public RowToRemove(int column, int shiftDirection) {
    this.column = column;
    this.shiftDirection = shiftDirection;
    //this.shiftDirection = -1;
  }
}

PImage img; 
PImage newImg;
void setup() {
  //img = loadImage("na miata quarter.jpg"); 
  //img = loadImage("IMG_0194.JPG");
  img = loadImage("na miata profile.jpg");
  //img = loadImage("head-on.jpg");
  //img = loadImage("mustang.jpg");
  size(1920, 1080);
  img.pixels[0] = color(255, 255, 255);

  newImg = removeRow(img);

}


int cycles = 0;
void draw() {
  if (cycles < 9*img.width/10) {

    println("CYCLE " + cycles);
    newImg = removeRow(newImg); 
    newImg.updatePixels();
    background(0);
    cycles++;
    image(newImg, 0, 0, 2*newImg.width/3, 2*newImg.height/3);
  }
}

PImage removeRow(PImage original) {

  ArrayList<RowToRemove> rowsToRemove = new ArrayList<RowToRemove>();
  int columns = original.width;

  double lowestDiffValue = Double.POSITIVE_INFINITY;



  // find the best column to remove
  for (int i = 0; i<columns-2; i++) {
    color[] currentColumn = new color[original.height];
    color[] nextColumn = new color[original.height];

    for (int j = 0; j<original.height; j++) {
      currentColumn[j] = original.pixels[i + j*original.width];
      nextColumn[j] = original.pixels[i + 2 + j*original.width]; // +2 because we're skipping the middle column
    }


    int shiftDown = compareShiftDown(currentColumn, nextColumn);
    int noShift = compare(currentColumn, nextColumn);
    int shiftUp = compareShiftUp(currentColumn, nextColumn);

    // 0 = no shift, -1 = shift down (left side higher), 1 = shift up (right side higher)
    int shiftDirection = 0;

    // find the best of the three
    int min = min(shiftDown, noShift, shiftUp);

    if (min == shiftDown) {
      shiftDirection = -1;
    } else if (min == shiftUp) {
      shiftDirection = 1;
    }

    // prefer no shift to a shift
    if (min == noShift) {
      shiftDirection = 0;
    }

    if (min < lowestDiffValue) {
      lowestDiffValue = min;
      int columnToRemove = i+1;

      rowsToRemove = new ArrayList<RowToRemove>();
      rowsToRemove.add(new RowToRemove(columnToRemove, shiftDirection));
    } else if (min == lowestDiffValue) {
      int columnToRemove = i+1;
      rowsToRemove.add(new RowToRemove(columnToRemove, shiftDirection));
    }
  }

  int randomIndex = (int) random(0, rowsToRemove.size());
  RowToRemove r = rowsToRemove.get(randomIndex);
  int shiftDirection = r.shiftDirection;
  int columnToRemove = r.column;
  PImage ret;
  if (shiftDirection != 0) {
    ret = new PImage(original.width-1, original.height-1);
  } else {
    ret = new PImage(original.width-1, original.height);
  }

  // copy half of image pre-column to be removed
  for (int i = 0; i<columnToRemove; i++) {
    for (int j = 0; j<ret.height; j++) {
      if (shiftDirection == -1) {
        ret.pixels[i + j*ret.width] = original.pixels[i + j*original.width+original.width];
      } else {
        ret.pixels[i + j*ret.width] = original.pixels[i + j*original.width];
      }
    }
  }

  // copy second half of image
  for (int i = columnToRemove + 1; i < ret.width; i++) {
    for (int j = 0; j< ret.height; j++) {
      if (shiftDirection == -1) {
        ret.pixels[(i - 1) + j*ret.width] = original.pixels[i + ((j)*original.width)];
      } else {
        ret.pixels[(i - 1) + j*ret.width] = original.pixels[i + ((j)*original.width) + (original.width*shiftDirection)];
      }
    }
  }

  ret.updatePixels();
  return ret;
}

int compareShiftDown(color[] a, color[] b) {
  color[] newA = new color[a.length - 1];
  color[] newB = new color[b.length - 1];

  for (int i = 0; i< a.length-1; i++) {
    newA[i] = a[i+1];
    newB[i] = b[i];
  }
  return compare(newA, newB);
}

int compareShiftUp(color[] a, color[] b) {
  color[] newA = new color[a.length - 1];
  color[] newB = new color[b.length - 1];

  for (int i = 0; i< a.length - 1; i++) {
    newA[i] = a[i];
    newB[i] = b[i+1];
  }
  return compare(newA, newB);
}

// find the total pixel-to-pixel difference from one pixel array to another
int compare(color[] a, color[] b) {
  // todo make sure same length
  int totalDifference = 0;
  for (int i = 0; i<a.length; i++) {
    color aColor = a[i];
    color bColor = b[i];
    int ar = (aColor >> 16) & 0xFF;
    int ag = (aColor >> 8) & 0xFF;
    int ab = aColor & 0xFF;
    int br = (bColor >> 16) & 0xFF;
    int bg = (bColor >> 8) & 0xFF;
    int bb = bColor & 0xFF;

    int pixelDiff = abs(ar-br) + abs(ag-bg) + abs(ab-bb);
    totalDifference += pixelDiff;
  }
  return totalDifference / a.length;
}
