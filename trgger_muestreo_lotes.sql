DROP TABLE IF EXISTS muestreo_lotes;

CREATE TABLE muestreo_lotes(
	description varchar(50), 
	ubicacion varchar(50),
	date_time timestamp, 
	gid serial PRIMARY KEY, 
	the_geom geometry(POINT,3115));
	
CREATE INDEX idx_muestreo_lotes_geom ON muestreo_lotes USING GIST(the_geom);


select * from lotes;


CREATE OR REPLACE FUNCTION update_observation()
RETURNS trigger AS $$
    BEGIN
        IF NEW.description IS NULL THEN
            RAISE EXCEPTION 'descipcion no puede estar vacia';
        END IF;

        
        NEW.ubicacion = (SELECT nombre_hda|| ' - ' || codigo FROM lotes
        WHERE ST_Within(NEW.the_geom, the_geom));
        
        IF NEW.ubicacion IS NULL THEN
            RAISE EXCEPTION 'ubicacion: ubicacion no puede estar por fuera del lindero del poligono';
        END IF;

        NEW.date_time := current_timestamp;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql; 



DROP TRIGGER IF EXISTS update_observation ON muestreo_lotes;
CREATE TRIGGER update_observation BEFORE INSERT OR UPDATE ON muestreo_lotes
    FOR EACH ROW EXECUTE PROCEDURE update_observation();


