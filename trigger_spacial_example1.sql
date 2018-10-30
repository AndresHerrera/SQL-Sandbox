CREATE TABLE label_point (
gid serial NOT NULL,
geom geometry(point, 3115),
label_sample varchar(255),
CONSTRAINT label_point_pkey PRIMARY KEY (gid)
);

CREATE TABLE soil (
gid serial NOT NULL,
geom geometry(polygon, 3115),
label varchar(255),
CONSTRAINT soil_pkey PRIMARY KEY (gid)
);


-- Trigger for point Layer

CREATE OR REPLACE FUNCTION sample_label_point() RETURNS TRIGGER AS
$BODY$
DECLARE
BEGIN
raise notice 'point trigger starts now: %', now();
IF TG_OP = 'INSERT'
THEN
  IF
    (SELECT COUNT(*)
     FROM
       (SELECT t.gid
        FROM label_point AS t,
        soil AS s
        WHERE st_Within(NEW.geom, s.geom)) AS foo) > 0
  THEN
    SELECT soil.label
INTO NEW.label_sample
FROM soil
WHERE ST_Intersects(NEW.geom, soil.geom);
raise notice 'point trigger ends now: %', now();
    RETURN NEW; 
  ELSE
    RAISE notice 'no intersection';
    RAISE notice 'point trigger ends now: %', now();
    RETURN NEW;
  END IF;
ELSIF TG_OP = 'UPDATE'
THEN
IF
(ST_Equals(NEW.geom , OLD.geom)=FALSE)
THEN

  IF
    (SELECT COUNT(*)
     FROM
       (SELECT t.gid
        FROM label_point AS t,
        soil AS s
        WHERE st_Within(NEW.geom, s.geom)
        AND (t.gid <> OLD.gid)) AS foo) > 0 
  THEN
SELECT soil.label
INTO NEW.label_sample
FROM soil
WHERE ST_Intersects(NEW.geom, soil.geom);
    RAISE Notice 'Intersection found!';
    RETURN NEW; 

  ELSE 
  SELECT NULL
    INTO NEW.label_sample;
  RETURN NEW; 
  raise notice 'point trigger ends now: %', now();
  END IF; 
ELSE
Raise Notice 'Update of attribute data';
raise notice 'point trigger ends now: %', now();
Return NEW;
END IF;
END IF; 
END; 
$BODY$ 
LANGUAGE plpgsql;

-----

CREATE TRIGGER label_point_trigger
BEFORE INSERT OR UPDATE ON label_point
FOR EACH ROW EXECUTE PROCEDURE sample_label_point();


-----------------------------------------

-- Trigger for Soil Layer

CREATE OR REPLACE FUNCTION soil_label() RETURNS TRIGGER AS
$BODY$
DECLARE
new_label text := quote_ident(NEW.label);  -- assign at declaration
BEGIN
IF TG_OP = 'INSERT'
THEN
raise notice 'soil insert-trigger starts now: %', now();
  IF
    (SELECT COUNT(*)
     FROM
       (SELECT t.gid
        FROM label_point AS t,
        soil AS s
        WHERE st_Within(t.geom, NEW.geom)) AS foo) > 0
  THEN
    EXECUTE 'UPDATE label_point SET label_sample = $2 WHERE ST_Within(label_point.geom, $1)'
        USING NEW.geom, NEW.label;
--   raise notice 'soil trigger ends now: %', now();
    RETURN NEW; 
  ELSE
    RAISE Notice 'no intersection';
    RETURN NEW;
  END IF;
ELSIF TG_OP = 'UPDATE'
THEN
raise notice 'soil update-trigger starts now: %', now(); 
  IF
    (SELECT COUNT(*)
     FROM
       (SELECT t.gid
        FROM label_point AS t,
        soil AS s
        WHERE st_Within(t.geom, NEW.geom)
        --AND (t.gid <> OLD.gid)
        ) 
        AS foo) > 0 
  THEN
EXECUTE 'UPDATE label_point SET label_sample = ' ||  quote_literal(NEW.label)  || ' WHERE ST_Within(label_point.geom, $1)'
        USING NEW.geom;

   raise notice 'UPDATE label_point SET label_sample = % WHERE ST_Within(label_point.geom, %)', new_label, NEW.geom;

   raise notice'Label found: %', NEW.label;
    RAISE Notice 'Intersection found!';
    RETURN NEW; 

  ELSE 
  EXECUTE 'UPDATE label_point SET label_sample = NULL WHERE ST_Within(label_point.geom, $2)'
        USING NEW.geom, OLD.geom;
  RAISE NOTICE 'no intersection (anymore) of feature with gid=%', NEW.gid;
  RETURN NEW; 
  END IF; 
END IF; 
RAISE NOTICE 'Soil-trigger ends now: %', now();
END; 
$BODY$ 
LANGUAGE plpgsql;

CREATE TRIGGER label_soil_trigger
BEFORE INSERT OR UPDATE ON soil
FOR EACH ROW EXECUTE PROCEDURE soil_label();


------------------------------------------------------

-- Delete Trigger

CREATE OR REPLACE FUNCTION public.before_delete_soil()
  RETURNS trigger AS
$BODY$
BEGIN
 RAISE NOTICE 'Trigger % of table % is active % % 
 for record %', TG_NAME, TG_RELNAME, TG_WHEN, TG_OP,
                OLD.label;
 RAISE NOTICE 'Label % was deleted for Point with gid=%', 
               OLD.label, OLD.gid;
 UPDATE label_point SET label_sample = NULL WHERE ST_Within(label_point.geom, OLD.geom);
 RETURN OLD;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.before_delete_soil()
  OWNER TO postgres;


CREATE TRIGGER trigger_before_delete_soil
  BEFORE DELETE
  ON public.soil
  FOR EACH ROW
  EXECUTE PROCEDURE public.before_delete_soil();


