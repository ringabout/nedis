type
  SkipNodeObj*[T] = object
    right*: ref SkipNodeObj[T]
    down*: ref SkipNodeObj[T]
    value*: T
  SkipNode*[T] = ref SkipNodeObj[T]
  SkipList*[T] = object
    header*: SkipNode[T]
    bottom*: SkipNode[T]
    tail*: SkipNode[T]

proc newSkipList*[T: SomeInteger](): SkipList[T] {.noinit.} =
  let infinity = high(T)
  # buttom
  new result.bottom
  result.bottom.right = result.bottom 
  result.bottom.down = result.bottom
  # tail
  new result.tail
  result.tail.right = result.tail
  result.tail.value = infinity
  # header
  new result.header
  result.header.right = result.tail
  result.header.down = result.bottom
  result.header.value = infinity

proc find*[T: SomeInteger](L: SkipList[T], value: T): SkipNode[T] =
  ## return node containing value
  ## or bottom if not found 
  var current = L.header.right
  L.bottom.value = value
  while current.value != value:
    if value < current.value:
      current = current.down
    else:
      current = current.left

proc insert*[T: SomeInteger](L:var SkipList[T], value: T) = 
  var current = L.header
  let infinity = high(T)
  var node: SkipNode[T] 
  L.bottom.value = value
  while current != L.bottom:
    while current.value < value:
      current = current.right
    if current.value > current.down.right.right.value:
      new node
      node.value = current.value
      node.right = current.right
      node.down = current.down.right.right
      current.value = current.down.right.value
      current.right = node
    else:
      current = current.down
      
  
  if L.header.right != L.tail:
    # the error
    new node
    node.down = L.header
    node.right = L.tail
    node.value = infinity
    L.header = node

# proc `$`*[T](L: SkipList[T]): string = 
#   var current = L.header
#   while current.down != L.bottom:
#     current = current.down
#   while current.right != L.tail:
#     result.add($current.value & "->")
#     current = current.right
#   result &= "tail"

proc `$`*[T](L: SkipList[T]): string = 
  var c = L.header
  while c != L.bottom:
    var current = c
    while current.right != L.tail:
      result.add($current.value & "->")
      current = current.right
    result &= "tail\n\n"
    c = c.down
  


when isMainModule:
  import random
  randomize()
  var s = newSkipList[int]() 
  var a = [5, 10, 15, 20, 25, 27, 30, 35, 45, 40, 50]
  echo a
  a.shuffle()
  for i in a:
    s.insert(i)
  echo s



