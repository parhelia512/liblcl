#[ 
   The code is automatically generated by the genBind tool. 
   Author: ying32
   https://github.com/ying32  
]#
##
{.deadCodeElim: on.}
##
# DLL
when defined(windows):
  {.push, callconv: stdcall.}
else:
  {.push, callconv: cdecl.}
##
when defined(windows):
  const dllname = "liblcl.dll"
elif defined(macosx):
  const dllname = "liblcl.dylib"
else:
  const dllname = "liblcl.so"    
##
import types
##
##

{{define "getFunc"}}
    {{$el := .}}
    {{$buff := newBuffer}}

    {{if eq $el.Platform "windows"}}
        {{$buff.Writeln "when defined(windows):"}}
    {{else if eq $el.Platform "linux,macos"}}
        {{$buff.Writeln "when not defined(windows):"}}
    {{else if eq $el.Platform "macos"}}
        {{$buff.Writeln "when defined(macosx):"}}
    {{else if eq $el.Platform "linux"}}
        {{$buff.Writeln "when defined(linux):"}}
    {{end}}
    {{/*平台不为all的则起始就得空2格了*/}}
    {{if ne $el.Platform "all"}}
        {{$buff.Write "  "}}
    {{end}}
    {{$buff.Write "proc " $el.Name "*("}}
    {{range $idx, $ps := $el.Params}}
        {{if gt $idx 0}}
           {{$buff.Write ", "}}
        {{end}}
        {{$buff.Write $ps.Name ": "}}
        {{if $ps.IsVar}}
            {{$buff.Write "var "}}
        {{end}}
        {{if not (isObject $ps.Type)}}
            {{covType $ps.Type|$buff.Write}}
        {{else}}
            {{$buff.Write "pointer"}}
        {{end}}
    {{end}}
    {{$buff.Write ")"}}
    {{if not (isEmpty $el.Return)}}
        {{$buff.Write ": "}}
        {{if not (isObject $el.Return)}}
            {{covType $el.Return|$buff.Write}}
        {{else}}
            {{$buff.Write "pointer"}}
        {{end}}
    {{end}}
    {{$buff.Writeln " {.importc: \"" $el.Name "\", dynlib: dllname.}"}}

{{$buff.ToStr}}
{{end}}

{{range $el := .Functions}}
    {{template "getFunc" $el}}
{{end}}

##
##
{{range $el := .Objects}}
    {{if ne $el.ClassName "Exception"}}
# ----------------- {{$el.ClassName}} ----------------------
        {{range $fn := $el.Methods}}
            {{template "getFunc" $fn}}
        {{end}}
    {{end}}
{{end}}

##
# 开始 
##
# 普通事件回调函数
proc doEventCallbackProc(f: pointer, args: pointer, argCount: int32): uint =
##
  # args为一个数组，长度为argCount, argCount最大为12
  var val = proc(index: int): pointer {.nimcall.} =
    return cast[pointer](cast[ptr uint](cast[uint](args) + cast[uint](index * sizeof(int)))[])
##
  # echo("doEventCallbackProc: f: ", cast[uint](f), ", args: ",cast[uint](args), ", count: ", argCount)
##
  case argCount
  of 0: 
    cast[proc(){.nimcall.}](f)()
  of 1:
    cast[proc(a1:pointer) {.nimcall.} ](f)(val(0))
  of 2:
    cast[proc(a1,a2:pointer) {.nimcall.} ](f)(val(0), val(1))
  of 3:
    cast[proc(a1,a2,a3:pointer) {.nimcall.} ](f)(val(0), val(1), val(2))
  of 4:
    cast[proc(a1,a2,a3,a4:pointer) {.nimcall.} ](f)(val(0), val(1), val(2), val(3))
  of 5:
    cast[proc(a1,a2,a3,a4,a5:pointer) {.nimcall.} ](f)(val(0), val(1), val(2), val(3), val(4))
  of 6:
    cast[proc(a1,a2,a3,a4,a5,a6:pointer) {.nimcall.} ](f)(val(0), val(1), val(2), val(3), val(4), val(5))
  of 7:
    cast[proc(a1,a2,a3,a4,a5,a6,a7:pointer) {.nimcall.} ](f)(val(0), val(1), val(2), val(3), val(4), val(5), val(6))
  of 8:
    cast[proc(a1,a2,a3,a4,a5,a6,a7,a8:pointer) {.nimcall.} ](f)(val(0), val(1), val(2), val(3), val(4), val(5), val(6), val(7))
  of 9:
    cast[proc(a1,a2,a3,a4,a5,a6,a7,a8,a9:pointer) {.nimcall.} ](f)(val(0), val(1), val(2), val(3), val(4), val(5), val(6), val(7), val(8))
  of 10:
    cast[proc(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10:pointer) {.nimcall.} ](f)(val(0), val(1), val(2), val(3), val(4), val(5), val(6), val(7), val(8), val(9))
  of 11:
    cast[proc(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11:pointer) {.nimcall.} ](f)(val(0), val(1), val(2), val(3), val(4), val(5), val(6), val(7), val(8), val(9), val(10))
  of 12:  
    cast[proc(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12:pointer) {.nimcall.} ](f)(val(0), val(1), val(2), val(3), val(4), val(5), val(6), val(7), val(8), val(9), val(10), val(11))
  else:
    echo("There are more than 12 parameters.")
##
  return 0
##
# 窗口消息专用回调
proc doMessageCallbackProc(f: pointer, msg: pointer): uint =
  # 这里要转发消息
  cast[proc(a1:pointer) {.nimcall.} ](f)(msg)
  return 0
##
# 线程同步专用回调
var
  threadSyncProc*: TThreadProc
##
proc doThreadSyncCallbackProc(): uint =
  if threadSyncProc != nil:
    threadSyncProc()
    threadSyncProc = nil
  return 0
##
##
var
  exceptionProc*: TExceptionEvent;
##
proc doHandlerExceptionCallbackProc(msg: cstring): uint =
  # 如果设置了全局的，则由全局的异常捕获，则不再直接抛出异常
  if exceptionProc != nil:
    exceptionProc(newException(Exception, $msg))
    return
  raise newException(Exception, $msg)
##
# set callback
SetEventCallback(cast[pointer](doEventCallbackProc))
SetMessageCallback(cast[pointer](doMessageCallbackProc))
SetThreadSyncCallback(cast[pointer](doThreadSyncCallbackProc))
SetExceptionHandlerCallback(cast[pointer](doHandlerExceptionCallbackProc))

