from PIL import Image
img = Image.open('img/input.png').convert('L')  # grayscale
pixels = list(img.getdata())
with open('img/output_image.txt', 'w') as f:
    for p in pixels:
        f.write(f"{p}\n")