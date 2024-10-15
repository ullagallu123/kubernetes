[2024-10-12 11:24:23,012] INFO in logging: msg headers {'X-INSTANA-L': '1', 'traceparent': '00-00000000000000009b11bfc96c137cc4-96bc15f97c06cd0d-01', 'tracestate': 'in=9b11bfc96c137cc4;96bc15f97c06cd0d', 'X-INSTANA-T': '9b11bfc96c137cc4', 'X-INSTANA-S': '96bc15f97c06cd0d'}
[2024-10-12 11:24:23,029] ERROR in logging: ConnectionClosedByBroker: (403) 'ACCESS_REFUSED - Login was refused using authentication mechanism PLAIN. For details see the broker logfile.'
[pid: 8|app: 0|req: 1/1] 100.96.3.203 () {44 vars in 760 bytes} [Sat Oct 12 11:24:21 2024] POST /pay/siva => generated 142 bytes in 1091 msecs (HTTP/1.1 500) 2 headers in 99 bytes (1 switches on core 0)

2024-10-12 11:04:20.441313+00:00 [notice] <0.86.0>     alarm_handler: {set,{system_memory_high_watermark,[]}}
2024-10-12 11:24:23.015959+00:00 [info] <0.669.0> accepting AMQP connection <0.669.0> (100.96.3.221:55814 -> 100.96.2.100:5672)
2024-10-12 11:24:23.018557+00:00 [error] <0.669.0> Error on AMQP connection <0.669.0> (100.96.3.221:55814 -> 100.96.2.100:5672, state: starting):
2024-10-12 11:24:23.018557+00:00 [error] <0.669.0> PLAIN login refused: user 'roboshop' - invalid credentials
2024-10-12 11:24:23.028811+00:00 [info] <0.669.0> closing AMQP connection <0.669.0> (100.96.3.221:55814 -> 100.96.2.100:5672)