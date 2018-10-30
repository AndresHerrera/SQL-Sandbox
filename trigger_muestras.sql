

CREATE TABLE puntos_muestreo (
gid serial NOT NULL,
the_geom geometry(point, 3115),
latitude double precision,
longitude double precision,
CONSTRAINT puntos_muestreo_pkey PRIMARY KEY (gid)
);



CREATE OR REPLACE FUNCTION update_location_func()
RETURNS TRIGGER AS $$
BEGIN
NEW.longitude := st_x(st_transform(NEW.the_geom, 4326));
NEW.latitude := st_y(st_transform(NEW.the_geom, 4326));
RETURN NEW;
END;
$$ language 'plpgsql';


CREATE TRIGGER update_muestras_location BEFORE insert or update
ON puntos_muestreo FOR EACH ROW EXECUTE PROCEDURE
update_location_func();


-- modificar ejemplo para que calcule x y en 3115 
