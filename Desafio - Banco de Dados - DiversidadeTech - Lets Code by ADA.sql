create database copa_nordestina;

create table Estado (
	id serial,
	nome varchar (60) not null unique,
	uf char (2) not null unique,
	primary key (id)
);

create table Cidade (
	id serial,
	nome varchar (60) not null,
	id_estado integer not null,
	primary key (id),
	foreign key (id_estado) references estado (id)
);

create table Times (
	id serial,
	nome varchar (60) not null,
	id_cidade integer not null,
	primary key (id),
	foreign key (id_cidade) references cidade (id)
);

create table jogos (
	id serial,
	id_time_1 integer not null,
	id_time_2 integer check (id_time_2 <> id_time_1) not null,
	data_jogo date not null,
	gols_time_1 integer check (gols_time_1 >= 0) not null,
	gols_time_2 integer check (gols_time_2 >= 0) not null,
	primary key (id),
	foreign key (id_time_1) references times (id),
	foreign key (id_time_2) references times (id)
);

create table jogadores (
	id serial,
	nome varchar (60) not null,
	idade integer check (idade >= 0) not null,
	id_time integer not null,
	primary key (id),
	foreign key (id_time) references times (id)
);

insert into Estado (nome, uf) 
values 
	('Pernambuco', 'PE'),
	('Paraíba', 'PB'),
	('Alagoas', 'AL'),
	('Rio Grande do Norte', 'RN'),
	('Maranhão', 'MA'),
	('Ceará', 'CE'),
	('Sergipe', 'SE'),
	('Bahia', 'BA');

select * from estado;

insert into cidade (nome, id_estado)
values
('Recife', 1),
('Joâo Pessoa', 2),
('Maceió', 3),
('Natal', 4),
('São Luis', 5),
('Fortaleza', 6),
('Aracaju', 7),
('Salvador', 8);

select * from cidade;

insert into times (nome, id_cidade)
values
('Sport', 1),
('Botafogo da Paraíba', 2),
('CSA', 3),
('ABC', 4),
('Sampaio Corrêa', 5),
('Fortaleza', 6),
('Confiança', 7),
('Bahia', 8);

select *  from times;

insert into jogos 
(id_time_1, id_time_2, data_jogo, gols_time_1, gols_time_2)
values
(1, 5, '07-01-2022', 2, 1),
(2, 6, '07-01-2022', 1, 0),
(3, 7, '07-01-2022', 0, 2),
(4, 8, '07-01-2022', 1, 3),
(1, 2, '14-01-2022', 1, 2),
(7, 8, '14-01-2022', 0, 3),
(2, 8, '21-01-2022', 0, 1);

select * from jogos;

-- Total de vitórias por time
select
	times.nome as "time",
	vencedores.total_vitorias
from (
	select 
		count(*) as total_vitorias,
		CASE 
			WHEN gols_time_1 > gols_time_2 THEN id_time_1
		    WHEN gols_time_1 = gols_time_2 THEN null
		    ELSE id_time_2
		END AS vencedor
	FROM jogos 
	group by vencedor
) as vencedores inner join times 
on vencedores.vencedor = times.id
group by vencedores.total_vitorias, times.nome
order by vencedores.total_vitorias desc;

-- Time que mais venceu partidas (Campeão): Bahia
select
	times.nome as "time",
	vencedores.total_vitorias
from (
	select 
		count(*) as total_vitorias,
		CASE 
			WHEN gols_time_1 > gols_time_2 THEN id_time_1
		    WHEN gols_time_1 = gols_time_2 THEN null
		    ELSE id_time_2
		END AS vencedor
	FROM jogos 
	group by vencedor
) as vencedores inner join times 
on vencedores.vencedor = times.id
group by vencedores.total_vitorias, times.nome
order by vencedores.total_vitorias desc 
limit 1;


-- Total de gols por time
select 
	"time",
	times.nome,
	sum(gols) as "gols marcados" 
from (
	select 
		id_time_1 as "time", 
		gols_time_1 as gols 
	from jogos
	union all
	select 
		id_time_2 as "time",
		gols_time_2 as gols 
	from jogos
) as total_times inner join times 
on  total_times.time = times.id
group by "time", times.nome
order by "time", times.nome asc;

-- Total de gols sofridos por time
select 
	"time", 
	times.nome,
	sum(gols) as "gols sofridos"
from (
	select 
		id_time_2 as "time", 
		gols_time_1 as gols 
	from jogos
	union all
	select 
		id_time_1 as "time",
		gols_time_2 as gols 
	from jogos
) as total_times inner join times 
on  total_times.time = times.id
group by "time", times.nome
order by "time", times.nome asc;

-- Os times que mais sofreram gols foram Sport, ABC e Confiança, todos com 3 gols sofridos no campeonato. 
--Porém, observando-se o tópico "Total de vitórias por time", percebe-se que ABC participou de um menor
--número de partidas em relação a Sport e Confiança, que tiveram uma vitória, enquanto ABC foi eliminado na priimeira partida. 
--Portanto, pode-se considerar ABC como time com a pior defesa do campeonato.

