void setPerspectiveVecs() {
  if (mousePressed && imageReady) {
    for (int i = 0; i < perspectiveVecs.size(); i++) {
      if (dist(mouseX, mouseY, perspectiveVecs.get(i).x, perspectiveVecs.get(i).y)<50) {
        perspectiveVecs.get(i).set(mouseX, mouseY);
        opencv.toPImage(warpPerspective(perspectiveVecs, outputWidth, outputHeight), output);
      }
    }
    savePerspectiveVecs();
  }
}

void loadPerspectiveVecs() {
  table = loadTable("data.csv", "header");  
  //println(table.getRowCount());
  for (TableRow row : table.rows()) {
    float x = row.getInt(0);
    float y = row.getInt(1);
    perspectiveVecs.add(new PVector(x, y)); 
  }
  
  /*Order of the Vectors seems to be important...?
   1------0          
   |      |
   2------3
   
  perspectiveVecs.add(new PVector(500.0, 10.0));   //0: Top right
  perspectiveVecs.add(new PVector(10.0, 10.0));    //1: Top left
  perspectiveVecs.add(new PVector(10.0, 350.0));   //2: Bottom right
  perspectiveVecs.add(new PVector(500.0, 350.0));  //3: Bottom left
  */
}

void savePerspectiveVecs() {
  table = new Table();
  table.addColumn("x", Table.INT);
  table.addColumn("y", Table.INT);

  for (int i = 0; i<4; i++) {
    TableRow row = table.addRow();
    row.setInt("x", (int) perspectiveVecs.get(i).x);
    row.setInt("y", (int) perspectiveVecs.get(i).y);
  }
  saveTable(table, "data/data.csv");  
}
