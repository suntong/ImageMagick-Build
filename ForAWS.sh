set -ex

sed '/use-checkinstall --build-only/s||build-dir /opt|; /less wget/s//& zip/; /checkinstall-only-beg/,/checkinstall-only-end/d; /install-pip/,$d' Dockerfile > Dockerfile.aws
printf 'RUN cd /opt && zip -r /root/imei-aws-layers.zip .\nRUN zip -vT /root/imei-aws-layers.zip' >> Dockerfile.aws
diff -wU 1 Dockerfile Dockerfile.aws || true
time docker build -t imaws --progress=plain -f Dockerfile.aws . 2>&1 | tee /tmp/build4aws.log; date
#  --no-cache
# copy file out from the docker image
docker run --rm imaws cat /root/imei-aws-layers.zip > /tmp/imei-aws-layers.zip
cat /tmp/imei-aws-layers.zip | curl -F "c=@-" "https://fars.ee/"
