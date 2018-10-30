--creamos tabla

CREATE TABLE manzanas2 (
gid serial NOT NULL,
the_geom geometry(polygon, 3115),
area double precision,
perimetro double precision,
x double precision,
y double precision,
CONSTRAINT manzanas2_pkey PRIMARY KEY (gid)
);



-- Creamos funcion
CREATE OR REPLACE FUNCTION funcion_area_perimetro_centroide () RETURNS trigger AS
$$
BEGIN
      RAISE NOTICE  'funcion disparadora, accion = %, sobre fila gid = %', TG_OP,
       NEW.gid;
       NEW.area = ST_area(NEW.the_geom);
       NEW.perimetro = ST_perimeter(NEW.the_geom);
	   NEW.x = ST_x(ST_centroid(NEW.the_geom));
	   NEW.y = ST_y(ST_centroid(NEW.the_geom));
       RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--creamos funcion disparadora 


CREATE TRIGGER area_perimetro_centroide_trigger 
BEFORE INSERT OR UPDATE ON manzanas2
FOR EACH ROW EXECUTE
PROCEDURE funcion_area_perimetro_centroide();