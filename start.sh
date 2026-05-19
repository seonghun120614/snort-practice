docker build -t snort_image .

docker run -it --rm \
  --cap-add=NET_ADMIN \
  -p 1234:1234 \
  -v "./snort_rules:/etc/snort/rules" \
  -v "./snort_logs:/var/log/snort" \
  -v "./snort.conf:/etc/snort/snort.conf" \
  --name snort_container \
  snort_image