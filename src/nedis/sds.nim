type
  SDS* = object
    len: int
    avail: int
    buf*: ptr UncheckedArray[char]

proc `$`*(s: SDS): string


proc newSDS*(initSize: int = 8): SDS = 
  SDS(len: 0, avail: initSize, buf: cast[ptr UncheckedArray[char]](alloc(sizeof(char) * initSize)))

proc newSDS*(s: string, initSize: int = 8): SDS = 
  if s.len == 0:
    return newSDS(initSize)
  result.len = s.len
  result.avail = s.len
  result.buf = cast[ptr UncheckedArray[char]](alloc(sizeof(char) * result.len * 2))
  moveMem(result.buf, s[0].unsafeAddr, s.len)

proc len*(s: SDS): int {.inline.} = 
  s.len

proc avail*(s: SDS): int {.inline.}= 
  s.avail

proc clone*(s: SDS): SDS = 
  result.len = s.len
  result.avail = s.avail
  result.buf = cast[ptr UncheckedArray[char]](alloc(result.len + result.avail))
  moveMem(result.buf, s.buf, s.len)


proc free*(s:var SDS) = 
  dealloc(s.buf)
  s.buf = nil

proc clear*(s: var SDS) {.inline.}= 
  s.len = 0

proc resize*(s: SDS, size: int): SDS =
  if size < 1048576:
    result.len = size
    result.avail = size
    result.buf = cast[ptr UncheckedArray[char]](alloc(size * 2))  
  else:
    result.len = size
    result.avail = 1048576
    result.buf = cast[ptr UncheckedArray[char]](alloc(s.len + s.avail))
  moveMem(result.buf, s.buf, s.len)
  
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

proc copy*(s1: var SDS, s2: SDS) {.inline.} = 
  if s1.len + s1.avail < s2.len:
    s1 = resize(s1, s2.len)
  else:
    s1.len = s2.len
    s1.avail -= s2.len
  if s1.len == 0:
    return
  s1.buf = s2.buf
  # for i in 0 ..< s1.len:
  #   s1.buf[i] = s2[i]

proc fill*(s: var SDS, c: char = '\0', size: int = 1) {.inline.} = 
  let tmp = s.len
  if s.avail < size:
    s = resize(s, s.len + s.avail + size)
  else:
    s.len += size
    s.avail -= size
  for i in 0 ..< size:
    s.buf[tmp+i] = c

proc strim*(s: SDS, dict: set[char]): SDS {.inline.} = 
  let total = s.len * 2
  result.buf = cast[ptr UncheckedArray[char]](alloc(total))  
  var counter: int = 0
  for c in 0 ..< s.len:
    if s.buf[c] notin dict:
      result.buf[counter] = s.buf[c]
      inc(counter)
  result.len = counter
  result.avail = total - counter

proc cmp*(s1: SDS, s2: SDS): bool =
  if s1.len != s2.len:
    return false
  for i in 0 ..< s1.len:
    if s1.buf[i] != s2.buf[i]:
      return false
  return true 

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

proc `==`*(s1, s2: SDS): bool =
  cmp(s1, s2)


when isMainModule:
  var s1 = newSDS("76test")
  var s2 = newSDS("qwuyetrgu")
  copy(s1, s2)
  var s3 = s2.strim({'t'})
  var s4 = clone(s2)
  assert s1 == newSDS("qwuyetrgu")
  assert s3 == newSDS("qwuyergu")
  s2[3] = 'a'
  assert s1 == s2
  assert not (s4 == s2)

  