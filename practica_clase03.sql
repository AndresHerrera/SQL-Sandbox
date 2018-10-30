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

--drop table uv_nodos

select * from  uv_edifi;


CREATE OR REPLACE FUNCTION calcular_punto()
  RETURNS "trigger" AS
  $BODY$
  BEGIN
    NEW.the_geom:=SetSRID(MakePoint(new.punto_x, new.punto_y), 4326) ;

    select osm_id, name, st_distance(the_geom,st_setsrid(st_makepoint(new.punto_x, new.punto_y),4326)) 
	INTO NEW.id_edif_cerca, NEW.n_edif_cerca , NEW.d_edif_cerca
    from uv_edifi order by 3 asc limit 1;

    select osm_id, name, st_distance(the_geom,st_setsrid(st_makepoint(new.punto_x, new.punto_y),4326)) 
	INTO NEW.id_edif_lejos, NEW.n_edif_lejos , NEW.d_edif_lejos
    from uv_edifi order by 3 desc limit 1;

  RETURN NEW;
  END
  $BODY$
LANGUAGE 'plpgsql' VOLATILE;



CREATE TRIGGER insert_nodes_geom
  BEFORE INSERT OR UPDATE
  ON uv_nodos
  FOR EACH ROW
EXECUTE PROCEDURE calcular_punto();


INSERT INTO uv_nodos (punto_x, punto_y) VALUES (-76.53509,3.37263);

select * from uv_nodos

------- EJEMPLO CREACION DE UNA FUNCION 


CREATE OR REPLACE FUNCTION cuadrado(integer) RETURNS integer AS $$
BEGIN
 RETURN $1*$1;
END;
$$ LANGUAGE plpgsql;

select cuadrado(5);


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


--DROP FUNCTION obtieneCentroideEdificacion(integer);

select astext(obtieneCentroideEdificacion(54580877));

--obtengo los centroides de los dos edificios... cercano y lejano
select id_punto,  id_edif_cerca, id_edif_lejos, obtieneCentroideEdificacion(id_edif_cerca), obtieneCentroideEdificacion(id_edif_lejos) 
from uv_nodos


-- le añado el punto de origen
select id_punto,  the_geom,  id_edif_cerca, id_edif_lejos, obtieneCentroideEdificacion(id_edif_cerca), obtieneCentroideEdificacion(id_edif_lejos) 
from uv_nodos

-- genero lineas desde el punto de origen hasta edificio mas cercano y hasta el edificio mas lejano

select id_punto,  id_edif_cerca,   st_makeline(the_geom,obtieneCentroideEdificacion(id_edif_cerca) ) , 
id_edif_lejos,   st_makeline(the_geom,obtieneCentroideEdificacion(id_edif_lejos) )  
from uv_nodos

-- colecto todo en una sola geometria y le añado un atributo para que sea identificada

select id_punto,  ST_Collect(st_makeline(the_geom,obtieneCentroideEdificacion(id_edif_cerca) ) , st_makeline(the_geom,obtieneCentroideEdificacion(id_edif_lejos) ))
as the_geom , 'Id. Edifio cerca: ' || id_edif_cerca || ' Id. Edificio lejos: ' ||  id_edif_lejos as comentario
from uv_nodos

-- para poder visualzar desde el GIS debo crear una vista

create view uv_edificioslineasvista as 
select id_punto,  ST_Collect(st_makeline(the_geom,obtieneCentroideEdificacion(id_edif_cerca) ) , st_makeline(the_geom,obtieneCentroideEdificacion(id_edif_lejos) ))
as the_geom , 'Id. Edifio cerca: ' || id_edif_cerca || ' Id. Edificio lejos: ' ||  id_edif_lejos as comentario
from uv_nodos

-- verifico que tipo de geometria es
select ST_GeometryType(the_geom) from uv_edificioslineasvista


SELECT Populate_Geometry_Columns('public.uv_edificioslineasvista'::regclass);

-- Registro la vista a la tabla de geometrias
INSERT INTO geometry_columns (f_table_catalog, f_table_schema, f_table_name,f_geometry_column,coord_dimension,srid,type) 
VALUES ('','public','uv_edificioslineasvista','the_geom',2,4326,'MULTILINESTRING');

