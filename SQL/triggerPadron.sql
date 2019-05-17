delimiter #

drop trigger if exists bdHabitante#
drop trigger if exists buHabitante#
drop trigger if exists biHabitante#
drop trigger if exists buPropietario#


drop trigger if exists tr2#

create trigger bdHabitante before delete on habitante
	for each row
	begin
		if(select count(*) from habitante where empadronadoEn = old.empadronadoEn) = 1 then
			signal sqlstate '45000' set mysql_errno = 5000,
			message_text = 'Error: Un municipio no se puede quedar sin habitantes';
		end if;
	end#

create trigger buHabitante before update on habitante
	for each row
	begin
		if(select count(*) from habitante where empadronadoEn = old.empadronadoEn) = 1 
		and (old.empadronadoEn <> new.empadronadoEn) then
			signal sqlstate '45000' set mysql_errno = 5000,
			message_text = 'Error: Un municipio no se puede quedar sin habitantes';
		end if;
	end#

create trigger biHabitante before insert on propietario
	for each row
	begin
		if(select count(*) from propietario where vivienda = new.vivienda) = 3 then
			signal sqlstate '45000' set mysql_errno = 5001,
			message_text = 'Las viviendas no pueden tener mas de 3 propietarios';
		end if;
	end#

create trigger buPropietario before update on propietario
	for each row
	begin
		if(select count(*) from propietario where vivienda = new.vivienda) = 3 and (old.vivienda <> new.vivienda) then
		signal sqlstate '45000' set mysql_errno = 5002,
		message_text = 'Las viviendas no pueden tener mas de 3 propietarios';
		end if;

		if(select count(*) from propietario where vivienda = old.vivienda) = 1 and (old.vivienda <> new.vivienda) then
		signal sqlstate '45000' set mysql_errno = 5002,
		message_text = 'Las viviendas no pueden tener menos de 1 propietarios';
		end if;

		if(new.fHasta is not null) and (new.fDesde > new.fHasta) then
		signal sqlstate '45000' set mysql_errno = 5003,
		message_text = 'Error: Fecha incorrecta';
		end if;

	end#
delimiter ;