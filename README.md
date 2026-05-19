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

- `reading from file /var/log/snort/...`: Snort가 실시간 네트워크 카드가 아니라, 과거 저장된 로그 파일(snort.log.1779170771)을 읽어서 분석하고 있다는 뜻입니다. 뒤의 숫자는 파일이 생성된 유닉스 타임스탬프입니다.

- `link-type EN10MB (Ethernet)`: 이 패킷이 수집된 네트워크의 2계층(데이터 링크 계층) 형태가 이더넷(Standard Ethernet) 규격임을 의미, EN10MB는 역사적으로 10Mbps 이더넷 시절부터 쓰인 용어지만, 현재는 100Mbps, 1Gbps 환경에서도 이더넷 패킷이면 동일하게 표시됨

- `snapshot length 1514`: 패킷을 캡처할 때 최대 1514바이트 크기까지만 잘라서 저장하도록 설정되었다는 뜻이며, 일반적인 이더넷의 최대 패킷 크기(MTU)가 1500바이트(+이더넷 헤더 14바이트)이므로, 패킷 전체를 유실 없이 온전히 다 캡처했다는 것을 의미

- `06:06:37.390429`: Timestamp

- `ARP`: 패킷의 3계층 프로토콜은 주소 결정을 위한 ARP, IP 주소는 알지만 그 IP를 쓰고 있는 장비의 물리적 주소(MAC 주소)를 모를 때 사용

- `Request`: 상대방에게 질문을 던지는 '요청' 패킷

- `who-has`: "누가 가지고 있니?" 의 요청

- `2af7b0a26c0e`: 원래 이 자리에는 질문 대상의 IP 주소가 와야 하는데, 특이하게 `2af7b0a26c0e` 라는 문자열이 적혀있음, 이는 도커 컨테이너의 16진수 문자열로 ID 를 부여하게 되는데, 해당 ID 가 들어가게 됨

- `tell 172.17.0.1`: 도커 엔진 내부의 가상 게이트웨이(Docker Bridge Interface) 주소에 해당하며, 이 질문을 던진 주체의 IP 주소임

- `length 28`: ARP 요청 데이터 자체의 순수한 크기가 28바이트라는 의미