select * from  uv_edificioslineasvista 

---crear cuantos puntos desee

INSERT INTO uv_nodos (punto_x, punto_y) VALUES (-76.53054,3.37481); 
INSERT INTO uv_nodos (punto_x, punto_y) VALUES (-76.52990,3.37400); 

------ agregando complejidad -----------------------------------------------------------------
-- creo un nodo en uv_nodos, desde un trigger el cual se dispara cuando se crea una nueva geometria



CREATE TABLE uv_puntoconectado
(
        id_punto serial,
       CONSTRAINT uv_puntoconectado_pkey PRIMARY KEY (id_punto)
);
SELECT AddGeometryColumn('','uv_puntoconectado','the_geom',4326,'POINT',2);


CREATE OR REPLACE FUNCTION genera_punto()
  RETURNS "trigger" AS
  $BODY$
  BEGIN
    INSERT INTO uv_nodos (punto_x, punto_y) VALUES (x(new.the_geom),y(new.the_geom));
  RETURN NEW;
  END
  $BODY$
LANGUAGE 'plpgsql' VOLATILE;


CREATE TRIGGER genera_punto_geom
  BEFORE INSERT OR UPDATE
  ON uv_puntoconectado
  FOR EACH ROW
EXECUTE PROCEDURE genera_punto();


---- 1) Crear una vista que permita generar un area de influencia (buffer) de 50 mts en el centro geometrico de la linea comprendida desde el punto de inicio y el edificio mas lejano
---- 2) Crear una función o trigger que permita calcular el azimuth entre el edificio mas lejano y mas cercano
---- 3) Elaborar una consulta que involucre la funcion st_convexhull y st_contains



select uc.the_geom, l.the_geom ,
 st_contains(uc.the_geom, l.the_geom), st_contains(l.the_geom, uc.the_geom),
 st_intersects(uc.the_geom, l.the_geom), st_intersects(l.the_geom, uc.the_geom),
 st_within(uc.the_geom, l.the_geom), st_within(l.the_geom, uc.the_geom),
 st_touches(uc.the_geom, l.the_geom), st_touches(l.the_geom, uc.the_geom),
 st_disjoint(uc.the_geom, l.the_geom), st_disjoint(l.the_geom, uc.the_geom),
 st_crosses(uc.the_geom, l.the_geom), st_crosses(l.the_geom, uc.the_geom),
 st_overlaps(uc.the_geom, l.the_geom), st_overlaps(l.the_geom, uc.the_geom)
from uv_cagua as uc , lugares as l  
where l.id_pol=1

SELECT st_area(the_geom) as "Area" FROM uv_cagua;
SELECT st_perimeter(the_geom) as "Perimetro" FROM uv_cagua;


select st_centroid(the_geom) as "Centroide WKB",
x(st_centroid(the_geom)) as " Coord X Centroide",
y(st_centroid(the_geom)) as " Coord Y Centroide" from uv_cagua;


SELECT st_dimension(the_geom) as "Dimension" FROM uv_cagua;
SELECT st_geometrytype(the_geom)as "Tipo Geometria" from uv_cagua;
SELECT getsrid(the_geom)as "SRID" from uv_cagua;


SELECT st_npoints(the_geom) as "NPOINTS" from uv_cagua;


SELECT *, astext(the_geom) FROM uv_cagua
WHERE ST_Distance(     ST_Transform( the_geom, 3115)   ,   
 ST_Transform(st_GeomFromText('POINT(-76.53386 3.37408)', 4326), 3115) ) < 120;


 SELECT *, astext(the_geom) FROM uv_cagua
WHERE ST_Distance(     ST_Transform( the_geom, 3115)   ,   
 ST_Transform(st_GeomFromText('POINT(-76.53386 3.37408)', 4326), 3115) ) > 120;


SELECT st_envelope(the_geom) as "NPOINTS" from uv_cagua;
SELECT st_buffer(the_geom,100) as "NPOINTS" from uv_cagua;
SELECT st_convexhull(the_geom) as "NPOINTS" from uv_cagua;
 





