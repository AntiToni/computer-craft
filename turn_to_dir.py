# Program should turn to specified direction from current direction

dir_list = []
for i in range(3):
    for j in range(2):
        dir = [0,0,0]
        dir[i] = j if j == 1 else -1
        dir_list.append(dir)

print(dir_list)

def turn_to_dir(curr, target):
    turn = 0
    product = dot_product(curr, target)

    # Check if in correct rotation already
    if curr[0] != target[0] or curr[2] != target[2]:
        if product != [0,0,0]:
            # Need to turn 180
            turn = 2
        else:
            # Must turn left or right
            swap = [target[2],target[1],target[0]]
            swap_product = dot_product(curr, swap)

            turn = swap_product[0] - swap_product[2]

    turn_map = {-1: 'LEFT', 0: 'NONE', 1: 'RIGHT', 2: '180'}
    turn = turn_map[turn]

    return turn

# Pretend that Im not a dumbass thx
def dot_product(a, b):
    c = []
    for i in range(len(a)):
        c.append(a[i] * b[i])

    return c

if __name__ == '__main__':
    turn_to_dir([0,0,0],[0,0,0])

    for curr in dir_list:
        for target in dir_list:
            print(str(curr) + ' -> ' + str(target) + ' : ' + str(turn_to_dir(curr,target)))