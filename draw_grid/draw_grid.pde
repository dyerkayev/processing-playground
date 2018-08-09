
import java.util.Map;
import java.util.Set;
import controlP5.*;

ControlP5 cp5;
RadioButton materialButtons;


public static int SQUARE_SIZE = 512;
public static int UI_COLUMN_WIDTH = 120;
public static int UI_MARGIN = 8;

public static int GRID_MULTIPLIER = 8;
public static int GRID_STEP = 8;

public static int GRID_CELL_SIZE = GRID_MULTIPLIER * GRID_STEP;
public static int GRID_OFFSET = GRID_CELL_SIZE / 2; 
public static int NUM_CELLS_XZ = (SQUARE_SIZE - 2 * GRID_OFFSET) / GRID_CELL_SIZE; 

public static HashMap<Integer, Integer> materialColors = new HashMap<Integer, Integer>();
public static int[] gridMaterials = new int[NUM_CELLS_XZ * NUM_CELLS_XZ];

public int selectedMaterial = 255;
public boolean drawInterpolatedGrid = true;


public void settings() {
  size(SQUARE_SIZE + UI_COLUMN_WIDTH, SQUARE_SIZE, P2D);
  smooth(0);
}

void setup() {
/*  cp5 = new ControlP5(this);
  
  cp5.addButton("testButton")
    .setValue(0)
    .setPosition(100, 100)
    .setSize(200,29)
    ;*/
    
    materialColors.put(255, color(65));
    materialColors.put(1, color(204, 252, 156));
    materialColors.put(2, color(73, 239, 55));
    materialColors.put(3, color(55, 239, 208));
    materialColors.put(4, color(166, 116, 242));

    materialColors.put(0, color(255, 0, 0));

    cp5 = new ControlP5(this);
    materialButtons = cp5.addRadioButton("materialsRadioGroup")
         .setPosition(SQUARE_SIZE + UI_MARGIN, UI_MARGIN)
         .setSize(20,20)
         .setColorForeground(color(120))
         .setColorActive(color(124, 124, 124, 200))
         .setColorLabel(color(255))
         .setItemsPerRow(5)
         .setSpacingColumn(1)
         .addItem("255",255)
         .addItem("1",1)
         .addItem("2",2)
         .addItem("3",3)
         .addItem("4",4)
         ;
     
     materialButtons.getItem("255").setColorBackground(materialColors.get(255));
     materialButtons.getItem("1").setColorBackground(materialColors.get(1));
     materialButtons.getItem("2").setColorBackground(materialColors.get(2));
     materialButtons.getItem("3").setColorBackground(materialColors.get(3));
     materialButtons.getItem("4").setColorBackground(materialColors.get(3));
     
     //fill out materials array
     
     for (int index = 0; index < NUM_CELLS_XZ * NUM_CELLS_XZ; index++)
       gridMaterials[index] = 0;
}

void materialsRadioGroup(int value)
{
  selectedMaterial = value; //<>//
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == CONTROL) {
      if (drawInterpolatedGrid)
        drawInterpolatedGrid = false;
      else
        drawInterpolatedGrid = true;
    } 
  }
}

