#! /usr/bin/env python
# -*- coding: utf-8 -*-

from solid import *
from solid.utils import *

# ==========================
# Configuration
# ==========================

# --- Basic Units ---
U = 19.05  # Standard key unit size in mm
KEY_CUTOUT_SIZE = 14.0  # Size of the square hole for the switch
PLATE_THICKNESS = 1.5  # Thickness of the plate in mm

# --- Plate Design ---
PLATE_BORDER = 3.0  # Extra border around the outermost keys in mm
# INTER_HALF_SPACING is no longer needed as files are separate

# --- Layout Definition (Key Widths in U units) ---
# Define the layout for each half. Each inner list is a row.
# Modify these lists to match your desired 60% split layout.
# This example uses a 5x6 grid per side with common modifier widths.
left_layout_u = [
    [1,   1,    1,    1,    1,    1   ],  # Row 0 (Top: Esc, 1-5)
    [1.5, 1,    1,    1,    1,    1   ],  # Row 1 (Tab, QWERT)
    [1.75,1,    1,    1,    1,    1   ],  # Row 2 (Caps, ASDFG)
    [2.25,1,    1,    1,    1,    1   ],  # Row 3 (Shift, ZXCVB)
    [1.25,1.25, 1.25, 1,    1,    1.25],  # Row 4 (Bottom Mods/Thumb - Customize as needed)
]

right_layout_u = [
    [1,    1,    1,    1,    1,    1   ],  # Row 0 (Top: 6-0, -)
    [1,    1,    1,    1,    1,    1.5 ],  # Row 1 (YUIOP, Bksp)
    [1,    1,    1,    1,    1,    1.75],  # Row 2 (HJKL;, Enter)
    [1,    1,    1,    1,    1,    2.25],  # Row 3 (NM,./, Shift)
    [1.25, 1,    1,    1.25, 1.25, 1.25],  # Row 4 (Bottom Mods/Thumb - Customize as needed)
]

# --- Stagger Definition (Offset per row in U units) ---
# Standard QWERTY-like stagger (relative to Row 0)
stagger_offsets_u = [
    0.0,   # Row 0 (Number row)
    0.25,  # Row 1 (QWERTY row)
    0.5,   # Row 2 (ASDF row)
    0.75,  # Row 3 (ZXCV row)
    0.75   # Row 4 (Bottom/Thumb row - often customized, adjust if needed)
]

# ==========================
# Helper Functions
# ==========================

def key_cutout():
    """ Creates the 14x14mm negative space for a single switch cutout. """
    # Make it slightly taller than the plate for clean subtraction
    return cube([KEY_CUTOUT_SIZE, KEY_CUTOUT_SIZE, PLATE_THICKNESS * 3], center=True)

