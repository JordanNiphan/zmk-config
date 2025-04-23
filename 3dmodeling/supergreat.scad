// Keyboard Layout Visualization in OpenSCAD

// --- Constants ---
u = 19;         // Standard key unit size (mm)
gap = 1;        // Gap between keys (actual key dimension = u - gap)
key_height = 8; // Height of the keycap base
text_depth = 0.5; // How much the text sticks out from the surface
text_size = 3.5;  // Font size for legends
key_color = [0.8, 0.8, 0.8]; // Light grey for keycaps
text_color = [0.1, 0.1, 0.1]; // Dark grey/black for text
font = "Liberation Sans:style=Bold"; // Choose a font available on your system

// --- Key Data ---
// Format: [ TopLegend, BottomLegend, x_start_units, y_row_index, width_units ]
// Derived from the input structure.
key_data = [
  // Row 0 (y=0) - Function/Number Row
  [ "~", "`", 0, 0, 1 ], [ "!", "1", 1, 0, 1 ], [ "@", "2", 2, 0, 1 ], [ "#", "3", 3, 0, 1 ], [ "$", "4", 4, 0, 1 ], [ "%", "5", 5, 0, 1 ], [ "^", "6", 6, 0, 1 ], [ "&", "7", 7, 0, 1 ], [ "*", "8", 8, 0, 1 ], [ "(", "9", 9, 0, 1 ], [ ")", "0", 10, 0, 1 ], [ "_", "-", 11, 0, 1 ], [ "+", "=", 12, 0, 1 ], [ "", "Backspace", 13, 0, 2 ],
  // Row 1 (y=-1) - QWERTY Row
  [ "", "Tab", 0, -1, 1.5 ], [ "", "Q", 1.5, -1, 1 ], [ "", "W", 2.5, -1, 1 ], [ "", "E", 3.5, -1, 1 ], [ "", "R", 4.5, -1, 1 ], [ "", "T", 5.5, -1, 1 ], [ "", "Y", 6.5, -1, 1 ], [ "", "U", 7.5, -1, 1 ], [ "", "I", 8.5, -1, 1 ], [ "", "O", 9.5, -1, 1 ], [ "", "P", 10.5, -1, 1 ], [ "{", "[", 11.5, -1, 1 ], [ "}", "]", 12.5, -1, 1 ], [ "|", "\\", 13.5, -1, 1.5 ],
  // Row 2 (y=-2) - ASDF Row (Home)
  [ "", "Caps Lock", 0, -2, 1.75 ], [ "", "A", 1.75, -2, 1 ], [ "", "S", 2.75, -2, 1 ], [ "", "D", 3.75, -2, 1 ], [ "", "F", 4.75, -2, 1 ], [ "", "G", 5.75, -2, 1 ], [ "", "H", 6.75, -2, 1 ], [ "", "J", 7.75, -2, 1 ], [ "", "K", 8.75, -2, 1 ], [ "", "L", 9.75, -2, 1 ], [ ":", ";", 10.75, -2, 1 ], [ "\"", "'", 11.75, -2, 1 ], [ "", "Enter", 12.75, -2, 2.25 ],
  // Row 3 (y=-3) - ZXCV Row
  [ "", "Shift", 0, -3, 2.25 ], [ "", "Z", 2.25, -3, 1 ], [ "", "X", 3.25, -3, 1 ], [ "", "C", 4.25, -3, 1 ], [ "", "V", 5.25, -3, 1 ], [ "", "B", 6.25, -3, 1 ], [ "", "N", 7.25, -3, 1 ], [ "", "M", 8.25, -3, 1 ], [ "<", ",", 9.25, -3, 1 ], [ ">", ".", 10.25, -3, 1 ], [ "?", "/", 11.25, -3, 1 ], [ "", "Shift", 12.25, -3, 2.75 ],
  // Row 4 (y=-4) - Bottom Modifiers Row
  [ "", "Ctrl", 0, -4, 1.25 ], [ "", "Win", 1.25, -4, 1.25 ], [ "", "Alt", 2.5, -4, 1.25 ], [ "", "", 3.75, -4, 6.25 ], // Space bar (no legend)
  [ "", "Alt", 10, -4, 1.25 ], [ "", "Win", 11.25, -4, 1.25 ], [ "", "Menu", 12.5, -4, 1.25 ], [ "", "Ctrl", 13.75, -4, 1.25 ]
];

