#!/bin/bash


### Wordpress Scan with the purpose for integration into CI/CD pipeline ###
# Example: ./wpscan_cicd.sh "https://example.com"


# prepare directories and variables
[[ -d wpscan ]] || mkdir wpscan
current_date=$(date +"%m%d%Y")
if [ ! -z "$WPSCAN_API_TOKEN" ]; then
	api_cmd="--api-token $(echo -n $WPSCAN_API_TOKEN)"
fi

# build wpscan_analyze if doesnt exist
wpscan_analyze_exist=$(docker images | grep -o wpscan-analyze)
if [ -z "$wpscan_analyze_exist" ]; then
	git clone https://github.com/lukaspustina/wpscan-analyze && \
	cd wpscan-analyze && \
	docker image build -t wpscan-analyze .

	cd .. && rm -rf wpscan-analyze
fi

# https://github.com/wpscanteam/wpscan
docker run --rm wpscanteam/wpscan:latest \
	--url "$1" -e vp,vt --plugins-detection mixed \
	$(echo -n $api_cmd) --format json > wpscan/output_$(echo -n $current_date)

# https://github.com/lukaspustina/wpscan-analyze
docker run -it -v "$(pwd)/wpscan:/wpscan-analyze/" wpscan-analyze \
	-f output_$(echo -n $current_date)
