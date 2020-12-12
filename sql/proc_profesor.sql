CREATE OR REPLACE FUNCTION verificar_libro()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
	insbn_b numeric ;
begin
	if (TG_OP = 'INSERT' ) then
		select isbn from consulta_remota_libros
			where isbn = new.isbn into insbn_b;

	if insbn_b is not null then
			return new;
		else
			return null;
			end if;
	end if;
end
$function$;

-- Impide que se registre una referencia si el libro no existe
create trigger verificar_libro before insert or update on referencia for each row execute procedure verificar_libro();


  create or replace function consulta_profesor()returns setof consulta_profesores as $body$
  declare
  	r consulta_profesores;
  begin
  for r in

    SELECT
  	a.cod_a AS codigo_asignatura,
      a.nom_a AS nombre_asignatura,
  	e.nom_e AS estudiante,
      e.cod_e AS codigo,
  	i.grupo AS grupo,
      i.n1,
      i.n2,
      i.n3,
      COALESCE(i.n1, 0::numeric) * 0.35 + COALESCE(i.n2, 0::numeric) * 0.35 + COALESCE(i.n3, 0::numeric) * 0.3 AS definitiva
     FROM inscribe i,
      estudiantes e,
      asignaturas a,
  	profesores p
    WHERE e.cod_e = i.cod_e AND a.cod_a = i.cod_a AND p.id_p= i.id_p and p.id_p = ( SELECT CURRENT_USER::integer ) order by a.cod_a, i.grupo,e.nom_e asc;
  loop
  return next r;
  end loop;
  return;
  end
  $body$
  language 'plpgsql';

  create or replace function actualizar_info_profesor(nom_n varchar, dir_n varchar, tel_n bpchar, prof_n varchar)
  returns void as $actualizar_info_profesor$
  declare
  begin
  	update universidad.profesores set
  		nom_p = nom_n,
  		dir_p = dir_n,
  		tel_p = tel_n,
  		profesion=prof_n
  	WHERE
  		id_p=(SELECT CURRENT_USER::int);

  end
  $actualizar_info_profesor$ language plpgsql;

  create or replace function actualizar_notas_estudiante(id_e_n int, cod_a_n int, n1_n real, n2_n real, n3_n real)
returns void as $actualizar_notas_estudiante$
declare
begin
	update universidad.inscribe set
		n1 = n1_n,
		n2 = n2_n,
		n3 = n3_n
	WHERE
		cod_e=id_e_n AND
		cod_a=cod_a_n AND
		id_p=(SELECT CURRENT_USER::int);

end
$actualizar_notas_estudiante$ language plpgsql;
  
