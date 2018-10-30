CREATE OR REPLACE FUNCTION extraer_barrio()
  RETURNS "trigger" AS
  $BODY$
  BEGIN
	
	NEW.the_geom:=st_SetSRID(st_MakePoint(new.x, new.y), 4326) ;
	
	select barrio 
	INTO NEW.barrio
    from barrios WHERE st_intersects(the_geom,st_setsrid(st_makepoint(new.x, new.y),4326))   limit 1;

  RETURN NEW;
  END
  $BODY$
LANGUAGE 'plpgsql' VOLATILE;

CREATE TRIGGER extraer_nombre_barrio
  BEFORE INSERT OR UPDATE
  ON localizador
  FOR EACH ROW
EXECUTE PROCEDURE extraer_barrio();




CREATE SEQUENCE localizador_id_seq;
ALTER TABLE localizador ALTER id_localizador SET DEFAULT NEXTVAL('localizador_id_seq');
ALTER SEQUENCE localizador_id_seq RESTART WITH 10;



--Insertar un nuevo punto
INSERT INTO localizador(x,y) VALUES(-76.532657,3.436789 );
select * from localizador;

--Insertar un nuevo punto

INSERT INTO localizador(x,y) VALUES(-75.4504,4.0758);
select * from localizador;

-------------


-- Ajuste a trigger 

CREATE OR REPLACE FUNCTION extraer_barrio()
  RETURNS "trigger" AS
  $BODY$
  BEGIN
	NEW.the_geom:=st_SetSRID(st_MakePoint(new.x, new.y), 4326) ;

	select barrio 
	    INTO NEW.barrio
        from barrios WHERE st_intersects(the_geom,st_setsrid(st_makepoint(new.x, new.y),4326))   limit 1;

      IF NEW.barrio IS NULL THEN
            NEW.barrio := 'No existe el Barrio';
      END IF;

  RETURN NEW;
  END
  $BODY$
LANGUAGE 'plpgsql' VOLATILE;


--Insertar un nuevo punto

INSERT INTO localizador(x,y) VALUES(-75.4504,4.0758);
select * from localizador;





