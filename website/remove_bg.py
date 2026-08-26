from rembg import remove
from PIL import Image

input_path = "public/images/founders/group.jpg"
output_path = "public/images/founders/group.png"

print("Loading image...")
with open(input_path, 'rb') as i:
    input_data = i.read()
    print("Processing...")
    output_data = remove(input_data)
    with open(output_path, 'wb') as o:
        o.write(output_data)
        print("Done!")
