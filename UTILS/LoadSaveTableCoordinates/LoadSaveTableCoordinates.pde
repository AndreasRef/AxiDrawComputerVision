Table table;

void setup() {
  size(640, 360);
  loadData();
}

void draw() {

}

void loadData() {
  table = loadTable("data.csv", "header");
  for (TableRow row : table.rows()) {
    float x = row.getFloat("x");
    float y = row.getFloat("y");    
    ellipse(x, y, 10, 10);
  }
}

void mousePressed() {
  // Create a new row
  TableRow row = table.addRow();
  // Set the values of that row
  row.setInt("x", mouseX);
  row.setInt("y", mouseY);


  // If the table has more than 10 rows
  if (table.getRowCount() > 10) {
    // Delete the oldest row
    table.removeRow(0);
  }

  // Writing the CSV back to the same file
  saveTable(table, "data/data.csv");
  // And reloading it
  loadData();
}
