
drop trigger if exists aiEmpleado;

drop trigger if exists auEmpleado;
drop trigger if exists auEmpleado_a_no_capacitado;
drop trigger if exists bu_Edicion;
drop trigger if exists bi_matricula;
drop trigger if exists bi_matricula_prerreq;
drop trigger if exists ad_matricula;
drop trigger if exists bu_matricula;

-- Cuando se inserta comprobar que si es capacitado, debe insertarse en la tabla capacitado. Si no esta capacitado, no se inserta.

create trigger aiEmpleado after insert on empleado
for each row
when exists (select new.codEmp from empleado where capacitado = 'S')
begin
	insert into capacitado values (new.codEmp);
end;

create trigger auEmpleado after update on empleado
for each row
when (old.capacitado = 'N') and (new.capacitado = 'S')
begin
	insert into capacitado values (new.codEmp);
end;

create trigger auEmpleado_a_no_capacitado after update on empleado
for each row
when (old.capacitado = 'S') and (new.capacitado = 'N')
begin
	delete from capacitado where old.codEmp = codEmp;
end;

create trigger bu_Edicion before update on edicion
for each row
when ((new.profesor is not null) and (old.profesor <> new.profesor) 
	and exists (select * from matricula 
		where fecha = new.fecha and codCurso = new.codCurso and new.profesor = empleado))
begin
	select raise (ABORT, 'El profesor asignado ya está como alumno de ese curso');
end;

create trigger bi_matricula before insert on matricula
for each row
when exists (select * from edicion where fecha = new.fecha and codCurso = new.codCurso and new.profesor = empleado))
begin
	select raise (ABORT, 'El empleado asignado ya está como profesor de ese curso');
end;

--create trigger bi_matricula_prerreq before insert on edicion
--for each row
--when exists (select * from prerreq where prerreq.curso = new.curso and obligatorio))
--begin
--	select raise (ABORT, 'El empleado asignado ya está como profesor de ese curso');
--end;

create trigger bu_matricula before update on matricula
for each row
begin
	select raise (ABORT, 'Las matriculas no pueden ser modificadas, borrala y vuelve a crearla');
end;

create trigger ad_matricula before delete on matricula
for each row
begin
	insert into matriculaBorradas values (datetime(), 'alguien', old.fecha,old.curso,old.empleado);
end;