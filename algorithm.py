# Map any coordinate to a direction
# 0 - UP
# 1 - RIGHT
# 2 - DOWN
# 3 - LEFT

tile_width = 3

grid = []
for x in range(15):
    row = []
    for z in range(15):
        row.append('')
    grid.append(row)

def map_to_dir(x,y,z,x_size,z_size):
    x += 1
    z += 1

    y_even = y % 2 == 0
    z_even = z % 2 == 0
    z_size_even = z_size % 2 == 0

    dir = '^' if not y_even else 'v'

    # Reverse behaviour if z 
    if y_even:
        if z_even:
            dir = '^'
            if x == x_size:
                dir = '<'
        elif x == 1:
            dir = '<'
    else:
        if z_even:
            dir = 'v'
            if x == 1:
                dir = '>'
        elif x == x_size:
            dir = '>'

    # End tile check
    if y_even:
        if x == 1 and z == 1:
            dir = 'O'
    elif z == z_size:
        if z_size_even and x == 1:
            dir = 'O'
        elif not z_size_even and x == x_size:
            dir = 'O'

    return dir

def print_horizontal_line():
    print('+', end='')
    for _ in range(len(grid[0])):
        print('-' * tile_width, end='+')
    print()

def print_grid():
    print_horizontal_line()
    for i in range(len(grid) - 1, -1, -1):
        for item in grid[i]:
            formatted_item = f'{item:^{tile_width}}'
            print('|' + formatted_item, end='')
        print('|')
        print_horizontal_line()


if __name__ == '__main__':
    y = -2

    x_size = 5
    z_size = 6

    for i in range(x_size):
        for j in range(z_size):
            grid[i][j] = map_to_dir(i,y,j,x_size,z_size)
            
    print_grid()