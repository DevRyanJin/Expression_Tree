# REMARKS: Implement Expression Tree by using Binary Tree Data Structure in Ruby

#Node class
class Node
end

#Binary Tree class, sub-class of Node
class BinaryTree < Node
  
  #getter and setter for intance variables
  attr_accessor :left, :right
  @left = nil
  @right = nil
  
  #constructor
  def initialize(left, right)
    @left = left
    @right = right
  end
 
 #method implementing transverse InOrder way
  def transverseInOrder
    if left != nil
      left.transverseInOrder do |node|
        yield(node)
      end
    end
    yield(self)
    if right != nil
      right.transverseInOrder do |node|
        yield(node)
      end
    end
  end

# method implementing transverse PostOrder way
  def transversePostOrder
    if left != nil
      left.transversePostOrder do |node|
        yield(node)
      end
    end
    if right != nil
      right.transversePostOrder do |node|
        yield(node)
      end
    end
    yield(self)
  end
 
# method implementing transverse PreOrder way
  def transversePreOrder
    yield(self)
    if left != nil
      left.transversePreOrder do |node|
        yield(node)
      end
    end
    if right != nil
      right.transversePreOrder do |node|
        yield(node)
      end
    end
  end
end

#ExpressionTree class sub-class of BinaryTree
class ExpressionTree < BinaryTree

  #getter methods for depth and fix_depth
  attr_reader :depth, :fix_depth
  @depth = 0
  @fix_depth = 0

  def assign(variable, value)
  end
  
  def simplify
    return self
  end

  def details
    return ""
  end
  
  #setter methods for instance variables
  def set_depth(depth)
    @depth = depth
  end
  def set_fix_depth(depth)
    @fix_depth = depth-1
  end
  
  def structure
    return ""
  end
end


#ConstantTree class containing only an integer, sub-class of ExpressionTree
class ConstantTree < ExpressionTree
  attr_reader :value
  @value = nil
  def initialize(value)
    @value = value
  end
  def details
    return @value.to_s()
  end
  def structure
    result = ""
    for i in 0..@depth-1
      result = result + "|  "
    end
    result = result + "==> " + @value.to_s()
    return result
  end
end

#VariableTree class containing only an letter variable, sub-class of ExpressionTree
class VariableTree < ExpressionTree
  attr_reader :variable
  @variable = nil
  def initialize(variable)
    @variable = variable
  end
  def details
    return @variable
  end
  def structure
    result = ""
    for i in 0..@depth-1
      result = result + "|  "
    end
    result = result + "==> " + variable.to_s()
    return result
  end
end


#OperatorTree class containing only symbol of '+','-','*', or'^', sub-class of ExpressionTree
class OperatorTree < ExpressionTree
  attr_reader :operator
  @operator = nil

  def initialize(operator, left, right)
    @operator = operator
    @left = left
    @right = right
    @depth = 0
    @fix_depth = 0
  end

#return the operater object
  def details
    return @operator
  end
  
  # set the set_depth instance variable by using recursion when left or right is not nil
  def set_depth(depth)
    @depth = depth
    left.set_depth(depth+1) if left != nil
    right.set_depth(depth+1) if right != nil
  end
  # set the set_fix_depth instance variable by using recursion when left or right is not nil
  def set_fix_depth(depth)
    @fix_depth = depth
    left.set_fix_depth(depth+1) if left != nil
    right.set_fix_depth(depth+1) if right != nil
  end
  
  #simplify the expression
  def simplify
    if @left!=nil && @right != nil
      @left = @left.simplify
      @right = @right.simplify
      #if both operands are constants, calculate the result
      if @left.is_a? ConstantTree
        if @right.is_a? ConstantTree
          return ConstantTree.new(@left.value + @right.value) if @operator == "+"
          return ConstantTree.new(@left.value - @right.value) if @operator == "-"
          return ConstantTree.new(@left.value * @right.value) if @operator == "*"
          return ConstantTree.new(@left.value ** @right.value) if @operator == "^"
        else
        #when left value is zero
          if @left.value == 0
            return @right if @operator == "+"
            return @right if @operator == "-"
            return ConstantTree.new(0) if @operator == "*"
            return ConstantTree.new(1) if @operator == "^"
          else
            #when left value is one
            if @left.value == 1
              return @right if @operator == "*"
              return @right if @operator == "^"
            end
          end
        end
      else
        if @right.is_a?(ConstantTree)
          if @right.value == 0
            return @left if @operator == "+"
            return @left if @operator == "-"
            return ConstantTree.new(0) if @operator == "*"
            return ConstantTree.new(1) if @operator == "^"
          else
            if @right.value == 1
              return @left if @operator == "*"
              return @left if @operator == "^"
            end
          end
        end
      end
    end
    return self
  end
  
  #read a variable and replace it with the given expression
  def assign(variable, node)
    if @left!=nil
      if @left.is_a?(VariableTree)&&@left.variable == variable
        @left = read(node)
      else
        @left.assign variable,node
      end
    end
    if @right!=nil
      if @right.is_a?(VariableTree)&&@right.variable == variable
        @right = read(node)
      else
        @right.assign variable,node
      end
    end
  end
  
  #set up the structure which allows us to print all structure later on..
  def structure
    result = ""
    for i in 0..@depth-1
      result = result + "|  "
    end
    if @operator == "+"
      result = result + "==> add"
    end
    if @operator == "-"
      result = result + "==> subtract"
    end
    if @operator == "*"
      result = result + "==> multiply"
    end
    if @operator == "^"
      result = result + "==> power"
    end
    return result
  end
