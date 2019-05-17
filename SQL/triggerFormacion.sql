delimiter #

drop trigger if exists aiEmpleado#
drop trigger if exists auEmpleado#
drop trigger if exists bu_Edicion#
drop trigger if exists bi_matricula#
drop trigger if exists ad_matricula#
drop trigger if exists bu_matricula#

-- Cuando se inserta comprobar que si es capacitado, debe insertarse en la tabla capacitado. Si no esta capacitado, no se inserta.

create trigger aiEmpleado after insert on empleado
	for each row
	begin
		if exists (select new.codEmp from empleado where capacitado = 'S') then
			insert into capacitado values (new.codEmp);
		end if;

	end#

create trigger auEmpleado after update on empleado
	for each row
	begin
		if (old.capacitado = 'N') and (new.capacitado = 'S') then
			insert into capacitado values (new.codEmp);
		end if;

		if (old.capacitado = 'S') and (new.capacitado = 'N') then
			delete from capacitado where old.codEmp = codEmp;
		end if;
	end#

-- Exclusion de Matriculado y profesor

create trigger bu_Edicion before update on edicion
	for each row
	begin
		if (new.profesor is not null) and (old.profesor <> new.profesor) then

			if exists (select * from matricula 
						where fecha = new.fecha and codCurso = new.codCurso and new.profesor = empleado) then
				signal sqlstate '45000' set mysql_errno = 5005, message_text = 'ERROR';
			end if;
		end if;
	end# 

-- Si un curso tiene como requisito otro, hay que comprobar que el empleado tenga ese curso.

/*create trigger bi_matricula before insert on matricula
	for each row 
	begin
        if not exists (select empleado from matricula m where not exists 
                (select * from prerreq p where p.cursoReq = m.curso and p.obligatorio = '1'))
        end if;
        if not exists (select empleado from matricula m where new.empleado = empleado and not exists 
        			(select * from prerreq p where p.cursoReq = new.curso and not exists 
        			(select * from prerreq p2 where p2.cursoReq = new.curso and p.obligatorio = '1'))) then
                signal sqlstate '45000' set mysql_errno = 5007, message_text = 'El empleado no cumple con los requisitos';
        end if;
	end#*/

create trigger bu_matricula before update on matricula
	for each row
	begin
		signal sqlstate '45000' set mysql_errno = 5008, 
		message_text = 'Las matriculas no pueden ser modificadas, borrala y vuelve a crearla';
	end#

create definer = current_user trigger ad_matricula after delete on matricula
	for each row
	begin
		create table if not exists matriculaBorradas(fechaBorrado timestamp, usuario varchar(255), fechaCurso date, curso char(15), empleado char(5));
		insert into matriculaBorradas values (timestamp(now()), user(), old.fecha,old.curso,old.empleado);
	end#
delimiter ;
