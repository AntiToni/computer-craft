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
    z_even = z % 2 != 0 if y_even else z % 2 == 0
    z_size_even = z_size % 2 == 0


    dir = {'x': 1, 'y': 0, 'z': 0}

    # Reverse direction every second column, also add sideways moves
    if z_even:
        dir = {'x': -1, 'y': 0, 'z': 0}
        if x == 1:
            dir = {'x': 0, 'y': 0, 'z': 1}
    elif x == x_size:
        dir = {'x': 0, 'y': 0, 'z': 1}

    # End tile check
    if y_even:
        # Flip direction of arrow if even y
        dir['z'] *= -1
        if x == 1 and z == 1:
            dir = {'x': 0, 'y': -1, 'z': 0}
    elif z == z_size and (z_size_even and x == 1 or not z_size_even and x == x_size):
            dir = {'x': 0, 'y': -1, 'z': 0}

    return dir

def grid_to_string(grid):
    for sublist in grid:
        for i in range(len(sublist)):
            string = ''
            print(sublist, i)
            if sublist[i] == '':
                string = ''
            elif sublist[i]['x'] == 1:
                string = '^'
            elif sublist[i]['x'] == -1:
                string = 'v'
            elif sublist[i]['y'] == 1:
                string = 'O'
            elif sublist[i]['y'] == -1:
                string = 'X'
            elif sublist[i]['z'] == 1:
                string = '>'
            elif sublist[i]['z'] == -1:
                string = '<'
            sublist[i] = string

def print_horizontal_line():
    print('+', end='')
    for _ in range(len(grid[0])):
        print('-' * tile_width, end='+')
    print()

def print_grid(grid):
    print_horizontal_line()
    for i in range(len(grid) - 1, -1, -1):
        for item in grid[i]:
            formatted_item = f'{item:^{tile_width}}'
            print('|' + formatted_item, end='')
        print('|')
        print_horizontal_line()


if __name__ == '__main__':
    y = -3

    x_size = 5
    z_size = 6

    for i in range(x_size):
        for j in range(z_size):
            grid[i][j] = map_to_dir(i,y,j,x_size,z_size)

    print(grid)

    grid_to_string(grid)

    print_grid(grid)
            
    # print_grid(grid_to_string(grid))