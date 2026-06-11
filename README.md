# Accelerated Image Processing — Sobel Edge Detection

A hardware-accelerated **Sobel edge detection** system implemented in **Verilog RTL**

---

## Overview

This project implements a **real-time Sobel edge detection accelerator** in hardware. It takes a grayscale image, streams pixel data into a Verilog module that computes horizontal and vertical gradients using the Sobel operator, and reconstructs the edge-detected output image.

**Key features:**

- Fully synthesizable Verilog RTL
- Pipelined 3×3 convolution window with line buffers
- Hardware-friendly gradient magnitude approximation (abs sum)
- Python scripts for seamless image I/O

---

## Project Structure

```text
accleratedImageProcessing/
├── README.md                  # This file
├── RTL/
│   └── sobel_accel.v          # Top-level Sobel accelerator module
├── TB/
│   ├── tb_sobel_accel.v       # Testbench
│   └── tb_sobel_accel.vvp     # Compiled simulation binary
├── scripts/
│   ├── preprocessing.py       # Convert image → pixel data text file
│   └── postprocessing.py      # Convert output data → image file(s)
└─ img/
    ├── output_image.txt       # Preprocessed input pixel data
    ├── output_data.txt        # Raw simulation output
    ├── output_sobel_full.jpg  # Full output image (with borders)
    └── output_sobel_interior.jpg  # Interior cropped output image

```

---

## How It Works

```
Input Image (PNG/JPG)
        │
        ▼
┌───────────────────┐
│  preprocessing.py │  Convert to grayscale, dump pixel values
└────────┬──────────┘
         │ output_image.txt (one decimal pixel per line)
         ▼
┌───────────────────┐
│    sobel_accel    │  Hardware Sobel edge detection (Verilog)
│  (RTL simulation) │  3×3 window, Gx/Gy computation, magnitude
└────────┬──────────┘
         │ output_data.txt (edge pixel values)
         ▼
┌───────────────────┐
│ postprocessing.py │  Reconstruct image from output data
└────────┬──────────┘
         │
         ▼
Output Image (JPG)
```

---

## Usage

### 1. Preprocess Input Image

Convert any grayscale image to a text file of decimal pixel values (one per line).

```bash
python scripts/preprocessing.py
```

**Input:** `img/input.png` (grayscale)  
**Output:** `img/output_image.txt`

> The script expects a grayscale image. If you have a color image, convert it first (e.g., using PIL or an image editor).

### 2. Run RTL Simulation

Compile and run the Verilog testbench with Icarus Verilog.

```bash
# Compile
iverilog -o TB/tb_sobel_accel.vvp TB/tb_sobel_accel.v RTL/sobel_accel.v

# Simulate
vvp TB/tb_sobel_accel.vvp
```

**Output:** `img/output_data.txt` (edge-detected pixel values)

### 3. Postprocess Output Data

Reconstruct the edge-detected image from the simulation output.

```bash
python scripts/postprocessing.py
```

**Outputs:**
| File | Description |
|------|-------------|
| `img/output_sobel_full.jpg` | Full 640×427 image with black borders |
| `img/output_sobel_interior.jpg` | Interior 638×425 region only |

---

## Testbench

The testbench (`TB/tb_sobel_accel.v`):

- Generates a **100 MHz clock** (10 ns period)
- Reads pixel data from `img/output_image.txt` via `$fscanf`
- Streams pixels into the DUT with `pixel_valid` strobes
- Writes edge-detected output to `img/output_data.txt`
- Supports configurable image dimensions (`WIDTH`, `HEIGHT`)

**Default image size:** 640 × 427 pixels (interior region: 638 × 425).

---

## Results

After running the full flow (preprocess → simulate → postprocess), you will find:

- **`img/output_sobel_full.jpg`** — The edge-detected image with black borders (pixels on the image boundary that could not be fully convolved).
- **`img/output_sobel_interior.jpg`** — The interior region only (cropped 2 pixels from each edge).

### Expected behavior

- Strong edges (high contrast) appear as bright pixels.
- Smooth regions (low gradient) appear as dark pixels.
- The output should resemble a classic Sobel edge-detected version of the input.

---
