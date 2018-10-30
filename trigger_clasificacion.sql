CREATE TABLE clasificador(
	valor integer, 
	clase varchar(50));

insert into clasificador(valor, clase) values (1,'Pastos');
insert into clasificador(valor, clase) values (2,'Cultivo');
insert into clasificador(valor, clase) values (3,'Zona Urbana');
insert into clasificador(valor, clase) values (4,'Zona Industrial'); 
insert into clasificador(valor, clase) values (0,'No definida'); 	
	

	
CREATE TABLE puntos_clasifica (
gid serial NOT NULL,
the_geom geometry(point, 3115),
latitude double precision,
longitude double precision,
valor integer,
clase varchar(50),
CONSTRAINT puntos_clasifica_pkey PRIMARY KEY (gid)
);	




CREATE OR REPLACE FUNCTION clasifica_punto()
RETURNS TRIGGER AS $$
BEGIN
IF NEW.valor IS NULL THEN
            RAISE EXCEPTION 'El valor no puede estar vacio';
END IF;
NEW.longitude := st_x(st_transform(NEW.the_geom, 4326));
NEW.latitude := st_y(st_transform(NEW.the_geom, 4326));
NEW.clase := (SELECT clase FROM clasificador WHERE valor = NEW.valor);
RETURN NEW;
END;
$$ language 'plpgsql';	


CREATE TRIGGER trigger_puntos_clasifica BEFORE insert or update
ON puntos_clasifica FOR EACH ROW EXECUTE PROCEDURE
clasifica_punto();