//interpolate material above the grid at the point given by x, y
int interpolateMaterial(int x, int y, boolean debug)
{
  //pick grid cell
  int xIndex = (x - GRID_OFFSET) / GRID_CELL_SIZE;
  
  if (xIndex >= NUM_CELLS_XZ)
    return 0;
  
  int yIndex = (y - GRID_OFFSET) / GRID_CELL_SIZE; 

  if (yIndex >= NUM_CELLS_XZ)
    return 0;

  int index = xIndex + NUM_CELLS_XZ * yIndex;
  
  if (index >= 0 && index < NUM_CELLS_XZ * NUM_CELLS_XZ)
  {
    //highlight the grid cell
    int cellMinX = xIndex * GRID_CELL_SIZE + GRID_OFFSET;
    int cellMinY = yIndex * GRID_CELL_SIZE + GRID_OFFSET;
    int cellMaxX = cellMinX + GRID_CELL_SIZE;
    int cellMaxY = cellMinY + GRID_CELL_SIZE;
    int cellMidX = (cellMinX + cellMaxX) / 2;
    int cellMidY = (cellMinY + cellMaxY) / 2;

    if (debug) {
      //draw a pale cross in the cell
      stroke(142, 147, 155);
      line(cellMidX, cellMinY, cellMidX, cellMaxY);  
      line(cellMinX, cellMidY, cellMaxX, cellMidY);  
    }
    //find the normalized position in the chosen cell
    float deltaX = (float)(x - cellMidX);
    float deltaY = (float)(y - cellMidY);

    float tx = 0.f;
    float ty = 0.f;
    
    //if (deltaX >= 0.f && deltaY >= 0.f)
     //upperright cell
    int x0 = cellMidX;
    int y0 = cellMidY;
    int x1 = cellMidX + GRID_CELL_SIZE;
    int y1 = cellMidY + GRID_CELL_SIZE;
    
    if (deltaX >= 0.f && deltaY < 0.f)
    {
      //lowerright
      x0 = cellMidX;
      y0 = cellMidY - GRID_CELL_SIZE;
      x1 = cellMidX + GRID_CELL_SIZE;
      y1 = cellMidY;
    }
    else if (deltaX < 0.f && deltaY >= 0.f)
    {
      //upperleft
      x0 = cellMidX - GRID_CELL_SIZE;
      y0 = cellMidY;
      x1 = cellMidX;
      y1 = cellMidY + GRID_CELL_SIZE;
    }
    else if (deltaX < 0.f && deltaY < 0.f)
    {
      //lowerleft
      x0 = cellMidX - GRID_CELL_SIZE;
      y0 = cellMidY - GRID_CELL_SIZE;
      x1 = cellMidX;
      y1 = cellMidY;
    }

    tx = (float)(x - x0) / (float)(x1 - x0);
    ty = (float)(y - y0) / (float)(y1 - y0);      
    
    //debug for tx and ty
    if (debug) {
      String debugString = String.format("(%.3f,%.3f)", tx, ty);
      fill(0);
      textSize(12);
      text(debugString, SQUARE_SIZE + UI_MARGIN, 60);      
    }
    
    //get cell materials
    int cellIndexX = (x0 - GRID_CELL_SIZE / 2 ) / GRID_CELL_SIZE;
    int cellIndexY = (y0 - GRID_CELL_SIZE / 2) / GRID_CELL_SIZE;
    int[] materials = new int[4];    
    
    int cellIndexX0 = cellIndexX;
    int cellIndexX1 = cellIndexX + 1;
    int cellIndexY0 = cellIndexY;
    int cellIndexY1 = cellIndexY + 1;

    cellIndexX0 = constrain(cellIndexX0, 0, NUM_CELLS_XZ - 1); 
    cellIndexX1 = constrain(cellIndexX1, 0, NUM_CELLS_XZ - 1);
    cellIndexY0 = constrain(cellIndexY0, 0, NUM_CELLS_XZ - 1);
    cellIndexY1 = constrain(cellIndexY1, 0, NUM_CELLS_XZ - 1);
    
    if (debug) {
      fill(255, 0, 0);
      
      String cellDebugText = String.format("%d, %d, %d, %d", cellIndexX0, cellIndexY0, cellIndexX1, cellIndexY1);
      textSize(10);
      text(cellDebugText, SQUARE_SIZE + UI_MARGIN, 80);
      
      markGridCell(cellIndexX0, cellIndexY0);
      markGridCell(cellIndexX1, cellIndexY0);
      markGridCell(cellIndexX0, cellIndexY1);
      markGridCell(cellIndexX1, cellIndexY1);
    }
    
    materials[0] = getCellMaterial(cellIndexX0, cellIndexY0);    
    materials[1] = getCellMaterial(cellIndexX1, cellIndexY0);
    materials[2] = getCellMaterial(cellIndexX0, cellIndexY1);
    materials[3] = getCellMaterial(cellIndexX1, cellIndexY1);

    //calculate weights
    float[] weights = new float[4];
    weights[0] = (1.f - tx) * (1.f - ty);
    weights[1] = tx * (1.f - ty);
    weights[2] = (1.f - tx) * ty;
    weights[3] = tx * ty;
    
    if (debug) {
      String materialWeightsString = String.format("Material weights:\n%d: %.3f, %d: %.3f \n%d: %.3f, %d: %.3f", 
        materials[0], weights[0], materials[1], weights[1], materials[2], weights[2], materials[3], weights[3]);
      //merge material weights
      textSize(10);
      text(materialWeightsString, SQUARE_SIZE + UI_MARGIN, 100);
    }
    
    float[] mergedWeights = new float[4];
    for (int materialIndex = 0; materialIndex < 4; materialIndex++)
    {
      int material = materials[materialIndex];

      if (material >=0) //valid material
      {
        float materialWeight = 0.f;
        for (int weightIndex = 0; weightIndex < 4; weightIndex++)
        {
          if (materials[weightIndex] == material)
            materialWeight += weights[weightIndex];
        }
        
        mergedWeights[materialIndex] = materialWeight;
      }
    }
    
    if (debug) {
      String mergedWeightsString = String.format("Merged weights:\n%d: %.3f, %d: %.3f \n%d: %.3f, %d: %.3f", 
         materials[0], mergedWeights[0], materials[1], mergedWeights[1], materials[2], mergedWeights[2], materials[3], mergedWeights[3]);
      textSize(10);
      text(mergedWeightsString, SQUARE_SIZE + UI_MARGIN, 160);
    }

   
    float highestMaterialWeight = 0.f;
    int chosenMaterial = 0;
    
    for (int materialIndex = 0; materialIndex < 4; materialIndex++)
    {
      int material = materials[materialIndex];

      if (material >=0) //valid material
      {
        float materialWeight = mergedWeights[materialIndex];
        if (materialWeight > highestMaterialWeight)
        {
          highestMaterialWeight = materialWeight;
          chosenMaterial = material;
        }
      }
    }
    
    if (debug) {
      String chosenMaterialText = String.format("Winner material:\n%d (%f)", chosenMaterial, highestMaterialWeight);
      text(chosenMaterialText, SQUARE_SIZE + UI_MARGIN, 220);
      //draw a tiny cross with selected material color
      int pointX = x0 + (int)(tx * (float)GRID_CELL_SIZE);
      int pointY = y0 + (int)(ty * (float)GRID_CELL_SIZE);
    
      stroke(materialColors.containsKey(chosenMaterial) ? materialColors.get(chosenMaterial) : color(255, 0, 0));
      line(pointX - 4, pointY, pointX + 4, pointY);
      line(pointX, pointY - 4, pointX, pointY + 4); 
    }
    
    return chosenMaterial;
  }
  
  return 0;
}

