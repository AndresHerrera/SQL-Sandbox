CREATE TABLE uv_nodos
(
        id_punto serial,
	punto_x double precision,
 	punto_y double precision, 
 	id_edif_cerca integer,
 	n_edif_cerca character varying,
 	d_edif_cerca double precision,
 	id_edif_lejos integer,
 	n_edif_lejos character varying,
 	d_edif_lejos double precision,
       CONSTRAINT uvnodos_pkey PRIMARY KEY (id_punto)

);

SELECT AddGeometryColumn('','uv_nodos','the_geom',4326,'POINT',2);



CREATE OR REPLACE FUNCTION public.calcular_punto()
  RETURNS trigger AS
$BODY$
  BEGIN
    NEW.the_geom:=st_setSRID(st_makepoint(new.punto_x, new.punto_y), 4326) ;

    select osm_id, name, st_distance(the_geom,st_setsrid(st_makepoint(new.punto_x, new.punto_y),4326)) 
	INTO NEW.id_edif_cerca, NEW.n_edif_cerca , NEW.d_edif_cerca
    from uv_edifi order by 3 asc limit 1;

    select osm_id, name, st_distance(the_geom,st_setsrid(st_makepoint(new.punto_x, new.punto_y),4326)) 
	INTO NEW.id_edif_lejos, NEW.n_edif_lejos , NEW.d_edif_lejos
    from uv_edifi order by 3 desc limit 1;

  RETURN NEW;
  END
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.calcular_punto()
  OWNER TO postgres;


CREATE TRIGGER insert_nodes_geom
  BEFORE INSERT OR UPDATE
  ON uv_nodos
  FOR EACH ROW
EXECUTE PROCEDURE calcular_punto();



INSERT INTO uv_nodos (punto_x, punto_y) VALUES (-76.53509,3.37263);




-- Funcion para obtener el centroide de la edificacion segun su identificador

CREATE OR REPLACE FUNCTION obtieneCentroideEdificacion(integer) RETURNS geometry AS $$
DECLARE
 sql_result geometry;
 id_poligono  alias for $1;
BEGIN
 SELECT st_centroid(the_geom) into sql_result from uv_edifi where osm_id=id_poligono::text;
 RETURN sql_result ;
END;
$$ LANGUAGE plpgsql;





-- para poder visualzar desde el GIS debo crear una vista

create view uv_edificioslineasvista as 
select id_punto,  ST_Collect(st_makeline(the_geom,obtieneCentroideEdificacion(id_edif_cerca) ) , st_makeline(the_geom,obtieneCentroideEdificacion(id_edif_lejos) ))
as the_geom , 'Id. Edifio cerca: ' || id_edif_cerca || ' Id. Edificio lejos: ' ||  id_edif_lejos as comentario
from uv_nodos



SELECT Populate_Geometry_Columns('public.uv_edificioslineasvista'::regclass);




---crear cuantos puntos desee

INSERT INTO uv_nodos (punto_x, punto_y) VALUES (-76.53054,3.37481); 
INSERT INTO uv_nodos (punto_x, punto_y) VALUES (-76.52990,3.37400); 



-- =================================================================
---Crear una vista que permita generar un área de influencia (buffer) de 50 mts en el centro geométrico de la línea comprendida desde el punto de inicio y el edificio mas lejano


create view uv_lineaentreedificios as 
select id_punto, st_makeline(obtieneCentroideEdificacion(id_edif_cerca), obtieneCentroideEdificacion(id_edif_lejos)) as the_geom
 from uv_nodos;


 SELECT Populate_Geometry_Columns('public.uv_lineaentreedificios'::regclass);
 
 
 --- creo el buffer a 50 metros en el centro gometrico entre los dos edificios.
 
 
 create view uv_centroidebufferlineaentreedificios as 
 select id_punto,  st_transform(st_buffer(   st_transform( st_centroid(the_geom)  ,3115)    , 50   ) ,4326)  as the_geom
 from  uv_lineaentreedificios


  SELECT Populate_Geometry_Columns('public.uv_centroidebufferlineaentreedificios'::regclass);
 
 -- =================================================================
 
 -- =================================================================
 --- Crear una función o trigger que permita calcular el azimut entre el edificio mas lejano y mas cercano.
 
 
 

 ALTER TABLE uv_nodos ADD COLUMN azimuth_entre_edificios double precision;




select id_punto, id_edif_cerca, id_edif_lejos,   st_azimuth(obtieneCentroideEdificacion(id_edif_cerca) ,obtieneCentroideEdificacion(id_edif_lejos))/(2*pi())*360 as azimuth_entre_edificios
 from uv_nodos order by id_punto desc limit 1;
 



CREATE OR REPLACE FUNCTION public.calcular_azimuth()
  RETURNS trigger AS
$BODY$
  BEGIN
    select st_azimuth(obtieneCentroideEdificacion(id_edif_cerca) ,obtieneCentroideEdificacion(id_edif_lejos))/(2*pi())*360 
INTO NEW.azimuth_entre_edificios
from uv_nodos order by id_punto desc limit 1;

  RETURN NEW;
  END
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.calcular_azimuth()
  OWNER TO postgres;



  CREATE TRIGGER calcula_nodes_azimuth
  BEFORE INSERT OR UPDATE
  ON uv_nodos
  FOR EACH ROW
EXECUTE PROCEDURE calcular_azimuth();



select * from uv_nodos;


INSERT INTO uv_nodos (punto_x, punto_y) VALUES (-76.33490,3.44300); 
 
 



