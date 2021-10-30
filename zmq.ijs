NB. zmq covers and utils

coclass'jzmq'

0 : 0
setlib runs once when script is first loaded
to set lib_zmq_ as zmq shared library - for example,
 '"C:/program files/zeromq 4.3.2/libzmq-v120-mt-4_3_2.dll"'
or 
 'libzmq.so.5'
 
if setlib can't find zmq or finds the wrong one, override with
   lib_zmq=: '"..."' NB. set after load
)

0 : 0
ctx_jzmq_ and sockets_jzmq_ maintained in zmq locale
ctx created when first required

messages are 2 frames
 f1 - count [option]
 f2 - data

message to server   - option access
message from server - option error
)

lzmqc=: lzmqe=: ''

localhost=: '127.0.0.1'

NB. /usr/include/zmq.h
ZMQ_PAIR=: 0
ZMQ_PUB=: 1
ZMQ_SUB=: 2
ZMQ_REQ=: 3
ZMQ_REP=: 4
ZMQ_DEALER=: 5
ZMQ_ROUTER=: 6
ZMQ_PULL=: 7
ZMQ_PUSH=: 8
ZMQ_XPUB=: 9
ZMQ_XSUB=: 10
ZMQ_STREAM=: 11

ZMQ_MORE=: 1
ZMQ_SRCFD=: 2
ZMQ_SHARED=: 3

ZMQ_DONTWAIT=: 1
ZMQ_SNDMORE=: 2

ZMQ_RCVMORE=: 13
ZMQ_LINGER=: 17

ZMQ_POLLIN=: 1
ZMQ_POLLOUT=: 2
ZMQ_POLLERR=: 4

setlib=: 3 : 0
select. UNAME
case. 'Linux';'OpenBSD' do.
  if. ('libzmq.so.5 dummyfunction n')&cd :: (1={.@cder) '' do.
    if. ('libzmq.so.4 dummyfunction n')&cd :: (1={.@cder) '' do.
      lib=: 'libzmq.so.3'
    else.
      lib=: 'libzmq.so.4'
    end.
  else.
    lib=: 'libzmq.so.5'
  end.
case. 'Win' do.
  p=. 'C:\program files\zeromq'
  d=. 1 1 dir p,'*'
  i=. ;100#.each".each (}:each(#p)}.each d) rplc each <'.';' '
  i=. 1 i.~d i.>./i
  'zmq not installed in "program files" folder' assert i<#d
  p=. ,;i{d
  b=. 1 1  dir    p,'libzmq*.dll'
  if. 0=#b do.
   b=. 1 1 dir w__=: p,'bin/libzmq-v120-mt-4*.dll'
  end.
  ('zmq dll not found in ',;b) assert 1=#b
  lib=: '"','"',~;b 
case. 'Darwin' do.
  lib=: 'libzmq.dylib'
case. do. 'platform not supported'assert 0
end.
)

NB. first time initialization
3 : 0''
if. _1=nc<'ctx' do. setlib '' [ ctx=: 0 [ sockets=: '' end.
)

check=: 3 : 0
if. y do. return. end.
lzmqe_jzmq_=: strerror''
'zmq-check'log''
('zmq-check ',lzmqc,' ',lzmqe) assert 0
)

cdx=: 4 : 0
lzmqc_jzmq_=: (x i.' '){.x
lzmqe_jzmq_=: ''
(lib,' ',x)cd y
)

cdxnm=: 4 : 'r[check _1~:>{.r=. x cdx y'
cdxnz=: 4 : 'r[check 0~: >{.r=. x cdx y'
cdxz=: 4 : 'r[check 0=  >{.r=. x cdx y'
cde=: 4 : '(lib,'' '',x)cd y'

version=: 3 : 0
try.
  if. IFWIN do. NB. load libsodium so it can found
   t=. '"','"',~}.'/libsodium.dll',~lib{.~lib i: '/'
   (t,' dummyfunction n')&cd :: (1={.@cder) ''
  end.
  v=. }.;'zmq_version n *i *i *i'cdx (,1);(,2);,3
  ('zmq version (',(":v),') is too old')assert 4>:{.v
catch.
  echo ,.lib;(cder'');}.cderx''
  'cd zmq shared library version call failed'assert 0
end.
v
)

strerror=: 3 : 0
memr 0 _1,~'zmq_strerror >x i'cde 'zmq_errno > i'cde''
)

NB. create ctx if it doesn't already exist
ctx_new=: 3 : 0
if. 0~:ctx_jzmq_ do. return. end.
version''
sockets_jzmq_=: ''
ctx_jzmq_=: 'zmq_ctx_new > x'cdxnz ''
)

