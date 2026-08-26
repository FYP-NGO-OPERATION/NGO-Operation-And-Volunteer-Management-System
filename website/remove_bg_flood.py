from PIL import Image

def flood_fill_transparent(image_path, output_path, threshold=20):
    img = Image.open(image_path).convert("RGBA")
    width, height = img.size
    pixels = img.load()
    
    # Target color to replace (black)
    target_color = (0, 0, 0)
    
    # Visited set
    visited = set()
    
    # Stack for flood fill
    stack = [(0, 0), (width-1, 0), (0, height-1), (width-1, height-1)]
    
    def is_similar(c1, target):
        return c1[0] <= threshold and c1[1] <= threshold and c1[2] <= threshold
    
    while stack:
        x, y = stack.pop()
        
        if x < 0 or x >= width or y < 0 or y >= height:
            continue
            
        if (x, y) in visited:
            continue
            
        visited.add((x, y))
        
        current_color = pixels[x, y]
        
        if is_similar(current_color, target_color):
            # Make transparent
            pixels[x, y] = (0, 0, 0, 0)
            
            # Add neighbors
            stack.append((x + 1, y))
            stack.append((x - 1, y))
            stack.append((x, y + 1))
            stack.append((x, y - 1))

    img.save(output_path, "PNG")
    print(f"Saved transparent image to {output_path}")

if __name__ == "__main__":
    flood_fill_transparent("public/images/founders/group.jpg", "public/images/founders/group.png", threshold=25)
