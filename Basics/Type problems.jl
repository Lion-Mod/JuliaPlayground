using CircularList

## ROBOT (MUTABLE TYPE PRACTICE)
"""
There are a limited number of robot names which can be generated.

Each time you create a robot it gains a new name that is unique.

If you factory reset a robot you give it a new unique name.
"""
possible_names = [i * j * string(a) for a = 1:999 for j = 'a':'z' for i = 'a':'z'];

# Each time a Robot is created remove a name from the possible_names list.
mutable struct Robot
    name::String
    Robot() = reset!(new())
end

# Only take a new name if there is one in the possible_names list.
function reset!(robot::Robot)
    if length(possible_names) == 0
        error("No more names")
    end

    robot.name = pop!(possible_names)
    return robot
end

# When you factory_reset a robot remove a name from the possible_names list.
function factory_reset(robot::Robot)
    robot.name = pop!(possible_names)
    return robot
end

# Example
a_robot = Robot()
factory_reset(a_robot)



## GPSROBOT
"""
Creating a GPSROBOT that stores it's location and direction.

When run_instruction is called the GPSROBOT will move and update it's location and direction.

Key for instruction
- A = move forward 1
- R = turn 90 degrees right
- L = turn 90 degrees left
"""

using CircularList

# getindex method for dictionary and circular list as this isn't in CircularList
Base.getindex(h::Dict{String,Vector{Int64}}, key::CircularList.Node{String}) = h[key.data]

# Thinking for a GPSRobot
# - Direction can be represented as a circular list as it has a cyclical nature.
# - Location can be represented as a vector as x and y cordinates.
mutable struct GPSRobot
    direction::CircularList.List{String}
    location::Vector

    GPSRobot() = new(circularlist(["N", "E", "S", "W"]), [0, 0])
end

function run_instruction(instruction_set, gps_robot::GPSRobot)
    # Split the string of instruction_set into individual instructions.
    instructions = [s for s in split(instruction_set, "")]

    # N/S/W/E movement is like applying a scalar, e.g. N is upwards positively, no movement horizontally.
    direction_scaling = Dict("N" => [0, 1],
                             "S" => [0, -1],
                             "W" => [-1, 0],
                             "E" => [1, 0])

    # Go through the instructions and update the gps_robot
    for x in 1:length(instructions)

        # Update the circular list if R or L
        if instructions[x] == "R"
            forward!(gps_robot.direction)

        elseif instructions[x] == "L"
            backward!(gps_robot.direction)

        # Update the location when the robot moves
        elseif instructions[x] == "A"
            gps_robot.location = gps_robot.location + direction_scaling[current(gps_robot.direction)]
        end
    end

    return (current(gps_robot.direction).data, gps_robot.location)

end


robot_a = GPSRobot()
# GPSRobot(CircularList.List("N","E","S","W"), [0, 0])

run_instruction("RAARAL", robot_a)
# ("E", [2, -1])