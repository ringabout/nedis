type
  SDS* = ref object
    len: int
    avail: int
    buf*: ptr UncheckedArray[char]

proc newSDS*(initSize: int = 8): SDS = 
  SDS(len: 0, avail: initSize, buf: cast[ptr UncheckedArray[char]](alloc(sizeof(char) * initSize)))

proc newSDS*(s: string, initSize: int = 8): SDS = 
  if s.len == 0:
    return newSDS(initSize)
  new result
  result.len = s.len
  result.avail = s.len
  result.buf = cast[ptr UncheckedArray[char]](alloc(sizeof(char) * result.len * 2))
  for i in 0 ..< result.len:
    result.buf[i] = s[i]

proc len*(s: SDS): int = 
  s.len

proc avail*(s: SDS): int = 
  s.avail

proc clone*(s: SDS): SDS = 
  new result
  result.len = s.len
  result.avail = s.avail
  result.buf = cast[ptr UncheckedArray[char]](alloc(result.len + result.avail))
  for i in 0 ..< result.len:
    result.buf[i] = s.buf[i]


proc free*(s:var SDS) = 
  dealloc(s.buf)
  s.buf = nil
  s = nil

proc clear*(s: var SDS) = 
  s.len = 0

proc resize*(s: var SDS, size: int) =
  if size < 1048576:
    s.len = size
    s.avail = size
    s.buf = cast[ptr UncheckedArray[char]](alloc(size * 2))
  else:
    s.len = size
    s.avail = 1048576
    s.buf = cast[ptr UncheckedArray[char]](alloc(s.len + s.avail))

proc cat*(s1: var SDS, s2: string) = 
  let size = s1.len + s2.len
  

proc `$`*(s: SDS): string =
  result = newString(s.len)
  for i in 0 ..< s.len:
    result[i] = s.buf[i] 

var s = newSDS("hello, Nim!")
echo s.buf[12].repr


  