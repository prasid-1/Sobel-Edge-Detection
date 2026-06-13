from PIL import Image

# convert input image to grayscale and save pixel values to text file
img = Image.open('img/input.png').convert('L')
pixels = list(img.getdata())
with open('img/output_image.txt', 'w') as f:
    for p in pixels:
        f.write(f"{p}\n")