// --- Module to draw a single keycap ---
module keycap(top_lg = "", btm_lg = "", width_u = 1, depth_u = 1, pos = [0,0,0]) {
    key_w = width_u * u - gap;
    key_d = depth_u * u - gap;

    // Calculate center position for the key relative to its bottom-left corner (pos)
    center_x = pos[0] + (width_u * u / 2);
    center_y = pos[1] + (depth_u * u / 2); // OpenSCAD Y is depth
    center_z = pos[2] + key_height / 2;

    // Position for text on top surface
    text_pos_z = pos[2] + key_height + 0.01; // Place slightly above surface

    translate([center_x, center_y, center_z]) {
        // Keycap Base
        color(key_color)
            cube([key_w, key_d, key_height], center=true);

        // Determine Legend Positions
        has_top = (top_lg != "");
        has_btm = (btm_lg != "");
        text_y_offset = (has_top && has_btm) ? key_d * 0.22 : 0; // Offset for two lines
        btm_text_y = (has_top && has_btm) ? -text_y_offset : 0;
        top_text_y = (has_btm && has_top) ? text_y_offset : (has_top ? 0 : btm_text_y); // Center single legend

        // Bottom Legend Text
        if (has_btm) {
            translate([0, btm_text_y, key_height/2 + text_depth/2]) // Adjusted Z for text depth
            color(text_color)
            linear_extrude(height = text_depth, center=true) // Extrude text
                text(btm_lg, size = text_size, halign = "center", valign = "center", font = font);
        }

        // Top Legend Text
        if (has_top) {
             translate([0, top_text_y, key_height/2 + text_depth/2]) // Adjusted Z for text depth
             color(text_color)
             linear_extrude(height = text_depth, center=true) // Extrude text
                text(top_lg, size = text_size, halign = "center", valign = "center", font = font);
        }
    }
}


// --- Main part - Generate all keys ---
module keyboard() {
     for (key = key_data) {
        top_lg = key[0];
        btm_lg = key[1];
        x_pos_u = key[2];
        y_row_idx = key[3]; // Use negative index directly
        width_u = key[4];

        // Calculate bottom-left position for the key
        // We use negative Y to match screen coordinates (top row is y=0)
        key_pos = [ x_pos_u * u, y_row_idx * u, 0 ];

        keycap(top_lg, btm_lg, width_u, 1, key_pos); // Assuming depth_u is always 1
    }
}



// --- Render the keyboard ---
keyboard();

// Optional: Add a base plate (uncomment to see)
/*
 module base_plate(rows=5, total_width_u=15) {
     plate_width = total_width_u * u + gap;
     plate_depth = rows * u + gap;
     plate_thickness = 2;
     
     translate([-gap/2, - (rows * u) + u - gap/2, -plate_thickness]) {
        color([0.3, 0.3, 0.3]) 
            cube([plate_width, plate_depth, plate_thickness]);
     }
 }
 
 base_plate(5, 15); // Adjust parameters if layout changes significantly
*/



// Keyboard Layout Visualization in OpenSCAD - Left Hand Keys Only

// --- Constants ---
u = 19;         // Standard key unit size (mm)
gap = 1;        // Gap between keys (actual key dimension = u - gap)
key_height = 8; // Height of the keycap base
key_color = [0.8, 0.8, 0.8]; // Light grey for keycaps
hole_size = 14; // Size of the square hole side (mm)

