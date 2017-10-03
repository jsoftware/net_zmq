NB. zmq covers and utils

coclass'jzmq'

0 : 0
ctx_jzmq_ and sockets_jzmq_ maintained in zmq locale
ctx created when first required

messages are 2 frames
 f1 - count [option]
 f2 - data

message to server   - option access
message from server - option error
)

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
ZMQ_LINGER=:  17

ZMQ_POLLIN=: 1
ZMQ_POLLOUT=: 2
ZMQ_POLLERR=: 4

3 : 0''
if. _1=nc<'ctx' do. ctx=: 0 [ sockets=: '' end.
select. UNAME
case. 'Linux' do. lib=: 'libzmq.so'
case. 'Win' do.
  lib=: fread'~home/zmqdllpath.txt'
  if. lib=_1 do.
    lib=: jpath'c:/program files/zeromq 4.0.4/bin/libzmq-v120-mt-4_0_4.dll'
  end.
  m=. 'zmq shared library not at:',LF,'   ',lib,LF
  m=. m,'verify zmq installed and if necessary set path in ~home/zmqdllpath.txt',LF,LF
  m assert fexist lib
  lib=: '"','"',~lib
case. 'Darwin' do.
  lib=: 'libzmq.dylib'
case. do. 'platform not supported'assert 0
end.
)

check=: 3 : 0
if. y do. return. end.
lzmqe_jzmq_=: strerror''
('zmq error (',lzmqe,')') assert 0
)

cdx=: 4 : 0
lzmqc_jzmq_=: (x i.' '){.x
lzmqe_jzmq_=: ''
(lib,' ',x)cd y
)

cdxnm=: 4 : 'r[check _1~:>{.r=. x cdx y'
cdxnz=: 4 : 'r[check 0~: >{.r=. x cdx y'
cdxz=: 4 : 'r[check 0=  >{.r=. x cdx y'

version=: 3 : 0
try.
  v=. }.;'zmq_version n *i *i *i'cdx (,1);(,2);,3
  ('zmq version (',(":v),') is too old')assert 4>:{.v
catch.
  echo ,.lib;(cder'');}.cderx''
  'cd zmq shared library version call failed'assert 0
end.
v
)

strerror=: 3 : 0
memr 0 _1,~'zmq_strerror >x i'cdx 'zmq_errno > i'cdx''
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
echo y,(,2);,4
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

NB. locales ; '' to for all events ; timeout
NB. int zmq_poll (zmq_pollitem_t *items, int nitems, long timeout);
NB. returns readable;writeable;error
NB. unix and windows pollitem structure differ
NB.  unix fd is 32 bits and windows SOCKET is 64 bits
NB.  unix structure is 16 bytes windows structure is 24 (rounded up)
poll=: 3 : 0
't e s'=: y
'events must be empty string'assert ''-:e
size=. IFWIN{16 24
off=. IFWIN{ 0 4
b=. size*#s
a=. mema b
(b#{.a.)memw a,0,b
for_i. i.#s do.
  c=. i{s
  S__c memw (a+i*size),0,1,4
  (7{a.)memw (12+off+a+i*size),0,1
end.
'zmq_poll i * i x'cdxnm (<a);(#s);t
r=. a.i.(14+off){"1 (size,~#s)$memr a,0,b
memf a
<@#&s "1 |. |:2 2 2 #:r
)