public int getCellMaterial(int xIndex, int yIndex)
{
    if (xIndex >= NUM_CELLS_XZ)
      return -1;
      
    if (yIndex >= NUM_CELLS_XZ)
      return -1;
      
    int index = xIndex + NUM_CELLS_XZ * yIndex;
    if (index >= 0 && index < NUM_CELLS_XZ * NUM_CELLS_XZ)
    {
      return gridMaterials[index];
    }
    
    return -1;
}

//returns cell index if there was a hit, or -1 if no hit
public int pickGridCell(int x, int y) {
  int xIndex = (x - GRID_OFFSET) / GRID_CELL_SIZE;
  
  if (xIndex >= NUM_CELLS_XZ)
    return -1;
  
  int yIndex = (y - GRID_OFFSET) / GRID_CELL_SIZE; 

  if (yIndex >= NUM_CELLS_XZ)
    return -1;
  
  int index = xIndex + NUM_CELLS_XZ * yIndex;
  
  if (index >= 0 && index < NUM_CELLS_XZ * NUM_CELLS_XZ)
    return index;
    
  return -1;
}

public void fillGridCell(int cellIndex) {
  int yIndex = cellIndex / NUM_CELLS_XZ; 
  int xIndex = cellIndex - yIndex * NUM_CELLS_XZ;

  rect(xIndex * GRID_CELL_SIZE + GRID_OFFSET, yIndex * GRID_CELL_SIZE + GRID_OFFSET, GRID_CELL_SIZE, GRID_CELL_SIZE);
}