// --- Left Hand Key Data ---
// Format: [ "", "", x_start_units, y_row_index, width_units ]
// Contains only keys typically typed by the left hand.
left_key_data = [
  // Row 0 (y=0)
  [ "", "", 0, 0, 1 ], [ "", "", 1, 0, 1 ], [ "", "", 2, 0, 1 ], [ "", "", 3, 0, 1 ], [ "", "", 4, 0, 1 ], [ "", "", 5, 0, 1 ], [ "", "", 6, 0, 1 ],
  // Row 1 (y=-1)
  [ "", "", 0, -1, 1.5 ], [ "", "", 1.5, -1, 1 ], [ "", "", 2.5, -1, 1 ], [ "", "", 3.5, -1, 1 ], [ "", "", 4.5, -1, 1 ], [ "", "", 5.5, -1, 1 ],
  // Row 2 (y=-2)
  [ "", "", 0, -2, 1.75 ], [ "", "", 1.75, -2, 1 ], [ "", "", 2.75, -2, 1 ], [ "", "", 3.75, -2, 1 ], [ "", "", 4.75, -2, 1 ], [ "", "", 5.75, -2, 1 ],
  // Row 3 (y=-3)
  [ "", "", 0, -3, 2.25 ], [ "", "", 2.25, -3, 1 ], [ "", "", 3.25, -3, 1 ], [ "", "", 4.25, -3, 1 ], [ "", "", 5.25, -3, 1 ], [ "", "", 6.25, -3, 1 ],
  // Row 4 (y=-4)
  [ "", "", 0, -4, 1.25 ], [ "", "", 1.25, -4, 1.25 ], [ "", "", 2.5, -4, 1.25 ],
  [ "", "", 3.75, -4, 3.5 ] // Left part of Space bar
];

// --- Module to draw a single keycap ---
module keycap(width_u = 1, depth_u = 1, pos = [0,0,0]) {
    key_w = width_u * u - gap;
    key_d = depth_u * u - gap;

    // Calculate center position for the key relative to its bottom-left corner (pos)
    center_x = pos[0] + (width_u * u / 2);
    center_y = pos[1] + (depth_u * u / 2); // OpenSCAD Y is depth
    center_z = pos[2] + key_height / 2;

    translate([center_x, center_y, center_z]) {
        // Use difference() to subtract the hole from the keycap base
        difference() {
            // Keycap Base Cube
            color(key_color)
                cube([key_w, key_d, key_height], center=true);

            // Square prism (cube) for the hole
            // Make it slightly taller than key_height to ensure clean cut
            cube([hole_size, hole_size, key_height + 2], center=true);
        }
    }
}


// --- Main part - Generate Left Hand keys ---
module keyboard() {
     // Iterate over the left_key_data only
     for (key = left_key_data) {
        x_pos_u = key[2];
        y_row_idx = key[3]; // Use negative index directly
        width_u = key[4];

        // Calculate bottom-left position for the key
        key_pos = [ x_pos_u * u, y_row_idx * u, 0 ];

        // Call keycap
        keycap(width_u, 1, key_pos); // Assuming depth_u is always 1
    }
}

// --- Render the keyboard ---
keyboard();

// Optional: Add a base plate (uncomment to see and adjust)
/*
 module base_plate(key_data_array, rows = 5) {
     min_x_u = min([for (k = key_data_array) k[2]]);
     max_x_u = max([for (k = key_data_array) k[2] + k[4]]);
     min_y_u = min([for (k = key_data_array) k[3]]); // Find the lowest row index
     max_y_u = max([for (k = key_data_array) k[3]]); // Should be 0 for the top row

     plate_width = (max_x_u - min_x_u) * u + gap;
     // Depth calculation needs care with negative indices
     plate_depth = (max_y_u - min_y_u + 1) * u + gap;
     plate_thickness = 2;
     origin_x = min_x_u * u - gap/2;
     origin_y = min_y_u * u - gap/2; // Start at the bottom edge of the lowest row

     translate([origin_x, origin_y, -plate_thickness]) {
        color([0.3, 0.3, 0.3])
            cube([plate_width, plate_depth, plate_thickness]);
     }
 }

 base_plate(left_key_data, 5); // Call base_plate with the left hand data
*/



// Keyboard Layout Visualization in OpenSCAD - Right Hand Keys Only

// --- Constants ---
u = 19;         // Standard key unit size (mm)
gap = 1;        // Gap between keys (actual key dimension = u - gap)
key_height = 8; // Height of the keycap base
key_color = [0.8, 0.8, 0.8]; // Light grey for keycaps
hole_size = 14; // Size of the square hole side (mm)

