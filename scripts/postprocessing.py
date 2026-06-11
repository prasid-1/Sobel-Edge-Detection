from PIL import Image

# Known dimensions
orig_width = 640
orig_height = 427
interior_width = orig_width - 2
interior_height = orig_height - 2
expected_interior_pixels = interior_width * interior_height   # 271,150

with open('img/output_data.txt') as f:
    all_lines = [line.strip() for line in f if line.strip()]

print(f"Total lines in output file: {len(all_lines)}")

interior_pixels = []
for line in all_lines:
    try:
        val = int(line)
        interior_pixels.append(val)
        if len(interior_pixels) >= expected_interior_pixels:
            break
    except:
        pass

print(f"Extracted {len(interior_pixels)} interior pixels")

if len(interior_pixels) < expected_interior_pixels:
    print(f"Warning: only got {len(interior_pixels)}, expected {expected_interior_pixels}")

#create full image with black borders
full_img = Image.new('L', (orig_width, orig_height), 0)
for y in range(interior_height):
    for x in range(interior_width):
        idx = y * interior_width + x
        if idx < len(interior_pixels):
            full_img.putpixel((x+1, y+1), interior_pixels[idx])

full_img.save("img/output_sobel_full.jpg")
print("Saved full image with borders (black where data missing).")

#save just the interior region
interior_img = Image.new('L', (interior_width, interior_height))
interior_img.putdata(interior_pixels[:expected_interior_pixels])
interior_img.save("img/output_sobel_interior.jpg")
print("Saved interior image.")