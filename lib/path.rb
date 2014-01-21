require "tree"
#require "./lib/game_map"

class Path
  attr_accessor :from_room, :to_room, :route, :possible_routes, :map
  
  def initialize(from_room, to_room)
    @from_room = from_room
    @to_room = to_room
    #if from_room != to_room
      @path_tree = Tree::TreeNode.new(from_room, :start)
      calculate_paths(@path_tree, from_room, to_room)
      @route = get_route
    # else
    #   @route = [ to_room ]
    # end
  end 

  def self.set_map(map)
    @@map = map
  end

  def calculate_paths(node, start, goal)
    rooms = @@map.rooms
    if rooms[start].nil? || rooms[goal].nil?
      puts "Path between #{start.to_s} and #{goal.to_s} not found: Invalid input?"
      #log info: "Path between #{start.to_s} and #{goal.to_s} not found: Invalid input?"
    else
      rooms[start].exits.each do |exit|
        if is_a_repeat?(node, exit.to_room)
          next
        else
          next_node = node << Tree::TreeNode.new(exit.to_room, exit.from_direction)
        end

        if exit.to_room == goal
          next_node.content=:goal
        elsif already_visited?(next_node, exit.to_room)
          next_node.content = :invalid_path
          next
        else      
          calculate_paths(next_node, exit.to_room, goal)
        end
      end
    end
  end

  def already_visited?(node, xtr)
    visited = []
    node.parentage.each {|node| visited << node.name}
    visited.include?(xtr)
  end

  # a check to see if a room has two different paths that go to the same destination
  def is_a_repeat?(node, possible_repeat)
    children = []
    node.children.each {|node| children << node.name}
    children.include?(possible_repeat)
  end

  def get_route
    @possible_routes = []
    @path_tree.each_leaf do |leaf_node|
      path = []
      if leaf_node.content == :goal
        path << leaf_node.name
        leaf_node.parentage.each {|parent| path << parent.name}
        @possible_routes << path.reverse
      end
    end
    @possible_routes.min_by { |path| path.length }
  end
end