// --- Right Hand Key Data ---
// Format: [ "", "", x_start_units, y_row_index, width_units ]
// Contains only keys typically typed by the right hand.
right_key_data = [
  // Row 0 (y=0)
  [ "", "", 7, 0, 1 ], [ "", "", 8, 0, 1 ], [ "", "", 9, 0, 1 ], [ "", "", 10, 0, 1 ], [ "", "", 11, 0, 1 ], [ "", "", 12, 0, 1 ], [ "", "", 13, 0, 2 ],
  // Row 1 (y=-1)
  [ "", "", 6.5, -1, 1 ], [ "", "", 7.5, -1, 1 ], [ "", "", 8.5, -1, 1 ], [ "", "", 9.5, -1, 1 ], [ "", "", 10.5, -1, 1 ], [ "", "", 11.5, -1, 1 ], [ "", "", 12.5, -1, 1 ], [ "", "", 13.5, -1, 1.5 ],
  // Row 2 (y=-2)
  [ "", "", 6.75, -2, 1 ], [ "", "", 7.75, -2, 1 ], [ "", "", 8.75, -2, 1 ], [ "", "", 9.75, -2, 1 ], [ "", "", 10.75, -2, 1 ], [ "", "", 11.75, -2, 1 ], [ "", "", 12.75, -2, 2.25 ],
  // Row 3 (y=-3)
  [ "", "", 7.25, -3, 1 ], [ "", "", 8.25, -3, 1 ], [ "", "", 9.25, -3, 1 ], [ "", "", 10.25, -3, 1 ], [ "", "", 11.25, -3, 1 ], [ "", "", 12.25, -3, 2.75 ],
  // Row 4 (y=-4)
  [ "", "", 7.25, -4, 2.75 ], // Right part of Space bar (original start 3.75 + left width 3.5 = 7.25)
  [ "", "", 10, -4, 1.25 ], [ "", "", 11.25, -4, 1.25 ], [ "", "", 12.5, -4, 1.25 ], [ "", "", 13.75, -4, 1.25 ]
];


// --- Module to draw a single keycap ---
module keycap(width_u = 1, depth_u = 1, pos = [0,0,0]) {
    key_w = width_u * u - gap;
    key_d = depth_u * u - gap;

    // Calculate center position for the key relative to its bottom-left corner (pos)
    center_x = pos[0] + (width_u * u / 2);
    center_y = pos[1] + (depth_u * u / 2); // OpenSCAD Y is depth
    center_z = pos[2] + key_height / 2;

    translate([center_x, center_y, center_z]) {
        // Use difference() to subtract the hole from the keycap base
        difference() {
            // Keycap Base Cube
            color(key_color)
                cube([key_w, key_d, key_height], center=true);

            // Square prism (cube) for the hole
            // Make it slightly taller than key_height to ensure clean cut
            cube([hole_size, hole_size, key_height + 2], center=true);
        }
    }
}


// --- Main part - Generate Right Hand keys ---
module keyboard() {
     // Iterate over the right_key_data only
     for (key = right_key_data) {
        x_pos_u = key[2];
        y_row_idx = key[3]; // Use negative index directly
        width_u = key[4];

        // Calculate bottom-left position for the key
        key_pos = [ x_pos_u * u, y_row_idx * u, 0 ];

        // Call keycap
        keycap(width_u, 1, key_pos); // Assuming depth_u is always 1
    }
}

// --- Render the keyboard ---
keyboard();

// Optional: Add a base plate (uncomment to see and adjust)
/*
 module base_plate(key_data_array, rows = 5) {
     min_x_u = min([for (k = key_data_array) k[2]]);
     max_x_u = max([for (k = key_data_array) k[2] + k[4]]);
     min_y_u = min([for (k = key_data_array) k[3]]); // Find the lowest row index
     max_y_u = max([for (k = key_data_array) k[3]]); // Should be 0 for the top row

     plate_width = (max_x_u - min_x_u) * u + gap;
     // Depth calculation needs care with negative indices
     plate_depth = (max_y_u - min_y_u + 1) * u + gap;
     plate_thickness = 2;
     origin_x = min_x_u * u - gap/2;
     origin_y = min_y_u * u - gap/2; // Start at the bottom edge of the lowest row

     translate([origin_x, origin_y, -plate_thickness]) {
        color([0.3, 0.3, 0.3])
            cube([plate_width, plate_depth, plate_thickness]);
     }
 }

 base_plate(right_key_data, 5); // Call base_plate with the right hand data
*/