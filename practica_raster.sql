CREATE DATABASE practicaraster WITH OWNER postgres;

CREATE EXTENSION postgis;
CREATE EXTENSION hstore;


raster2pgsql -c -C -s 3115 -f rast -F -I -M -t 100x100 DEM.tif public.dem_ejemplo > dem.sql


select * from dem_ejemplo


--SLOPE
CREATE TABLE public.slope AS SELECT ST_Slope(b.rast, 1, '32BF', 'PERCENT', 1.0) rast FROM public.dem_ejemplo b;
ALTER TABLE public.slope ADD COLUMN rid SERIAL PRIMARY KEY;
CREATE INDEX public_slope_gix ON public.slope USING GIST(st_convexhull(rast));

--Aspect 
CREATE TABLE public.aspect AS SELECT ST_Aspect(b.rast, 1, '32BF', 'DEGREES', true) rast FROM public.dem_ejemplo b;
ALTER TABLE public.aspect ADD COLUMN rid SERIAL PRIMARY KEY;
CREATE INDEX public_aspect_gix ON public.aspect USING GIST(st_convexhull(rast));




select * from public.slope;

--Pendiente (Vector)

CREATE TABLE public.slope_vector_square AS SELECT (ST_DumpAsPolygons(bslope.rast)).val slope, 
(ST_DumpAsPolygons(bslope.rast)).geom geom FROM public.slope bslope;
ALTER TABLE public.slope_vector_square ADD COLUMN id SERIAL PRIMARY KEY;
CREATE INDEX slope_vector_square_gix ON public.slope_vector_square USING GIST(geom);

--DEM (Vector)
CREATE TABLE public.dem_vector_square AS SELECT (ST_DumpAsPolygons(b.rast)).val elevation, 
(ST_DumpAsPolygons(b.rast)).geom geom FROM public.dem_ejemplo b;
ALTER TABLE public.dem_vector_square ADD COLUMN id SERIAL PRIMARY KEY;
CREATE INDEX dem_vector_square_gix ON public.dem_vector_square USING GIST(geom);

--ASPECT (Vector)
CREATE TABLE public.aspect_vector_square AS SELECT (ST_DumpAsPolygons(b.rast)).val aspecto, 
(ST_DumpAsPolygons(b.rast)).geom geom FROM public.aspect b;
ALTER TABLE public.aspect_vector_square ADD COLUMN id SERIAL PRIMARY KEY;
CREATE INDEX aspect_vector_square_gix ON public.aspect_vector_square USING GIST(geom);



------------------------

select ST_Height(rast) from dem_ejemplo;
select ST_GeoReference(rast, 'GDAL') from dem_ejemplo;
select ST_NumBands(rast) from dem_ejemplo;
select ST_PixelHeight(rast) from dem_ejemplo;
select ST_PixelWidth (rast) from dem_ejemplo;

select ST_Width(rast) from dem_ejemplo;

select ST_RasterToWorldCoord(rast,1,1) from dem_ejemplo;
select ST_RasterToWorldCoord(rast,1000,1000) from dem_ejemplo;

select ST_RasterToWorldCoordX (rast,1) from dem_ejemplo;
select ST_RasterToWorldCoordY (rast,1) from dem_ejemplo;

select ST_Histogram (rast) from dem_ejemplo;



SELECT (stats).*
FROM (SELECT rid, ST_Histogram(rast) As stats
    FROM dem_ejemplo
     WHERE rid=1) As foo;
	 
	 