--Ejemplo 1
CREATE FUNCTION agregaruno(integer) RETURNS INTEGER AS '
    BEGIN
        RETURN $1 + 1;
    END;
' LANGUAGE 'plpgsql'


SELECT agregaruno(2);


--Ejemplo 2

CREATE FUNCTION concatenar_texto (TEXT, TEXT) RETURNS TEXT AS '
    BEGIN
        RETURN $1 || $2;
    END;
' LANGUAGE 'plpgsql';


SELECT concatenar_texto('Hola curso ', ' Geoinformacion en WEB');

-- Ejemplo 3 -- parametro con alias

CREATE OR REPLACE FUNCTION suma(int, int) RETURNS int AS $$
	DECLARE
	i ALIAS FOR $1;
	j ALIAS FOR $2;
	sum int;
  BEGIN
	sum := i + j;
	RETURN sum;
	END;
$$ LANGUAGE plpgsql;

SELECT suma(41, 1);

-- Ejemplo 4 -- parametros nombrados

CREATE OR REPLACE FUNCTION suma2(i int, j int) RETURNS int AS $$
	DECLARE
	sum int;
	BEGIN
	 sum := i + j;
	 RETURN sum;
	END;
$$ LANGUAGE plpgsql;

SELECT suma2(41, 1);

-- Ejemplo 5 Estructuras de control IF

CREATE OR REPLACE FUNCTION espar(i int) RETURNS boolean AS $$
 DECLARE
  tmp int;
  BEGIN
   tmp := i % 2;
   IF tmp = 0 THEN RETURN true;
      ELSE RETURN false;
   END IF;
 END;
$$ LANGUAGE plpgsql;

SELECT espar(3), espar(42);


-- Ejemplo 5 -- FOR


CREATE OR REPLACE FUNCTION factorial(i numeric) RETURNS numeric AS $$
  DECLARE
    tmp numeric; 
    result numeric;
  BEGIN
     result := 1;
     FOR tmp IN 1 .. i LOOP
       result := result * tmp;
     END LOOP;
     RETURN result;
   END;
$$ LANGUAGE plpgsql;

SELECT factorial(4::numeric);

-- EJEMPLO 6 -- WHILE


CREATE OR REPLACE FUNCTION factorial(i numeric) RETURNS numeric AS $$
  DECLARE 
  tmp numeric; 
  result numeric;
    BEGIN
       result := 1; tmp := 1;
       WHILE tmp <= i LOOP
         result := result * tmp;
         tmp := tmp + 1;
       END LOOP;
     RETURN result;
  END;
$$ LANGUAGE plpgsql;

SELECT factorial(42::numeric);


-- EJEMPLO 7 - Recursivo 


CREATE OR REPLACE FUNCTION factorial(i numeric) RETURNS numeric AS $$
   BEGIN
     IF i = 0 THEN
	RETURN 1;
	   ELSIF i = 1 THEN
	RETURN 1;
     ELSE
     RETURN i * factorial(i - 1);
     END IF;
   END;
$$ LANGUAGE plpgsql;

SELECT factorial(42::numeric);

--- EJEMPLO 8 


CREATE OR REPLACE FUNCTION totalPluviometros() RETURNS integer AS $total$
DECLARE
	total integer;
BEGIN
   SELECT count(*) into total FROM pluviometros;
   RETURN total;
END;
$total$ LANGUAGE plpgsql;


select totalPluviometros();


-- EJEMPLO 9 

CREATE OR REPLACE FUNCTION obtieneNombreFinca(text) RETURNS text AS $$
DECLARE
	result text;
BEGIN
   SELECT INTO result CAST(nombre_hda AS TEXT) FROM lotes WHERE codigo = $1; 
   RETURN result;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM lotes;

SELECT obtieneNombreFinca('000001');

-- Ejemplo 10

--select st_astext(the_geom) from pluviometros;
--select * from pluviometros;
--"POINT(1089483.85854425 889840.344782652)"

select max(gid)+1 as siguiente from pluviometros;


CREATE OR REPLACE FUNCTION crearNuevoPluviometro(double precision , double precision ) RETURNS boolean AS $$
DECLARE
	siguiente integer;
BEGIN
   SELECT INTO siguiente max(gid)+1 as siguiente from pluviometros;
   INSERT INTO pluviometros(id,id_pluv,the_geom) VALUES (siguiente, siguiente::text, st_setsrid(st_makepoint($1, $2) ,3115) ); 
   RETURN true;
END;
$$ LANGUAGE plpgsql;

select crearNuevoPluviometro(1089483.85854425,889840.344782652);

        
select * from pluviometros;

-- EJEMPLO 11

CREATE OR REPLACE FUNCTION borrarPluviometro(integer) RETURNS text AS $$
DECLARE
	idpluviometro ALIAS FOR $1;
BEGIN
   DELETE FROM pluviometros WHERE id = idpluviometro; 
   RETURN 'Pluviometro '|| idpluviometro::text || ' Eliminado';
END;
$$ LANGUAGE plpgsql;


SELECT borrarPluviometro(5);

select * from pluviometros;








