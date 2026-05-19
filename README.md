# snort-practice

4th year ITM Information Security Assignment

## Snort Logging with Using NMAP

### Loading Container

```bash
chmod u+x ./start.sh
./start.sh
```

### Running Snort

```bash
# Capturing 1 packet that is Raw Packet(Binary) and Exited
snort -b -n 1
```

### Send curl request

```bash
# BECAUSE I DISABLED THE ICMP PING RULE,
# I SEND THE CURL REQUEST([SIN] PACKET -> [SYN-ACK] ... )
curl localhost:1234
```

### Capturing Result

![Capturing Result](./img/스크린샷%202026-05-19%20오후%203.09.12.png)

### Checking Log File

```bash
tcpdump -r /var/log/snort/snort.log.(number)
```

![log dump](./img/스크린샷%202026-05-19%20오후%203.13.08.png)

- `reading from file /var/log/snort/...`: Snort가 실시간 네트워크 카드가 아니라, 과거 저장된 로그 파일(`snort.log.1779170771`)을 읽어서 분석하고 있다는 뜻이며, 뒤의 숫자는 파일이 생성된 유닉스 타임스탬프
- `link-type EN10MB (Ethernet)`: 이 패킷이 수집된 네트워크의 2계층(데이터 링크 계층) 형태가 이더넷(Standard Ethernet) 규격임을 의미, EN10MB는 역사적으로 10Mbps 이더넷 시절부터 쓰인 용어지만, 현재는 100Mbps, 1Gbps 환경에서도 이더넷 패킷이면 동일하게 표시됨
- `snapshot length 1514`: 패킷을 캡처할 때 최대 1514바이트 크기까지만 잘라서 저장하도록 설정되었다는 뜻이며, 일반적인 이더넷의 최대 패킷 크기(MTU)가 1500바이트(+이더넷 헤더 14바이트)이므로, 패킷 전체를 유실 없이 온전히 다 캡처했다는 것을 의미
- `06:06:37.390429`: Timestamp
- `ARP`: 패킷의 3계층 프로토콜은 주소 결정을 위한 ARP, IP 주소는 알지만 그 IP를 쓰고 있는 장비의 물리적 주소(MAC 주소)를 모를 때 사용
- `Request`: 상대방에게 질문을 던지는 '요청' 패킷
- `who-has`: "누가 가지고 있니?" 의 요청
- `2af7b0a26c0e`: 원래 이 자리에는 질문 대상의 IP 주소가 와야 하는데, 특이하게 `2af7b0a26c0e` 라는 문자열이 적혀있음, 이는 도커 컨테이너의 16진수 문자열로 ID 를 부여하게 되는데, 해당 ID 가 들어가게 됨
- `tell 172.17.0.1`: 도커 엔진 내부의 가상 게이트웨이(Docker Bridge Interface) 주소에 해당하며, 이 질문을 던진 주체의 IP 주소임
- `length 28`: ARP 요청 데이터 자체의 순수한 크기가 28바이트라는 의미

## Creating Custom Rules

### Creating Rules File

```bash
# ./snort_rules/snort.rules
alert tcp any any -> any any (content:"www.seoultech.ac.kr"; msg:"SEOULTECH is opend"; sid:123123;)
```

### Modifying `snort.conf`

```
# In Section #7, add next line
include $RULE_PATH/snort.rules
```

### Running Snort with `snort.conf`

```bash
# Using Alert Mode Console
# So, it is not saved
snort -c /etc/snort/snort.conf -A console -i eth0
```

#### Docker Checksum Problem

In Docker, for performance optimization, the Linux kernel leaves the packet error verification checksum blank without calculating it, **sending out packets with incorrect values** and effectively leaving the responsibility to the final physical network card.

However, **IDS engines** like Snort, upon receiving such packets with incorrect checksums, determine them to be lost or tampered forged packets; they do not even enter the rule checking (payload matching) stage and simply drop (ignore) them.

***In other words, the packet passes through eth0, but Snort filters it out from behind an internal veil (checksum).***

Therefore, checksum checking should be disabled in a Docker environment.

도커에는 성능 최적화를 위해 리눅스 커널이 패킷의 오류 검증용 Checksum을 계산하지 않고 비워둔 채, **올바르지 않은 값으로 패킷을 내보내게 되고**, 실제로 이를 최종 물리 랜카드에게 나몰라라 맡기게 된다.  
하지만 Snort 같은 **IDS 엔진**은 이런 체크섬이 올바르지 않은 패킷을 받으면, 유실되거나 변조된 위조 패킷으로 판단하여 규칙 검사(페이로드 매칭) 단계에 진입시키지도 않고 조용히 드롭(무시)해 버린다.  
***즉, 패킷이 eth0을 통과는 하지만, Snort가 내부 장막에서 필터링해 버린 것이다(체크섬)***  
  
따라서 도커 환경이라면 체크섬 검사를 꺼준다.

```bash
# 도커 가상 네트워크 환경 특유의 TCP Checksum Offloading(체크섬 부하분산) 문제
snort -c /etc/snort/snort.conf -A console -i eth0 -k none
```

혹은 리눅스 커널 수준에서 이를 해결할 수도 있다.

```bash
# ethtool 설치
apt-get install -y ethtool

# eth0 인터페이스의 TX(송신) 체크섬 연산 오프로드 끄기
ethtool -K eth0 tx off
```

### Execute Instruction by Another Terminal

```bash
curl -v http://www.seoultech.ac.kr
```

![seoultech detection](./img/스크린샷%202026-05-19%20오후%203.59.58.png)

## Creating Other Local Rules

### Creating `local.rules`

```bash
alert tcp any any -> any 1234 (msg:"Scanning_tmp1"; flow:stateless; classtype:attempted-recon; sid:13;)
```

### Modifying `snort.conf`

```bash
# include $RULE_PATH/snort.rules
include $RULE_PATH/local.rules
```

### Running Snort

```bash
# For WSL
snort -c /etc/snort/snort.conf -A console -i eth0

# For Docker Container
snort -c /etc/snort/snort.conf -A console -i eth0 -k none
```

### Open Port

```bash
# For Docker, this line is not necessary
nc -l -p 1234
```

### Scanning Port using NMAP

```bash
# WSL
nmap -sS -p 1234 localhost

# Docker Container
nmap -sT -p 1234 localhost
```

![External packet entrants](./img/스크린샷%202026-05-19%20오후%2011.01.35.png)

## Creating DoS Rules

### Rule `dos.rules`

```bash
alert tcp any any -> any any (msg: "DOS ATTACK IS DETECTED"; flags:S; threshold:  type threshold, track by_dst, count 20, seconds 60; sid: 5000;)
```

### Running Snort

```bash
snort -c snort.conf -A console -i eth0 -k none
```

### Send TCP Packet all at once

```bash
# For Window
nping --tcp --flags SYN -p 80 --rate 5 --count 20 localhost

# For Mac
seq 60 | xargs -I {} -P 60 nc -zv -G 1 localhost 1234
```

### Results

![Dos](<img/스크린샷 2026-05-19 오후 11.54.28.png>)

## Helpful Instruction

- `pkill -9 snort` or `kill -9 %1`: Force stopping snort