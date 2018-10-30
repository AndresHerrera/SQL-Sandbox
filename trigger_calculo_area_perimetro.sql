--creamos tabla

CREATE TABLE manzanas (
gid serial NOT NULL,
the_geom geometry(polygon, 3115),
area double precision,
perimetro double precision,
CONSTRAINT manzanas_pkey PRIMARY KEY (gid)
);



-- Creamos funcion
CREATE OR REPLACE FUNCTION funcion_area_perimetro () RETURNS trigger AS
$$
BEGIN
      RAISE NOTICE  'funcion disparadora, accion = %, sobre fila gid = %', TG_OP,
       NEW.gid;
       NEW.area = ST_area(NEW.the_geom);
       NEW.perimetro = ST_perimeter(NEW.the_geom);
       RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--creamos funcion disparadora 


CREATE TRIGGER area_perimetro_trigger 
BEFORE INSERT OR UPDATE ON manzanas
FOR EACH ROW EXECUTE
PROCEDURE funcion_area_perimetro();