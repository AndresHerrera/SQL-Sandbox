DROP TABLE IF EXISTS test_table;
CREATE TABLE test_table(
    id bigserial NOT NULL,
    latitude double precision,
    longitude double precision,
    geom geometry,
    geog geography,
    updated_ts double precision,
    CONSTRAINT test_table_unique_key UNIQUE (id)
);

-- index 
DROP INDEX IF EXISTS test_table_geom_idx;
CREATE INDEX test_table_geom_idx
  ON test_table
  USING gist
  (geom);

DROP INDEX IF EXISTS test_table_geog_idx;
CREATE INDEX test_table_geog_idx
  ON test_table
  USING gist
  (geog);

-- trigger function
CREATE OR REPLACE FUNCTION fn_test_table_geo_update_event() RETURNS trigger AS $fn_test_table_geo_update_event$
  BEGIN  
	-- as this is an after trigger, NEW contains all the information we need even for INSERT
	UPDATE test_table SET 
	geom = ST_SetSRID(ST_MakePoint(NEW.longitude,NEW.latitude), 4326),
	geog = ST_SetSRID(ST_MakePoint(NEW.longitude,NEW.latitude), 4326)::geography,
	updated_ts = date_part('epoch'::text, now()) WHERE id=NEW.id;

	RAISE NOTICE 'UPDATING geo data for %, [%,%]' , NEW.id, NEW.latitude, NEW.longitude;	
    RETURN NULL; -- result is ignored since this is an AFTER trigger
  END;
$fn_test_table_geo_update_event$ LANGUAGE plpgsql;

-- triggers
-- INSERT trigger
DROP TRIGGER IF EXISTS tr_test_table_inserted ON test_table;
CREATE TRIGGER tr_test_table_inserted
  AFTER INSERT ON test_table
  FOR EACH ROW
  EXECUTE PROCEDURE fn_test_table_geo_update_event();


 --  UPDATE trigger
DROP TRIGGER IF EXISTS tr_test_table_geo_updated ON test_table;
CREATE TRIGGER tr_test_table_geo_updated
  AFTER UPDATE OF 
  latitude,
  longitude
  ON test_table
  FOR EACH ROW
  EXECUTE PROCEDURE fn_test_table_geo_update_event();
  
-- test queries
--INSERT INTO test_table (latitude, longitude) VALUES(43.653226, -79.3831843);
--UPDATE test_table SET latitude=39.653226 WHERE id=1;
--SELECT to_timestamp(updated_ts), * FROM test_table;