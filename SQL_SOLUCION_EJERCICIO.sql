select * from edificios;

--PUNTO 1
select id_edi, capacidad , sede from edificios;

select id_edi, capacidad , sede , capacidad*1.1 from edificios where sede='Melendez';

update edificios set capacidad =  capacidad*1.1 where sede='Melendez';

select id_edi, capacidad , sede from edificios;


--PUNTO 2

select id_edi, estado , disponible,  capacidad from edificios;


select id_edi, estado , disponible,  capacidad from edificios where estado in ('Malo','Regular') and capacidad > 100


update edificios set disponible =  false where estado in ('Malo','Regular') and capacidad > 100

select id_edi, estado , disponible,  capacidad from edificios where estado in ('Malo','Regular') and capacidad > 100

--delete from edificios

-- PUNTO 3


insert into lugares(id_pol,nombre,the_geom) values (1,'Lago Central',
GeometryFromText('POLYGON((-76.53445 3.37363 , -76.53417 3.37363  , -76.53420 3.37303 , -76.53453 3.37340 , -76.53445 3.37363 ))', 4326));


select st_area(  st_transform( the_geom , 3115 ) ) as area_m2  ,  
st_perimeter(  st_transform( the_geom , 3115 ) ) as perimeter_m,
st_perimeter(  st_transform( the_geom , 3115 ) )/1000 as perimeter_km 
 from lugares where id_pol=1