ctx_term=: 3 : 0
if. 0=ctx_jzmq_ do. return. end.
'open sockets prevent ctx_term'assert 0=#sockets_jzmq_
'zmq_ctx_term > x x'cdxz ctx_jzmq_
ctx_jzmq_=: 0
)

NB. y ZMQ_REP etc.
socket=: 3 : 0
s=. 'zmq_socket > x x i'cdxnz ctx;y
sockets_jzmq_=: sockets_jzmq_,s
s
)

close=: 3 : 0
'close of socket that is not open'assert y e. sockets_jzmq_
'zmq_close > i x'cdxz y
sockets_jzmq_=: sockets_jzmq_-.y
)

NB. hardwired for int options
getsockopt=: 3 : 0
>3{r=. 'zmq_getsockopt i x i *i *x'cdxnm y,(,2);,4
)

NB. hardwired for int options
setsockopt=: 3 : 0
i.0 0['zmq_setsockopt i x i *i x'cdxnm ((2{.y),<,>{:y),<4
)

NB. bind socket;'tcp://*:5555'
bind=: 3 : 0
'zmq_bind > i x *c'cdxz y
)

connect=: 3 : 0
'zmq_connect > i x *c' cdxz y
)

recv=: 3 : 0
r=. 'zmq_recv i x *c x i'cdxnm y
(>{.r){.;2{r
)

send=: 3 : 0
r=. 'zmq_send > i x *c x i'cdxnm y
)

NB. timeout ; events ; tasks
NB. events '' is for read+write events on all tasks
NB. events are 1 for read, 2 for write, 3 for both tests for corresponding task
NB. int zmq_poll (zmq_pollitem_t *items, int nitems, long timeout);
NB. returns readable;writeable;error
NB. unix and windows pollitem structure differ
NB.  unix fd is 32 bits and windows SOCKET is 64 bits
NB.  unix structure is 16 bytes windows structure is 24 (rounded up)
NB. result is return_code;reads;writes;errors
NB. e is 1 for read test, 2 for write test, and 3 for both
poll=: 3 : 0
't e s'=. y
if. e-:'' do. e=. 3#~#s end.
'count events must equal count tasks'assert (#e)=#s
'events must be 1 (read), 2 (write), or 3 (both)'assert 0=#e-. 1 2 3
size=. IFWIN{16 24
off=. IFWIN{ 0 4
b=. size*#s
a=. mema b
(b#{.a.)memw a,0,b
for_i. i.#s do.
  c=. i{s
  S__c memw (a+i*size),0,1,4
  (a.{~i{e) memw (12+off+a+i*size),0,1
end.
q=. 'zmq_poll > i * i x'cdxnm (<a);(#s);t
r=. a.i.(14+off){"1 (size,~#s)$memr a,0,b
memf a
q;<@#&s "1 |. |:2 2 2 #:r
)

1!:5 :: [ <jpath'~temp/zmq'
logfile=: '~temp/zmq/',(":2!:6''),'.log'

NB. write log record to ~temp/zmq/pid.txt
NB. multiple zmq server tasks need their own pid log file to avoid write races
NB. log for zmq calls
log=: 4 : 0
(LF,~(isotimestamp 6!:0''),'  ',(10{.x),'  ',(8":2!:6''),'  ',lzmqc,'  ',lzmqe,'  ',":y) fappend logfile
)

NB. log for non zmq calls
logx=: 4 : 0
(LF,~(isotimestamp 6!:0''),'  ',(10{.x),'  ',(8":2!:6''),'  ',":y) fappend logfile
)

logread=: 3 : 'fread logfile'

logclear=: 3 : 0
ferase logfile
i.0 0
)

logclearall=: 3 : 0
ferase 1 dir'~temp/zmq/*.log'
i.0 0
)

loglog=: 3 : 0
(;fread each 1 dir '~temp/zmq/*.log')fwrite '~temp/zmq/log.log'
'~temp/zmq/log.log'
)
