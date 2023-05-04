#!/bin/bash

# Globals

URL="https://forecast.weather.gov/zipcity.php?inputstring="
DEFAULT=46556
FORECAST=0
CELSIUS=0

# Functions

usage() {
    cat 1>&2 <<EOF
Usage: $(basename $0) [zipcode]

-c    Use Celsius degrees instead of Fahrenheit for temperature
-f    Display forecast text

If zipcode is not provided, then it defaults to $ZIPCODE.
EOF
    exit $1
}

weather_information() {
    # Fetch weather information from URL based on ZIPCODE
	
	curl -sL ${URL}$ZIPCODE
}

temperature() {
    # Extract temperature information from weather source
	weather_information | egrep 'myforecast-current-lrg' | cut -d '>' -f 2 | cut -d '&' -f 1
}

forecast() {
    # Extract forecast information from weather source
if [[ $FORECAST -eq 1 ]];
then   

	weather_information | grep -E 'myforecast-current' | cut -d '>' -f 2 | cut -d '<' -f 1 | head -1 | xargs
else
	:
fi
}

temperatureC() {
if [[ $CELSIUS -eq 1 ]];
then
	weather_information| grep -E 'myforecast-current-sm' | cut -d '>' -f 2 | cut -d '&' -f 1
else
	:
fi
}
# Parse Command Line Options

while [ $# -gt 0 ]; do
    case $1 in
        -h) usage 0;;
	-c) CELSIUS=1;;
	-f) FORECAST=1;;
	*) break;;
    esac
    shift
done
ZIPCODE="$@"
if [[ -z "$ZIPCODE" ]];
then
	ZIPCODE="$DEFAULT"
else
	:
fi

if [ $CELSIUS -eq 1 ] && [ $FORECAST -eq 1 ]; then
	echo "Forecast:    $(forecast)" && echo "Temperature: $(temperatureC) degrees"
elif [ $FORECAST -eq 1 ]; then
	echo "Forecast:    $(forecast)" && echo "Temperature: $(temperature) degrees"
elif [ $CELSIUS -eq 1 ]; then
	echo "Temperature: $(temperatureC) degrees"
else
	echo "Temperature: $(temperature) degrees"
fi
