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

## Results:

### Input image

<img src="./img/input.png">

### Output after Soble Edge Detection

<img src="/img/output_sobel_full.jpg">

---

## Steps

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

## Results

After running the full flow (preprocess → simulate → postprocess), you will find:

- **`img/output_sobel_full.jpg`** — The edge-detected image with black borders (pixels on the image boundary that could not be fully convolved).
- **`img/output_sobel_interior.jpg`** — The interior region only (cropped 2 pixels from each edge).
