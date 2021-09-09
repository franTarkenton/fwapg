CREATE TABLE whse_basemapping.fwa_linear_boundaries_sp (
    linear_feature_id integer PRIMARY KEY,
    watershed_group_id integer,
    edge_type integer,
    waterbody_key integer,
    blue_line_key integer,
    watershed_key integer,
    fwa_watershed_code character varying(143),
    local_watershed_code character varying(143),
    watershed_group_code character varying(4),
    downstream_route_measure double precision,
    length_metre double precision,
    feature_source character varying(15),
    feature_code character varying(10),
    geom public.geometry(MultiLineString,3005),
    wscode_ltree public.ltree GENERATED ALWAYS AS ((replace(replace((fwa_watershed_code)::text, '-000000'::text, ''::text), '-'::text, '.'::text))::public.ltree) STORED,
    localcode_ltree public.ltree GENERATED ALWAYS AS ((replace(replace((local_watershed_code)::text, '-000000'::text, ''::text), '-'::text, '.'::text))::public.ltree) STORED
);


CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp (edge_type);
CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp (blue_line_key);
CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp (watershed_key);
CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp (waterbody_key);
CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp (watershed_group_code);
CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp USING GIST (wscode_ltree);
CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp USING BTREE (wscode_ltree);
CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp USING GIST (localcode_ltree);
CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp USING BTREE (localcode_ltree);
CREATE INDEX ON whse_basemapping.fwa_linear_boundaries_sp USING GIST (geom);