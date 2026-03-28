#!/bin/bash

source ./logging.sh

secondary_config_file=""

if [[ -v OTEL_EXPORTER_OTLP_ENDPOINT && -n ${OTEL_EXPORTER_OTLP_ENDPOINT} ]]; then
	echo "Also enabling OTLP/HTTP export to ${OTEL_EXPORTER_OTLP_ENDPOINT}"
	secondary_config_file="--config=file:./otelcol-config-export-http.yaml"
fi

run_with_logging "OpenTelemetry Collector ${OPENTELEMETRY_COLLECTOR_VERSION}" "${ENABLE_LOGS_OTELCOL:-false}" \
	./otelcol-contrib/otelcol-contrib --feature-gates service.profilesSupport --config=file:./otelcol-config.yaml ${secondary_config_file}
