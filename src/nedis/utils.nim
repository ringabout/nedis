type
  SDS* = ref object
    len: int
    avail: int
    buf*: ptr UncheckedArray[char]

proc `$`*(s: SDS): string


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

proc len*(s: SDS): int {.inline.} = 
  s.len

proc avail*(s: SDS): int {.inline.}= 
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

proc clear*(s: var SDS) {.inline.}= 
  s.len = 0

proc resize*(s: SDS, size: int): SDS =
  new result
  if size < 1048576:
    result.len = size
    result.avail = size
    result.buf = cast[ptr UncheckedArray[char]](alloc(size * 2))  
  else:
    result.len = size
    result.avail = 1048576
    result.buf = cast[ptr UncheckedArray[char]](alloc(s.len + s.avail))
  for i in 0 ..< result.len + result.avail:
    result.buf[i] = s.buf[i]

proc cat*(s1: var SDS, s2: string) {.inline.} = 
  let 
    total = s1.len + s2.len
    tmp = s1.len
  if s2.len > s1.avail:
    s1 = resize(s1, total)
  else:
    s1.len = total
    s1.avail -= s2.len
  for i in  0 ..< s2.len:
    s1.buf[tmp + i] = s2[i]

proc cat*(s1: var SDS, s2: SDS) {.inline.} = 
  let 
    total = s1.len + s2.len
    tmp = s1.len
  if s2.len > s1.avail:
    s1 = resize(s1, total)
  else:
    s1.len = total
    s1.avail -= s2.len
  for i in  0 ..< s2.len:
    s1.buf[tmp + i] = s2.buf[i]

proc `[]`*(s: SDS, idx: int): char = 
  s.buf[idx]

proc `[]=`*(s: var SDS, idx: int, v: char) = 
  s.buf[idx] = v

proc `&`*(s1: var SDS, s2: string): SDS {.inline.} = 
  cat(s1, s2)
  result = s1

proc `&`*(s1: var SDS, s2: SDS): SDS {.inline.} = 
  cat(s1, s2)
  result = s1

proc `&=`*(s1: var SDS, s2: string) {.inline.} = 
  cat(s1, s2)

proc `&=`*(s1: var SDS, s2: SDS) {.inline.} = 
  cat(s1, s2)
  
proc `$`*(s: SDS): string =
  result = newString(s.len)
  for i in 0 ..< s.len:
    result[i] = s.buf[i] 

when isMainModule:
  var s = newSDS("hello, Nim!")
  var s2 = "test"
  s &= s2
  echo s
  echo s.len

  