end

#read the command in a fully parenthesized arithmetic expression
def read(line)
    line = line.gsub(/\s+/, "") #remove white space from the line to be read
  return read_expression(line,0)[0]
end

#helper method to read the command in a fully parenthesized arithmetic expression
def read_expression(line,i)
  if line[i].chr == '('
    left,i = read_expression(line,i+1)
    operator = line[i].chr
    right,i = read_expression(line,i+1)
    if line[i].chr == ')'
      return OperatorTree.new(operator,left,right),i+1
    else
      raise RuntimeError, "Uneven parenthesis ("+i.to_s()+"):"+line
    end
  else
      if line[i].ord >= 45 && line[i].ord <= 57
        j = i+1
        while j<line.length && line[j].ord >= 48 && line[j].ord <= 57
          j = j + 1
        end
        return ConstantTree.new(Integer(line[i..j-1])),j
      else
        j = i+1
        while j<line.length && line[j] =~ /[[:alpha:]]/
          j = j + 1
        end
        return VariableTree.new(line[i..j-1]),j
      end
  end
end

#print the tree in inorder traversal
def printInfix(tree)
  result = ""
  depth = -1
  tree.set_fix_depth 0
  tree.transverseInOrder do |node|
    while(depth<node.fix_depth)
      result = result + "("
      depth = depth + 1
    end
    while(depth>node.fix_depth)
      result = result + ")"
      depth = depth - 1
    end
    result = result + node.details

  end
  for i in 0..depth
    result = result + ")"
  end
  puts result
end

#print the tree in postorder traversal
def printPostfix(tree)
  result = ""
  depth = -1
  wasOperator = false
  tree.set_fix_depth 0
  tree.transversePostOrder do |node|
    changedDepth = false
    while(depth<node.fix_depth)
      result = result + "("
      depth = depth + 1
      changedDepth = true
    end
    result = result + node.details

    if node.is_a? OperatorTree
      result = result + ")"
      depth = depth - 1
    end
  end
  for i in 0..depth
    result = result + ")"
  end
  puts result
end

#print the tree in preorder traversal
def printPrefix(tree)
  result = ""
  depth = -1
  stack = []
  tree.set_fix_depth 0
  tree.transversePreOrder do |node|
    if node.is_a? OperatorTree
      result = result + "("
      depth = depth + 1
      stack << node
    end
    result = result + node.details

    while stack.length > 0 && node == stack[depth].right
      result = result + ")"
      depth = depth - 1
      node = stack.pop
    end
  end
  for i in 0..depth
    result = result + ")"
  end
  puts result
end

#print the full tree structure by implementing preorder traversal method
def displayStructure(tree)
  result = ""
  tree.set_depth 0
  tree.transversePreOrder do |node|
    result = result + node.structure + "\n"
  end
  puts result
end

#recieves the given file's command as parameter and do some operation based on the command
def callCommand(line,command,arg,tree)
  if command == nil
    command = line
  else
    if command == "comment"
      puts line
      command = nil
    else
      if command == "read"
        tree = read(line)
        command = nil
      else
        if command == "simplify"
          tree = tree.simplify
          command = line
        else
          if command == "assign"
            if arg == nil
              arg = line
            else
              tree.assign  arg, line
              command = nil
              arg = nil
            end
          else
            eval(command +"(tree)")
            command = line
          end
        end
      end
    end
  end
  return command,arg,tree
end

#if argument length is 1, then read the given file and implement corresponding methods.
if ARGV.length == 1
  text=File.open(ARGV[0]).read
  text.gsub!(/\r\n?/, "\n")
  command = nil
  arg = nil
  tree = nil
  text.each_line do |line|
    line = line.strip
    c,a,t = callCommand(line,command,arg,tree)
    command = c
    arg = a
    tree = t
  end
  callCommand(nil,command,arg,tree)
end
