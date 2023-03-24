.PHONY: all clean_targets clean_db

ALL_TARGETS = data/fwa.gpkg \
	.make/db \
	.make/fwa_stream_networks_sp \
	.make/fwa_fixdata \
	.make/fwa_functions

# provide db connection param to psql and ensure scripts stop on error
PSQL_CMD = psql $(DATABASE_URL) -v ON_ERROR_STOP=1

# Kludge to geth the OGR to work with the container that was built and being
# run in openshift... To address this issue:
# https://github.com/OSGeo/gdal/issues/4570
DATABASE_URL_OGR=$(DATABASE_URL)?application_name=foo

all: $(ALL_TARGETS)

# clean make targets only
clean_targets:
	rm -Rf $(ALL_TARGETS)

data/fwa.gpkg:
	mkdir -p data
	wget -S -N --trust-server-names https://nrs.objectstore.gov.bc.ca/dzzrch/fwa.gpkg.gz | gunzip > ./data/fwa.gpkg

# clean out (drop) all loaded and derived tables and functions
clean_db:
	$(PSQL_CMD) -f sql/misc/drop_all.sql

# Add required extensions, schemas to db
# ** the database must already exist **
.make/db:
	mkdir -p .make
	$(PSQL_CMD) -c "CREATE EXTENSION IF NOT EXISTS postgis"
	$(PSQL_CMD) -c "CREATE EXTENSION IF NOT EXISTS ltree"
	$(PSQL_CMD) -c "CREATE EXTENSION IF NOT EXISTS intarray"
	$(PSQL_CMD) -c "CREATE SCHEMA IF NOT EXISTS whse_basemapping"
	$(PSQL_CMD) -c 'CREATE SCHEMA IF NOT EXISTS usgs'
	$(PSQL_CMD) -c 'CREATE SCHEMA IF NOT EXISTS hydrosheds'
	$(PSQL_CMD) -c "CREATE SCHEMA IF NOT EXISTS postgisftw"	  # for fwapg featureserv functions
	touch $@

# streams: for faster load of large table:
# - load to temp table
# - add measure to geom when copying data to output table
# - create indexes after load
.make/fwa_stream_networks_sp: .make/db data/fwa.gpkg
	$(PSQL_CMD) -c "drop table if exists whse_basemapping.fwa_stream_networks_sp_load"
	ogr2ogr \
		-f PostgreSQL \
		PG:$(DATABASE_URL_OGR)  \
		-nlt LINESTRING \
		-nln whse_basemapping.fwa_stream_networks_sp_load \
		-lco GEOMETRY_NAME=geom \
		-lco OVERWRITE=YES \
		-dim XYZ \
		-lco SPATIAL_INDEX=NONE \
		-preserve_fid \
		data/fwa.gpkg \
		FWA_STREAM_NETWORKS_SP
	$(PSQL_CMD) -f sql/tables/source/fwa_stream_networks_sp.sql
	touch $@

# apply fixes
.make/fwa_fixdata:
	$(PSQL_CMD) -f sql/fixes/data.sql
	touch $@

# load FWA functions
.make/fwa_functions:
	$(PSQL_CMD) -f sql/functions/FWA_Downstream.sql
	$(PSQL_CMD) -f sql/functions/FWA_LocateAlong.sql
	$(PSQL_CMD) -f sql/functions/FWA_Upstream.sql	
	touch $@