public void markGridCell(int xIndex, int yIndex) {
  ellipse(xIndex * GRID_CELL_SIZE + GRID_OFFSET + GRID_CELL_SIZE / 2, yIndex * GRID_CELL_SIZE + GRID_OFFSET + GRID_CELL_SIZE / 2, 4, 4);
}

void drawInterpolatedMaterials(int cellSize) {
  stroke(234, 247, 153);

  // fill grid cells
  int numCellsXZ = (SQUARE_SIZE - 2 * GRID_OFFSET) / cellSize;
  
  for (int xIndex = 0; xIndex < numCellsXZ; xIndex++) {
    for (int yIndex = 0; yIndex < numCellsXZ; yIndex++) {
      int materialIndex = 0;
      int cellX = xIndex * cellSize + GRID_OFFSET + cellSize / 2;
      int cellY = yIndex * cellSize + GRID_OFFSET + cellSize / 2;
      
      materialIndex = interpolateMaterial(cellX, cellY, false);
      fill(materialColors.get(materialIndex));            

      rect(xIndex * cellSize + GRID_OFFSET, yIndex * cellSize + GRID_OFFSET, cellSize, cellSize);      
    }
   }
   
  for (int xStep = GRID_OFFSET; xStep <= SQUARE_SIZE - GRID_OFFSET; xStep += cellSize) {
    line(xStep, 0, xStep, SQUARE_SIZE);
  }
  
  for (int yStep = GRID_OFFSET; yStep <= SQUARE_SIZE - GRID_OFFSET; yStep += cellSize) {
    line(0, yStep, SQUARE_SIZE, yStep);
  }

}

public void draw() {
  background(255, 255, 255);
  //background(204, 252, 156);
  
  int gridStep = GRID_CELL_SIZE;

  fill(0, 0, 156);
  rect(0,0,SQUARE_SIZE, SQUARE_SIZE);
  stroke(242, 247, 255);

  for (int xStep = GRID_OFFSET; xStep <= SQUARE_SIZE; xStep += gridStep) {
    line(xStep, 0, xStep, SQUARE_SIZE);
  }
  
  for (int yStep = GRID_OFFSET; yStep <= SQUARE_SIZE; yStep += gridStep) {
    line(0, yStep, SQUARE_SIZE, yStep);
  }   


  //color the grid
  for (int xIndex = 0; xIndex < NUM_CELLS_XZ; xIndex++)
    for (int yIndex = 0; yIndex < NUM_CELLS_XZ; yIndex++)
    {
      int materialIndex = gridMaterials[xIndex + yIndex * NUM_CELLS_XZ];
      fill(materialColors.get(materialIndex));
      
      rect(xIndex * GRID_CELL_SIZE + GRID_OFFSET, yIndex * GRID_CELL_SIZE + GRID_OFFSET, GRID_CELL_SIZE, GRID_CELL_SIZE);      
    }
    
  //check what cell mouse is on, and if pressed, set the cell to current selected material
  if (mousePressed)  
  {
    int cellIndex = pickGridCell(mouseX, mouseY);
    fill(15);
    if (cellIndex >= 0)
      gridMaterials[cellIndex] = selectedMaterial;
  }
  
    //highlight the cell
  interpolateMaterial(mouseX, mouseY, true); 

  // now let's look at things as an integer grid
  int gridSize = (SQUARE_SIZE - 2 * GRID_OFFSET) / gridStep;
  int textOffset = 2;
  textSize(8);
  for (int xIndex = 0; xIndex <= gridSize; xIndex++) {
    for (int yIndex = 0; yIndex <= gridSize; yIndex++) {
      int nodeX = xIndex * gridStep + GRID_OFFSET;
      int nodeY = yIndex * gridStep + GRID_OFFSET;
      
 //     fill (242, 247, 255);      
 //     ellipse(nodeX, nodeY, 8, 8);
      
      fill(0, 102, 153, 204);
      String nodeString = String.format("(%d,%d)", xIndex, yIndex);
      text(nodeString, nodeX + textOffset, nodeY - textOffset);
    }
  }
  
  if (drawInterpolatedGrid)
    drawInterpolatedMaterials(GRID_CELL_SIZE / 4); //<>//
  
} 
