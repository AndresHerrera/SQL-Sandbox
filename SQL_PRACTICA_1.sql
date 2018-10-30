SELECT postgis_full_version();

-- PARA POSTGRES < 9.0 

CREATE DATABASE clase02
  WITH ENCODING='UTF8'
       OWNER=postgres
       TEMPLATE=template_postgis;
	   
-- PARA POSTGRES > 9.1

CREATE DATABASE clase02
  WITH ENCODING='UTF8'
       OWNER=postgres;
	   
CREATE EXTENSION postgis;
	   
	   
-- CREAR TABLA VIAS	   

CREATE TABLE vias
(
     id_lin integer,
     nombre character varying,
    CONSTRAINT vias_pkey PRIMARY KEY (id_lin)
);

-- AGREGAR CAMPO GEOMETRICO the_geom  de tipo LINESTRING 
SELECT AddGeometryColumn('', 'vias','the_geom',4326,'LINESTRING',2);



-- CREAR TABLA LUGARES	  
CREATE TABLE lugares
(
     id_pol integer,
     nombre character varying,
    CONSTRAINT lugares_pkey PRIMARY KEY (id_pol)
);

-- AGREGAR CAMPO GEOMETRICO the_geom  de tipo POLYGON 
SELECT AddGeometryColumn('', 'lugares','the_geom',4326,'POLYGON',2);


-- CREAR TABLA EDIFICIOS	 
CREATE TABLE edificios
(
  id_edi integer NOT NULL,
  nombre character varying,
  plan character varying,
  capacidad integer,
  estado character varying,
  n_pisos integer,
  sede character(20),
  disponible boolean,
  fecha date,
  CONSTRAINT edificios_pkey PRIMARY KEY (id_edi)
);
-- AGREGAR CAMPO GEOMETRICO the_geom  de tipo POINT 
SELECT AddGeometryColumn('', 'edificios','the_geom',4326,'POINT',2);


-- AGREGO EDIFICIOS

insert into edificios(id_edi,
  nombre,
  plan,
  capacidad,
  estado,
  n_pisos,
  sede,
  disponible,
  fecha,
  the_geom) 
values (320,'Facultad de Ciencias Naturales y Exactas','Ciencias Naturales y Exactas',
800,'Regular',4,'Melendez',true, date '1965-01-01', GeometryFromText('POINT(-76.53518386 3.37718168)',4326));

insert into edificios(id_edi,nombre,plan,capacidad,estado,n_pisos,sede,disponible,fecha,the_geom) 
values (318,'Biblioteca Mario Carvajal','Biblioteca',
250,'Bueno',4,'Melendez',true, date '1976-01-01', GeometryFromText('POINT(-76.53235121 3.37756070)',4326));

insert into edificios(id_edi,nombre,plan,capacidad,estado,n_pisos,sede,disponible,fecha,the_geom) 
values (350,'Escuela de Ingeniería Civil y Geomática','Civil',
120,'Bueno',2,'Melendez',true, date '1965-01-01', GeometryFromText('POINT(-76.5351224 3.3724392)',4326));

insert into edificios(id_edi,nombre,plan,capacidad,estado,n_pisos,sede,disponible,fecha,the_geom) 
values (346,'Facultad de Ingenierías','Topografica',
212,'Excelente',2,'San Fernando',false, date '1980-01-01', GeometryFromText('POINT(-76.5321705 3.3753206)',4326));

insert into edificios(id_edi,nombre,plan,capacidad,estado,n_pisos,sede,disponible,fecha,the_geom) 
values (342,'Multitalleres',' ',
140,'Malo',3,'Melendez',false, date '2001-01-05', GeometryFromText('POINT(-76.53062131 3.37608989)',4326));



select * from edificios;

select id_edi, capacidad, estado, nombre  from edificios;

select id_edi, capacidad, estado, nombre  from edificios where estado = 'Bueno';

select id_edi, capacidad, estado, nombre  from edificios where estado = 'Bueno' AND capacidad > 200;



update edificios set fecha = date'1972-05-01' where id_edi=346;

select * from edificios;

select id_edi, capacidad, estado, nombre, the_geom from edificios;
select id_edi, capacidad, estado, nombre, st_astext(the_geom) from edificios;
select id_edi, capacidad, estado, nombre, st_askml(the_geom) from edificios;

insert into lugares(id_pol,nombre,the_geom) values (1,'Lago Central',
GeometryFromText('POLYGON((-76.53445 3.37363 , -76.53417 3.37363  , -76.53420 3.37303 , -76.53453 3.37340 , -76.53445 3.37363 ))', 4326));

delete from lugares where nombre='Lago Central';

select * from lugares;

insert into lugares(id_pol,nombre,the_geom) values (2,'Coliseo',
GeometryFromText('POLYGON((-76.5331673 3.3708657 , -76.5330178 3.3708621 , -76.5330178 3.3709095,  -76.5329664 3.3709095,
 -76.5329181 3.3709095,  -76.5328428 3.3709095 , -76.5328428 3.3708511, -76.5327261 3.3708475 , -76.5327261 3.3706506 , -76.5328573 3.3706506 ,  -76.5328573 3.3705959 , 
  -76.5330251 3.3705995 ,  -76.5330251 3.3706469 , -76.5331673 3.3706469 ,  -76.5331673 3.3707737 , -76.5331673 3.3708657))', 4326));

select * from lugares;

select id_pol, nombre,st_centroid(the_geom) from lugares;

select id_pol, nombre,st_astext(st_centroid(the_geom)) from lugares;

select id_pol, nombre,st_area(st_centroid(the_geom)) from lugares;

select id_pol, nombre,st_area(the_geom) from lugares;

select id_pol, nombre,st_area(  st_transform( the_geom , 3115 ) )  from lugares;

select id_pol, nombre,st_area(  st_transform( the_geom , 3115 ) )/10000  as hectareas  from lugares;


insert into vias(id_lin,nombre,the_geom) values (1,'Calle 13 -  Av Paso Ancho',
GeometryFromText('LINESTRING(-76.53702 3.37116 ,  -76.53016 3.36760   )', 4326));

select id_lin, nombre,st_astext(st_centroid(the_geom)) from vias;

select id_lin, nombre,length(st_transform( the_geom , 3115 )) from vias;