def generate_half_plate(layout_u, stagger_u, name="half"):
    """ Generates one half of the split keyboard plate. """
    print(f"Generating plate half: {name}")
    all_cutouts = []
    key_bounding_boxes = [] # Store tuples: (min_x, max_x, min_y, max_y) for each key position

    origin_y = 0 # Start placing rows from Y=0 downwards

    for r, row_layout in enumerate(layout_u):
        row_y = origin_y - (r * U) # Y position for the center of the current row
        row_stagger = stagger_u[r] * U if r < len(stagger_u) else 0
        current_x = row_stagger # Start x-position for the row, including stagger

        for key_width_u in row_layout:
            key_width = key_width_u * U
            # Calculate the center position of the current key
            key_center_x = current_x + (key_width / 2)
            key_center_y = row_y

            # --- Create and position the cutout ---
            cutout_obj = translate([key_center_x, key_center_y, 0])(key_cutout())
            all_cutouts.append(cutout_obj)

            # --- Calculate bounding box for this key's overall space ---
            # This helps determine the overall plate size
            key_min_x = current_x
            key_max_x = current_x + key_width
            key_min_y = row_y - (U / 2)
            key_max_y = row_y + (U / 2)
            key_bounding_boxes.append((key_min_x, key_max_x, key_min_y, key_max_y))

            # --- Advance x for the next key in the row ---
            current_x += key_width

    if not key_bounding_boxes:
        print(f"Warning: No keys found for half '{name}'. Returning empty object.")
        return union() # Return empty object

    # --- Determine overall plate dimensions ---
    min_x = min(box[0] for box in key_bounding_boxes) - PLATE_BORDER
    max_x = max(box[1] for box in key_bounding_boxes) + PLATE_BORDER
    min_y = min(box[2] for box in key_bounding_boxes) - PLATE_BORDER
    max_y = max(box[3] for box in key_bounding_boxes) + PLATE_BORDER

    plate_width = max_x - min_x
    plate_height = max_y - min_y
    plate_center_x = (min_x + max_x) / 2
    plate_center_y = (min_y + max_y) / 2

    print(f" - Plate Dimensions ({name}): Width={plate_width:.2f}, Height={plate_height:.2f}")
    print(f" - Plate Center ({name}): X={plate_center_x:.2f}, Y={plate_center_y:.2f}")

    # --- Create the base plate solid ---
    # Center the plate geometry around its calculated center before returning,
    # so that the final object's origin (0,0,0) corresponds to its geometric center.
    # However, for separate plates, it might be more useful to have the origin
    # consistently placed, e.g., at the top-left corner or relative to the first key.
    # Let's keep it centered for now, it's often easier to handle in slicers.
    base_plate = translate([plate_center_x, plate_center_y, 0])(
        cube([plate_width, plate_height, PLATE_THICKNESS], center=True)
    )

    # --- Subtract the key cutouts ---
    # Need to translate the cutouts relative to the plate's center as well.
    # Alternatively, create the plate at the origin and translate it later.
    # Let's rebuild the plate relative to (0,0) based on min/max values
    # and then translate the cutouts relative to that origin. This makes
    # the final object's origin predictable (related to min_x, max_y).

    base_plate_origin = translate([min_x, min_y, -PLATE_THICKNESS/2])(
         cube([plate_width, plate_height, PLATE_THICKNESS])
    )
    # Adjust cutouts to be relative to this new plate origin if needed,
    # but since they were calculated in absolute coords based on key positions,
    # they should subtract correctly from the base_plate_origin created using
    # the same min/max coordinates. Let's test this simpler approach first.

    plate_half = difference()(
        base_plate_origin, # Plate defined from min_x, min_y
        union()(all_cutouts) # Cutouts are already in the correct absolute positions
    )


    # Optional: Translate the final half so its corner is nearer the origin (0,0)
    # plate_half = translate([-min_x, -min_y, 0])(plate_half)

    return plate_half

# ==========================
# Main Execution
# ==========================

if __name__ == '__main__':
    # Generate the left half
    left_half = generate_half_plate(left_layout_u, stagger_offsets_u, "Left")

    # Generate the right half
    right_half = generate_half_plate(right_layout_u, stagger_offsets_u, "Right")

    # --- Output Separate Files ---
    output_filename_left = 'split_plate_left.scad'
    output_filename_right = 'split_plate_right.scad'

    print(f"\nSaving Left Half to {output_filename_left}...")
    scad_render_to_file(left_half, output_filename_left)
    print("Left Half Saved.")

    print(f"Saving Right Half to {output_filename_right}...")
    scad_render_to_file(right_half, output_filename_right)
    print("Right Half Saved.")

    print("\nDone generating separate plate halves.")

    # Optional: STL Rendering (requires OpenSCAD installed and in PATH)
    # try:
    #     print(f"\nAttempting to render STL files (requires OpenSCAD)...")
    #     output_stl_left = 'split_plate_left.stl'
    #     output_stl_right = 'split_plate_right.stl'
    #     scad_render_to_file(left_half, output_stl_left)
    #     print(f" - Saved {output_stl_left}")
    #     scad_render_to_file(right_half, output_stl_right)
    #     print(f" - Saved {output_stl_right}")
    #     print("STL rendering successful.")
    # except Exception as e:
    #     print(f"STL rendering failed. Ensure OpenSCAD is installed and in your system's PATH.")
    #     print(f"Error: {e}")