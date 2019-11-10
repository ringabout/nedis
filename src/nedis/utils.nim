type
  SDS* = object
    len: int
    free: int
    buf*: ptr UncheckedArray[char]

proc newSDS*(initSize: int = 8): SDS = 
  SDS(len: 0, free: initSize, buf: cast[ptr UncheckedArray[char]](alloc0(sizeof(char) * initSize)))

proc newSDS*(s: string, initSize: int = 8): SDS = 
  if s.len == 0:
    return newSDS(initSize)
  return SDS(len: s.len, free: s.len, buf: cast[ptr UncheckedArray[char]](s[0].unsafeAddr))

proc len*(s: SDS): int = 
  s.len

proc avail*(s: SDS): int = 
  s.free

proc clone*(s: SDS): SDS = 
  result.len = s.len
  result.free = s.free
  result.buf = cast[ptr UncheckedArray[char]](alloc0(result.len))
  for i in 0 ..< result.len:
    result.buf[i] = s.buf[i]

let s = newSDS("hello, Nim!")
let m = s.clone()
echo m


  